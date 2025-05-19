import 'dart:math';

import 'package:ecstasyapp/mainScreens/animations/dislikeAnimation.dart';
import 'package:ecstasyapp/mainScreens/animations/sendAnimationDialog.dart';
import 'package:ecstasyapp/mainScreens/drawerScreen/report.dart';
import 'package:ecstasyapp/mainScreens/feedShareScreen/admireShare.dart';
import 'package:ecstasyapp/mainScreens/profile/userProfile.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:confetti/confetti.dart';
import 'package:chewie/chewie.dart';
import 'package:ecstasyapp/constants.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late ConfettiController _likeConfettiController;
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool showAnimation = false;

  List<dynamic> feedData = [];
  int currentIndex = 0;
  bool isExpanded = false;
  int? expandedCommentIndex;
  bool isLoading = true;
  String? postId;
  late TextEditingController _shareController;

  bool isLiked = false;
  bool isDisliked = false;
  bool isAdmired = false;
  final String apiBaseUrl = AppConfig.apiBaseUrl;

  @override
  void initState() {
    super.initState();
    _likeConfettiController =
        ConfettiController(duration: const Duration(seconds: 4));
    _shareController = TextEditingController();
    // Initialize with a dummy controller to avoid uninitialized access
    _videoController = VideoPlayerController.network('');
    fetchFeedData();
  }

  Future<void> fetchFeedData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final idToken = prefs.getString('idToken') ?? '';
  final String sub = prefs.getString('sub') ?? '';

  final apiUrl = '$apiBaseUrl/api/v1/feed/feed';
  final headers = {
    'Authorization': 'Bearer $idToken',
    'sub': sub,
  };

  try {
    final response = await http.get(Uri.parse(apiUrl), headers: headers);
    print('API Response: ${response.statusCode} - ${response.body}'); // Log response
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['success']) {
        setState(() {
          feedData = jsonData['data'];
          print('Feed data loaded: ${feedData.length} items'); // Log count
          if (feedData.isNotEmpty) {
            currentIndex = 0;
            postId = feedData[currentIndex]['id'];
            isLiked = feedData[currentIndex]['isLiked'] ?? false;
            isDisliked = feedData[currentIndex]['isDisliked'] ?? false;
            isAdmired = feedData[currentIndex]['AdmireStatus'] != null;
          }
          isLoading = false;
        });
        _initializeMediaController();
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

  Future<void> toggleLike() async {
    if (postId == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final String sub = prefs.getString('sub') ?? '';

    final likeUrl = '$apiBaseUrl/api/v1/feed/like/$postId';
    final dislikeUrl = '$apiBaseUrl/api/v1/feed/dislike/$postId';
    final headers = {
      'Authorization': 'Bearer $idToken',
      'sub': sub,
      'Content-Type': 'application/json',
    };

    try {
      final newLikeState = !isLiked;
      final likeBody = jsonEncode({'isliked': newLikeState});
      final likeResponse =
          await http.put(Uri.parse(likeUrl), headers: headers, body: likeBody);

      if (likeResponse.statusCode == 200) {
        if (newLikeState && isDisliked) {
          final dislikeBody = jsonEncode({'disliked': false});
          final dislikeResponse = await http.put(Uri.parse(dislikeUrl),
              headers: headers, body: dislikeBody);
          if (dislikeResponse.statusCode == 200) {
            setState(() {
              isLiked = newLikeState;
              isDisliked = false;
              feedData[currentIndex]['isLiked'] = isLiked;
              feedData[currentIndex]['isDisLiked'] = isDisliked;
              feedData[currentIndex]['likes'] = isLiked
                  ? (feedData[currentIndex]['likes'] + 1)
                  : (feedData[currentIndex]['likes'] - 1);
              feedData[currentIndex]['dislikes'] -= 1;
              if (isLiked) _likeConfettiController.play();
            });
          } else {
            print('Failed to reset dislike: ${dislikeResponse.statusCode}');
            return;
          }
        } else {
          setState(() {
            isLiked = newLikeState;
            feedData[currentIndex]['isLiked'] = isLiked;
            feedData[currentIndex]['likes'] = isLiked
                ? (feedData[currentIndex]['likes'] + 1)
                : (feedData[currentIndex]['likes'] - 1);
            if (isLiked) _likeConfettiController.play(); // Trigger confetti
          });
        }
      } else {
        print('Like API error: ${likeResponse.statusCode}');
      }
    } catch (error) {
      print('API call error: $error');
    }
  }

  Future<void> toggleDislike() async {
    if (postId == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final String sub = prefs.getString('sub') ?? '';

    final likeUrl = '$apiBaseUrl/api/v1/feed/like/$postId';
    final dislikeUrl = '$apiBaseUrl/api/v1/feed/dislike/$postId';
    final headers = {
      'Authorization': 'Bearer $idToken',
      'sub': sub,
      'Content-Type': 'application/json',
    };

    try {
      final newDislikeState = !isDisliked;
      final dislikeBody = jsonEncode({'disliked': newDislikeState});
      final dislikeResponse = await http.put(Uri.parse(dislikeUrl),
          headers: headers, body: dislikeBody);

      if (dislikeResponse.statusCode == 200) {
        if (newDislikeState && isLiked) {
          final likeBody = jsonEncode({'isliked': false});
          final likeResponse = await http.put(Uri.parse(likeUrl),
              headers: headers, body: likeBody);
          if (likeResponse.statusCode == 200) {
            setState(() {
              isDisliked = newDislikeState;
              isLiked = false;
              feedData[currentIndex]['isDisLiked'] = isDisliked;
              feedData[currentIndex]['isLiked'] = isLiked;
              feedData[currentIndex]['dislikes'] = isDisliked
                  ? (feedData[currentIndex]['dislikes'] + 1)
                  : (feedData[currentIndex]['dislikes'] - 1);
              feedData[currentIndex]['likes'] -= 1;
              if (isDisliked) {
                showAnimation = true;
                Future.delayed(Duration(seconds: 4), () {
                  if (mounted) setState(() => showAnimation = false);
                });
              }
            });
          } else {
            print('Failed to reset like: ${likeResponse.statusCode}');
            return;
          }
        } else {
          setState(() {
            isDisliked = newDislikeState;
            feedData[currentIndex]['isDisLiked'] = isDisliked;
            feedData[currentIndex]['dislikes'] = isDisliked
                ? (feedData[currentIndex]['dislikes'] + 1)
                : (feedData[currentIndex]['dislikes'] - 1);
            if (isDisliked) {
              showAnimation = true;
              Future.delayed(Duration(seconds: 4), () {
                if (mounted) setState(() => showAnimation = false);
              });
            } else {
              showAnimation = false; // Ensure reset when undisliked
            }
          });
        }
      } else {
        print('Dislike API error: ${dislikeResponse.statusCode}');
      }
    } catch (error) {
      print('API call error: $error');
    }
  }

  void showReportDialog(BuildContext context) {
    String? selectedReportType;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          title: const Text('Report video',
              style: TextStyle(
                  color: Color.fromRGBO(50, 187, 255, 1),
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    for (String reportType in [
                      'Sexual content',
                      'Violent or repulsive content',
                      'Hateful or abusive content',
                      'Harmful or dangerous acts',
                      'Spam or misleading',
                      'Child abuse'
                    ])
                      CheckboxListTile(
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
                        value: selectedReportType == reportType,
                        onChanged: (bool? value) =>
                            setState(() => selectedReportType = reportType),
                        title: Text(reportType,
                            style: const TextStyle(color: Colors.white)),
                      ),
                  ],
                ),
              );
            },
          ),
          actionsPadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          actions: [
            Column(
              children: [
                const Divider(color: Colors.grey, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text('Cancel',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19))),
                      ),
                    ),
                    const VerticalDivider(color: Colors.grey, thickness: 1),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (selectedReportType != null) {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ReportContentScreen(
                                        reportType: selectedReportType!)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Please select a report type'),
                                    backgroundColor: Colors.red));
                          }
                        },
                        child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text('Report',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> sharePost() async {
    if (postId == null || _shareController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter content to share')));
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const SendAnimationDialog());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final String sub = prefs.getString('sub') ?? '';
    final String? userId = prefs.getString('userId') ?? '';
    final String? phoneNumber = prefs.getString('phoneNumber') ?? '';

    final apiUrl = '$apiBaseUrl/api/v1/share/';
    final headers = {
      'Authorization': 'Bearer $idToken',
      'sub': sub,
      'Content-Type': 'application/json'
    };
    final filename =
        feedData[currentIndex]['contentUrl'].split('/').last.split('?').first;
    final body = jsonEncode({
      "share": {
        "userId": userId,
        "postId": postId,
        "content": _shareController.text,
        "filename": filename,
        "createdBy": phoneNumber
      }
    });

    try {
      final response =
          await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      // Navigator.pop(context); // Close dialog
      if (response.statusCode == 200 || response.statusCode == 201) {
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text('Post shared successfully')));
        _shareController.clear();
        setState(() {});
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to share post')));
      }
    } catch (error) {
      Navigator.pop(context);
      print('Share API error: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error sharing post')));
    }
  }

  Future<void> toggleAdmire(int index) async {
    if (postId == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final String sub = prefs.getString('sub') ?? '';
    final userId = feedData[index]['user']['id'];
    final apiUrl = '$apiBaseUrl/api/v1/request/$userId';
    final headers = {
      'Authorization': 'Bearer $idToken',
      'sub': sub,
      'Content-Type': 'application/json'
    };
    final newAdmireState = !isAdmired;
    final body = jsonEncode({"isrequest": newAdmireState.toString()});

    try {
      final response =
          await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      if (response.statusCode == 200) {
        setState(() {
          isAdmired = newAdmireState;
          feedData[index]['AdmireStatus'] = isAdmired ? true : null;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Admire ${newAdmireState ? 'sent' : 'removed'} successfully')));
      } else {
        print('Admire API error: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update admire status')));
      }
    } catch (error) {
      print('Admire API call error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating admire status')));
    }
  }

 void _initializeMediaController() {
  if (feedData.isEmpty) return;

  final mediaUrl = feedData[currentIndex]['contentUrl'] ?? '';
  print('Initializing media: $mediaUrl');
  if (isVideoUrl(mediaUrl)) {
    _videoController.dispose();
    _videoController = VideoPlayerController.network(mediaUrl)
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoController,
            autoPlay: true,
            looping: false,
            allowFullScreen: false, // Disable fullscreen
            showOptions: false,
            fullScreenByDefault: false,
            showControls: false, // Hide all controls including progress bar
            // Remove additionalOptions for simplicity
          );
          print('Video initialized successfully');
        });
      }).catchError((error) {
        print('Video initialization error: $error');
        setState(() => _chewieController = null);
      });
  } else {
    print('Treating as image');
  }
}


  bool isVideoUrl(String url) {
    if (url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    // Check for common video extensions
    return lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('.avi') ||
        lowerUrl.contains('.mkv');
  }

  void _seekBy(int seconds) {
    if (_videoController.value.isInitialized) {
      final currentPosition = _videoController.value.position;
      final newPosition = currentPosition + Duration(seconds: seconds);
      _videoController.seekTo(newPosition);
    }
  }

  void _onVerticalSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null || feedData.isEmpty) return;

    if (details.primaryVelocity! > 0 && currentIndex > 0) {
      setState(() {
        currentIndex--;
        _updatePostState();
        _disposeControllers();
        _initializeMediaController();
      });
    } else if (details.primaryVelocity! < 0 &&
        currentIndex < feedData.length - 1) {
      setState(() {
        currentIndex++;
        _updatePostState();
        _disposeControllers();
        _initializeMediaController();
      });
    }
  }

  void _updatePostState() {
    postId = feedData[currentIndex]['id'];
    isLiked = feedData[currentIndex]['isLiked'] ?? false;
    isDisliked = feedData[currentIndex]['isDisLiked'] ?? false;
    isAdmired = feedData[currentIndex]['AdmireStatus'] != null;
  }

  @override
  void dispose() {
    _disposeControllers();
    _likeConfettiController.dispose();
    _shareController.dispose();
    super.dispose();
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _chewieController = null;
    if (_videoController.value.isInitialized) {
      _videoController.dispose();
    }
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareBottomSheet(
        contentUrl: feedData[currentIndex]['contentUrl'],
        postId: feedData[currentIndex]['id'],
      ),
    );
  }

  Future<List<dynamic>> fetchComments(String postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final String sub = prefs.getString('sub') ?? '';
    final apiUrl = '$apiBaseUrl/api/v1/feed/comment/$postId';
    final headers = {'Authorization': 'Bearer $idToken', 'sub': sub};

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) return jsonData['data'];
      }
      return [];
    } catch (error) {
      print('Comment fetch error: $error');
      return [];
    }
  }

 Future<void> _postReply(String commentId, String replyContent) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final idToken = prefs.getString('idToken') ?? '';
  final String sub = prefs.getString('sub') ?? '';
  final String userId = prefs.getString('userId') ?? '';
  final String phoneNumber = prefs.getString('phoneNumber') ?? '';
  final apiUrl = '$apiBaseUrl/api/v1/feed/reply';
  final headers = {
    'Authorization': 'Bearer $idToken',
    'sub': sub,
    'Content-Type': 'application/json'
  };
  final body = jsonEncode({
    "commentId": commentId,
    "content": replyContent,
    "createdBy": phoneNumber
  });

  try {
    print('Sending reply request to: $apiUrl');
    print('Request body: $body');
    
    final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);
    
    // Log the raw response for debugging
    print('Reply API response status: ${response.statusCode}');
    print('Reply API response content-type: ${response.headers['content-type']}');
    
    // Check if response is JSON
    final contentType = response.headers['content-type'] ?? '';
    final isJson = contentType.toLowerCase().contains('application/json');
    
    if (!isJson) {
      print('Warning: API returned non-JSON response: ${response.body.substring(0, min(200, response.body.length))}...');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server returned an unexpected response format'))
      );
      return;
    }
    
    // Now try to parse the JSON
    final jsonResponse = jsonDecode(response.body);
    print('Reply API response parsed: $jsonResponse');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final bool success = jsonResponse['success'] ?? false;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply posted successfully'))
        );
      } else {
        final String message = jsonResponse['message'] ?? 'Failed to post reply';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message))
        );
      }
    } else {
      print('Error: ${response.statusCode}, ${jsonResponse['message'] ?? 'Unknown error'}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post reply'))
      );
    }
  } catch (error) {
    print('Reply API error: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error posting reply'))
    );
  }
}

  void _showPinterestStyleOptions(BuildContext context) {
  final item = feedData[currentIndex];
  
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.transparent, // Make dialog background transparent
        contentPadding: EdgeInsets.zero,
        elevation: 0, // Remove shadow
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Increased spacing
          children: [
            // Like Option
            _buildOptionItem(
              icon: isLiked ? "assets/images/liked.png" : "assets/images/like.png",
              label: "Like (${item['likes'] ?? 0})",
              onTap: () {
                toggleLike();
                Navigator.pop(context);
              },
            ),
            
            // Share Option
            _buildOptionItem(
              icon: "assets/images/share.png",
              label: "Share (${item['totalUniqueShares'] ?? 0})",
              onTap: () {
                Navigator.pop(context);
                _showShareSheet(context);
              },
            ),
            
            // Dislike Option
            _buildOptionItem(
              icon: isDisliked ? "assets/images/disLiked.png" : "assets/images/disLike.png",
              label: "Dislike (${item['dislikes'] ?? 0})",
              onTap: () {
                toggleDislike();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildOptionItem({required String icon, required String label, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 78, 78, 85).withOpacity(0.7), // Semi-transparent background
        borderRadius: BorderRadius.circular(24.0), // Rounded corners
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1), 
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            icon,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error, color: Colors.white, size: 40);
            },
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()));
    }

    if (feedData.isEmpty) {
      return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
              child: Text('No posts available',
                  style: TextStyle(color: Colors.white))));
    }

    final item = feedData[currentIndex];

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragEnd: _onVerticalSwipe,
            child: Stack(
              children: [
                Column(
                  children: [
                    // Top Row with Admire, User Profile, and Report Button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Admire Button
                          GestureDetector(
                            onTap: () => toggleAdmire(currentIndex),
                            child: Container(
                              height: 24, // Reduced height
                              width: 40, // Reduced width
                              decoration: BoxDecoration(
                                color: isAdmired
                                    ? Colors.blue
                                    : Color.fromRGBO(128, 128, 128, 1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: isAdmired
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(3),
                                    width: 28,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: Center(
                                        child: Text(
                                            isAdmired ? 'Admired' : 'Admire',
                                            style: const TextStyle(
                                                fontSize:
                                                    4, // Reduced font size
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold))),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // User Profile
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserProfileView(
                                          targetId: item['user']['id'],
                                          admireCondition : item['AdmireStatus']
                                          
                                          )));
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  item['user']['profile_photo'] ??
                                      'https://via.placeholder.com/40', // Fallback URL
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                          'assets/images/profile_photo.png',
                                          height: 40,
                                          width: 40),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  item['user']['stage_name'] ?? 'Unknown',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12), // Reduced font size
                                ),
                              ],
                            ),
                          ),
                          // Report Button
                          GestureDetector(
                            onTap: () => showReportDialog(context),
                            child: Image.asset(
                              'assets/images/drawer.png',
                              height: 12,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Video/Image Container with Overlay Caption
                      Stack(
                    children: [
                      GestureDetector(
                        onLongPress: () => _showPinterestStyleOptions(context),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          width: double.infinity,
                          child: isVideoUrl(item['contentUrl'] ?? '')
                              ? (_chewieController != null
                                  ? Chewie(controller: _chewieController!)
                                  : Center(
                                      child: Text('Video unavailable',
                                          style: TextStyle(color: Colors.white))))
                              : Image.network(
                                  item['contentUrl'] ?? 'https://via.placeholder.com/300',
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Image load error: $error');
                                    return Center(
                                        child: Text('Image failed to load: $error',
                                            style: TextStyle(color: Colors.white)));
                                  },
                                ),
                        ),
                      ),
                      // Overlay Caption (Title + Description)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => isExpanded = !isExpanded),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item['title'] ?? 'No Title',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  item['description'] ?? 'No Description',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                  maxLines: isExpanded ? null : 2,
                                  overflow: isExpanded
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                    // Chat/Comments Container
                    Container(
                      // padding: const EdgeInsets.all(5.0),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _shareController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "Add a caption...",
                                    hintStyle: TextStyle(color: Colors.white54),
                                    filled: true,
                                    fillColor: Colors.grey[700],
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                              IconButton(
                                  icon: Icon(Icons.send, color: Colors.white),
                                  onPressed: sharePost),
                            ],
                          ),
                          SizedBox(height: 5),
                          GestureDetector(
                            onTap: () =>
                                _showCommentsBottomSheet(context, item['id']),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  if (item['comment'] != null)
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          item['comment']['user']
                                                  ['profile_photo'] ??
                                              'https://via.placeholder.com/32'),
                                      radius: 16,
                                      onBackgroundImageError: (e, s) =>
                                          Image.asset(
                                              'assets/images/profile_photo.png'),
                                    ),
                                  SizedBox(width: 8),
                                  if (item['comment'] != null)
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                                text:
                                                    "${item['comment']['user']['stage_name'] ?? 'Unknown'}: ",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text: item['comment']
                                                        ['content'] ??
                                                    '',
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14)),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  else
                                    Text("No comments yet",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    // Like/Dislike/Share Container (Styled like the image)
                    
                    SizedBox(height: 16),
                  ],
                ),
                // Confetti for Likes
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _likeConfettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.05,
                    numberOfParticles: 300,
                    gravity: 0.3,
                    colors: [Colors.green, Colors.blue, Colors.yellow],
                  ),
                ),
                // Falling Animation for Dislikes
                if (showAnimation) Positioned.fill(child: FallingAnimation()),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showCommentsBottomSheet(BuildContext context, String postId) async {
  final comments = await fetchComments(postId);
  
  // Track reply state outside the showModalBottomSheet
  Map<int, bool> showReplyFields = {};
  Map<int, TextEditingController> replyControllers = {};

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(color: Colors.black.withOpacity(0.5)),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              final isCommentExpanded = expandedCommentIndex == index;

                              // Initialize controller if needed
                              if (showReplyFields.containsKey(index) &&
                                  showReplyFields[index]! &&
                                  !replyControllers.containsKey(index)) {
                                replyControllers[index] = TextEditingController();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        comment['user']['profile_photo'] ??
                                            'https://via.placeholder.com/32'),
                                      onBackgroundImageError: (e, s) =>
                                          Image.asset('assets/images/profile_photo.png'),
                                    ),
                                    title: Text(
                                      comment['user']['stage_name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      comment['content'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                      maxLines: isCommentExpanded ? null : 2,
                                      overflow: isCommentExpanded
                                          ? TextOverflow.visible
                                          : TextOverflow.ellipsis,
                                    ),
                                    trailing: TextButton(
                                      onPressed: () {
                                        setModalState(() {
                                          showReplyFields[index] =
                                              !(showReplyFields[index] ?? false);
                                          if (!(showReplyFields[index] ?? false) &&
                                              replyControllers.containsKey(index)) {
                                            replyControllers[index]!.dispose();
                                            replyControllers.remove(index);
                                          }
                                        });
                                      },
                                      child: const Text(
                                        'Reply',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                    onTap: () => setModalState(() =>
                                        expandedCommentIndex =
                                            isCommentExpanded ? null : index),
                                  ),
                                  if (showReplyFields[index] ?? false)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 56.0,
                                        right: 16.0,
                                        bottom: 8.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Focus(
                                              onFocusChange: (hasFocus) {
                                                if (hasFocus) {
                                                  setModalState(() {});
                                                }
                                              },
                                              child: TextField(
                                                controller: replyControllers[index],
                                                style: const TextStyle(color: Colors.white),
                                                decoration: InputDecoration(
                                                  hintText: "Write a reply...",
                                                  hintStyle: const TextStyle(
                                                      color: Colors.white54),
                                                  filled: true,
                                                  fillColor: Colors.grey[700],
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(20),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.send,
                                                color: Colors.white),
                                            onPressed: () async {
                                              if (replyControllers.containsKey(index) &&
                                                  replyControllers[index]!
                                                      .text.isNotEmpty) {
                                                await _postReply(
                                                  comment['id'],
                                                  replyControllers[index]!.text,
                                                );
                                                setModalState(() {
                                                  showReplyFields[index] = false;
                                                  replyControllers[index]!.dispose();
                                                  replyControllers.remove(index);
                                                });
                                                final updatedComments =
                                                    await fetchComments(postId);
                                                setModalState(() {
                                                  comments.clear();
                                                  comments.addAll(updatedComments);
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (isCommentExpanded &&
                                      comment['replies'] != null &&
                                      comment['replies'].isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 32.0, top: 8.0),
                                      child: Column(
                                        children: comment['replies']
                                            .map<Widget>((reply) {
                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  reply['user']['profile_photo'] ??
                                                      'https://via.placeholder.com/30'),
                                              radius: 15,
                                              onBackgroundImageError: (e, s) =>
                                                  Image.asset(
                                                      'assets/images/profile_photo.png'),
                                            ),
                                            title: Text(
                                              reply['user']['stage_name'] ??
                                                  'Unknown',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(
                                              reply['content'] ?? '',
                                              style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
}
