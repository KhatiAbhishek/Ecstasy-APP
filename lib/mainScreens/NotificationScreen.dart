import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecstasyapp/constants.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, String>> friendRequests = [];
   bool isLoading = true;
   List<dynamic> notifications = [];
  final String apiBaseUrl = AppConfig.apiBaseUrl;
  

  @override
  void initState() {
    super.initState();
    fetchFriendRequests();
    fetchNotifications();
  }

  Future<void> fetchFriendRequests() async {
     setState(() {
      isLoading = true;
         });
         
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final idToken = prefs.getString('idToken') ?? '';
      final sub = prefs.getString('sub') ?? '';
      print('subb :- $sub');
    print('idToken :- $idToken');
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/v1/request/request'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'sub': sub,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          final requests = jsonData['data']['requests'] as List;
          setState(() {
            friendRequests = requests.map((request) => {
                  'targetId': request['source'] as String,
                  'stage_name': request['stage_name'] as String,
                  'profile_photo': request['profile_photo'] as String,
                }).toList();
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load friend requests');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching friend requests: $e');
    }
  }


Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final idToken = prefs.getString('idToken') ?? '';
      final sub = prefs.getString('sub') ?? '';

      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/v1/notifications/'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'sub': sub,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          setState(() {
            notifications = jsonData['data'];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching notifications: $e');
    }
  }


  Future<void> acceptRequest(String targetId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final String sub = prefs.getString('sub') ?? '';

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/v1/request/accept/$targetId'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'sub': sub,
        },
      );

      if (response.statusCode == 200) {
        _showDialog(context, true);
        await fetchFriendRequests();
      }
    } catch (e) {
      print('Error accepting request: $e');
    }
  }

  Future<void> declineRequest(String targetId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final String sub = prefs.getString('sub') ?? '';

    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/api/v1/request/accept/$targetId'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'sub': sub,
        },
      );

      if (response.statusCode == 200) {
        _showDialog(context, false);
        await fetchFriendRequests();
      }
    } catch (e) {
      print('Error declining request: $e');
    }
  }

  void _showDialog(BuildContext context, bool isApproved) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            Center(
              child: Dialog(
                backgroundColor: Color.fromRGBO(24, 24, 24, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  height: 350,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isApproved ? "Accepted" : "Declined",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 24),
                        FutureBuilder<VideoPlayerController>(
                          future: _initializeVideoPlayer(
                              isApproved ? 'assets/videos/success.mp4' : 'assets/videos/failure.mp4'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              return SizedBox(
                                height: 200,
                                width: 200,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: VideoPlayer(snapshot.data!),
                                ),
                              );
                            } else {
                              return SizedBox(height: 150, width: 150);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  Future<VideoPlayerController> _initializeVideoPlayer(String assetPath) async {
    VideoPlayerController controller = VideoPlayerController.asset(assetPath);
    await controller.initialize();
    controller.setLooping(true);
    controller.play();
    return controller;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Center(
                child: Text(
                  "Notifications",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Friend requests section remains unchanged
                    Expanded(
                      flex: 1,
                      child: isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: friendRequests.length,
                              itemBuilder: (context, index) {
                                // ... (keeping the existing implementation)
                              },
                            ),
                    ),
                    // Updated notifications section
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                        child: Container(
                          color: Color.fromRGBO(55, 55, 55, 1),
                          child: isLoading
                              ? Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                  itemCount: notifications.length,
                                  itemBuilder: (context, index) {
                                    final notification = notifications[index];
                                    String displayMessage = notification['message'];
                                    
                                    // Handle special cases where message might be empty
                                    if (displayMessage.isEmpty && notification['meta'] != null) {
                                      if (notification['meta']['type'] == 'friend_request') {
                                        displayMessage = "You received a friend request";
                                      } else if (notification['meta']['type'] == 'accept_request') {
                                        displayMessage = "Your friend request was accepted";
                                      }
                                    }

                                    return Column(
                                      children: [
                                        ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: AssetImage(
                                                "assets/images/defaultProfile.png"),
                                          ),
                                          title: Text(
                                            displayMessage,
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                                          child: Divider(
                                            color: Colors.white,
                                            thickness: 1,
                                            indent: MediaQuery.of(context).size.width * 0.05,
                                            endIndent: MediaQuery.of(context).size.width * 0.05,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}