import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:ecstasyapp/constants.dart';

class ReportContentScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final String apiBaseUrl = AppConfig.apiBaseUrl;
  final String reportType;

  ReportContentScreen({required this.reportType});

  Future<void> _onShareButtonPressed(BuildContext context) async {
    final email = _emailController.text;
    final description = _descriptionController.text;

    // Validate email field
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email field cannot be empty!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Retrieve data from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final idToken = prefs.getString('idToken') ?? '';
      final String sub = prefs.getString('sub') ?? '';
      final String userId = prefs.getString('userId') ?? '';

      // API URL
      final String apiUrl = "$apiBaseUrl/api/v1/report/$userId";

      // API Body
      final Map<String, dynamic> body = {
        "data": {
          "email": email,
          "description": description,
          "reporttype": reportType,
          "contecttype": "image",
        },
      };

      // API Call
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $idToken',
          'sub': sub,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      // Handle response
      if (response.statusCode == 200) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Stack(
              children: [
                // Blurred Background with 60% opacity
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),

                // Dialog Box
                Center(
                  child: Dialog(
                    backgroundColor: const Color.fromRGBO(28, 28, 30, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Thank you for bringing this to our notice',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14, // Slightly increased font size
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Success GIF (MP4)
                          FutureBuilder<VideoPlayerController>(
                            future: _initializeVideoPlayer(
                                'assets/videos/success.mp4'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: VideoPlayer(snapshot.data!),
                                  ),
                                );
                              } else {
                                return const SizedBox(
                                    height: 200,
                                    width: 200); // Placeholder while loading
                              }
                            },
                          ),

                          const SizedBox(height: 20),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'For more info visit: ',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      'http://www.ecstasyapp.com/community-guidelines',
                                  style: const TextStyle(
                                    color: Colors
                                        .blue, // Changed link color to blue
                                    fontSize: 10,
                                    decoration: TextDecoration
                                        .underline, // Added underline for emphasis
                                  ),
                                  // Optionally handle the link tap
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Handle link tap if necessary
                                      print('Link tapped');
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );

        // Close the dialog and navigate back after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop(); // Close the dialog
          Navigator.of(context).pop(); // Navigate back
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share report. Try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<VideoPlayerController> _initializeVideoPlayer(String assetPath) async {
    VideoPlayerController controller = VideoPlayerController.asset(assetPath);
    await controller.initialize();
    controller.setLooping(true);
    controller.play();
    return controller;
  }

//for testing 
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Blurred Background with 60% opacity
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),

            // Dialog Box
            Center(
              child: Dialog(
                backgroundColor: const Color.fromRGBO(28, 28, 30, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Thank you for bringing this to our notice',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14, // Slightly increased font size
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // GIF (MP4) replacing check_circle icon
                      FutureBuilder<VideoPlayerController>(
                        future:
                            _initializeVideoPlayer('assets/videos/success.mp4'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return SizedBox(
                              height: 200, // GIF size 200x200
                              width: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: VideoPlayer(snapshot.data!),
                              ),
                            );
                          } else {
                            return const SizedBox(
                                height: 200,
                                width: 200); // Placeholder while loading
                          }
                        },
                      ),

                      const SizedBox(height: 20),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'For more info visit: ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'http://www.ecstasyapp.com/community-guidelines',
                              style: const TextStyle(
                                color:
                                    Colors.blue, // Changed link color to blue
                                fontSize: 10,
                                decoration: TextDecoration
                                    .underline, // Added underline for emphasis
                              ),
                              // Optionally handle the link tap
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Handle link tap if necessary
                                  print('Link tapped');
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    // Close the dialog and navigate back after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close the dialog
      Navigator.of(context).pop(); // Navigate back
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Text(
                    'Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        // _onShareButtonPressed(context),
                        _showSuccessDialog(context),
                    child: const Text(
                      'Share',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Image.asset(
                  'assets/images/profile_photo.png', // Replace with your image path
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 5.0),
                const Text(
                  'Ecstasy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const Text(
                    'We deeply appreciate your feedback, as it’s crucial for our evolution and improvement.\n\nThank you for your contribution.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text(
                          "Email",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20, // Increased font size
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18), // Adjusted font size
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16), // Adjusted hint text size
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(125, 125, 125, 1),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(125, 125, 125, 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50), // Adjusted spacing
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Text(
                          "Description",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20, // Increased font size
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          controller: _descriptionController,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18), // Adjusted font size
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16), // Adjusted hint text size
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(125, 125, 125, 1),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(125, 125, 125, 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
