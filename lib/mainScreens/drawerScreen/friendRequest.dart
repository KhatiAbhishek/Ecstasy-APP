import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecstasyapp/constants.dart';

class AdmiringRequestsPage extends StatefulWidget {
  @override
  _AdmiringRequestsPageState createState() => _AdmiringRequestsPageState();
}

class _AdmiringRequestsPageState extends State<AdmiringRequestsPage> {
  List<Map<String, String>> friendRequests = [];
  bool isLoading = true;
  final String apiBaseUrl = AppConfig.apiBaseUrl;

  @override
  void initState() {
    super.initState();
    fetchFriendRequests();
  }

  Future<void> fetchFriendRequests() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final idToken = prefs.getString('idToken') ?? '';
      final sub = prefs.getString('sub') ?? '';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,size: 25,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Admiring requests",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: friendRequests.length,
                      itemBuilder: (context, index) {
                        final request = friendRequests[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(
                                request['profile_photo']!.isNotEmpty
                                    ? request['profile_photo']!
                                    : 'assets/images/defaultProfile.png',
                              ),
                            ),
                            title: Text(
                              request['stage_name']!,
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    acceptRequest(request['targetId']!);
                                  },
                                  icon: Image.asset(
                                    "assets/images/approve.png",
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    declineRequest(request['targetId']!);
                                  },
                                  icon: Image.asset(
                                    "assets/images/disapprove.png",
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}