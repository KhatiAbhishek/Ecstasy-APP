import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:ecstasyapp/constants.dart';

class ShareBottomSheet extends StatefulWidget {
  final String contentUrl;
  final String postId;
  const ShareBottomSheet({super.key, required this.contentUrl, required this.postId});

  @override
  _ShareBottomSheetState createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  Set<int> selectedIndexes = {};
  List<Map<String, dynamic>> friendList = [];
  bool isLoading = true;
  late IO.Socket socket;
  final String apiBaseUrl = AppConfig.apiBaseUrl;

  @override
  void initState() {
    super.initState();
    _fetchFriendsList();
    _initializeSocket();
  }

  // Initialize Socket.IO
  void _initializeSocket() {
    socket = IO.io('$apiBaseUrl', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    socket.onConnect((_) => print('Socket connected'));
    socket.onDisconnect((_) => print('Socket disconnected'));
  }

  // Fetch friends list from API
  Future<void> _fetchFriendsList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final String sub = prefs.getString('sub') ?? '';
    print("itTOken :- $idToken");
    print("subbb :- $sub");
    

    final apiUrl = '$apiBaseUrl/api/v1/chat/sharePostFriends';
    final headers = {
      'Authorization': 'Bearer $idToken',
      'sub': sub,
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      print('Friends API Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          setState(() {
            friendList = List<Map<String, dynamic>>.from(jsonData['data']).map((friend) {
              print('Friend data: $friend'); // Log each friend object
              return {
                'roomId': friend['roomId'],
                'stage_name': friend['user']['stage_name'],
                'profile_photo': friend['user']['profile_photo'] ?? 'assets/user.png',
                'userId': friend['user']['id'],
              };
            }).toList();
            isLoading = false;
          });
        } else {
          print('API success false: ${response.body}');
          setState(() => isLoading = false);
        }
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (error) {
      print('API call error: $error');
      setState(() => isLoading = false);
    }
  }

  // Share the post to selected friends via Socket.IO
  void _shareToFriends() async {
    if (selectedIndexes.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userId = prefs.getString('userId') ?? '';
    final String phoneNumber = prefs.getString('phoneNumber') ?? '';

    final selectedFriends = selectedIndexes.map((index) => friendList[index]).toList();

    if (!socket.connected) {
      print('Socket not connected, attempting to connect...');
      socket.connect();
      await Future.delayed(Duration(milliseconds: 500));
      if (!socket.connected) {
        print('Failed to connect socket');
        return;
      }
    }

    for (var friend in selectedFriends) {
      final roomId = friend['roomId'];
      if (roomId == null) {
        print('Warning: roomId is null for ${friend["stage_name"]}');
        continue;
      }
      
      // Modified to send postId instead of contentUrl
      final messageData = {
        'roomId': roomId,
        'senderId': userId,
        'message': '', 
        'postId': widget.postId, 
        'type': 'other',
      };

      print('Sharing post ${widget.postId} with ${friend["stage_name"]}');

      socket.emitWithAck('sendPrivateMessage', messageData, ack: (response) {
        print('Ack for ${friend["stage_name"]}: $response');
        if (response == 'Message sent') {
          print('Share successful for ${friend["stage_name"]}');
        } else {
          print('Share failed for ${friend["stage_name"]}: $response');
        }
      });
    }

    await Future.delayed(Duration(seconds: 1));
    print('Closing ShareBottomSheet');
    Navigator.pop(context);
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60 , horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                  const Text(
                    "Share",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  selectedIndexes.isNotEmpty
                      ? GestureDetector(
                          onTap: _shareToFriends,
                          child: const Text(
                            "Share",
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                        )
                      : const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.public, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Share the post privately with friends. They'll be able to see all post details.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : friendList.isEmpty
                        ? const Center(
                            child: Text(
                              "No friends available",
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            itemCount: friendList.length,
                            itemBuilder: (context, index) {
                              var friend = friendList[index];
                              bool isSelected = selectedIndexes.contains(index);

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: friend['profile_photo'].startsWith('http')
                                      ? NetworkImage(friend['profile_photo'])
                                      : AssetImage(friend['profile_photo']) as ImageProvider,
                                ),
                                title: Text(
                                  friend['stage_name'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        selectedIndexes.remove(index);
                                      } else {
                                        selectedIndexes.add(index);
                                      }
                                    });
                                  },
                                  child: Icon(
                                    isSelected ? Icons.check_circle : Icons.radio_button_off,
                                    color: isSelected ? Colors.blue : Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}