import 'package:ecstasyapp/mainScreens/chatScreen/ChatDisplayScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecstasyapp/constants.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> friends = [];
  String idToken = "";
  String sub = "";
  final String apiBaseUrl = AppConfig.apiBaseUrl;
  @override
  void initState() {
    super.initState();
    _loadPreferencesAndFetchData();
  }

  Future<void> _loadPreferencesAndFetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idToken = prefs.getString('idToken') ?? '';
      sub = prefs.getString('sub') ?? '';
    });
    print("idToken new: $idToken");
    print("sub new: $sub");
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
  final url = Uri.parse("$apiBaseUrl/api/v1/chat/chattingFriends");
  print("Fetching friends from: $url");

  final response = await http.get(
    url,
    headers: {
      "Authorization": "Bearer $idToken",
      "sub": sub,
    },
  );
  
  print("Response Status Code: ${response.statusCode}");
  print("Response Body: ${response.body}");

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      final List<dynamic> friendsData = responseData['data'];

      setState(() {
        friends =  friendsData.isNotEmpty ?
        friendsData.map((friend) => {
          "id": friend["user"]["id"].toString(),
          "name": friend["user"]["stage_name"].toString(),
          "profile_photo": friend["user"]["profile_photo"]?.toString() ?? "",
          "roomId": friend["roomId"].toString(),
        }).toList():[];
      });
    }
  } else {
    print("Error fetching friends: ${response.body}");
  }
}

  void navigateToChatDisplayScreen(
      BuildContext context, String personId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDisplayScreen(personId: personId, userName: userName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.person_add,
                  color: Colors.white,
                  size: 30,
                ),
                Column(
                  children: [
                    Image.asset(
                      'assets/images/profile_photo.png',
                      width: 80,
                      height: 80,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Ecstasy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 30,
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(55, 55, 55, 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: friends.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        return GestureDetector(
                          onTap: () {
                            navigateToChatDisplayScreen(
                                context, friend["id"]!, friend["name"]!);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: friend["profile_photo"] != null && friend["profile_photo"]!.isNotEmpty
                                      ? NetworkImage(friend["profile_photo"]!) as ImageProvider
                                      : AssetImage('assets/images/defaultProfile.png'),
                                  radius: 25,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    friend["name"]!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}