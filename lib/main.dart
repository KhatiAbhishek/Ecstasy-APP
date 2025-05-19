import 'package:ecstasyapp/auth/termService.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstScreen(),
    );
  }
}

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  late VideoPlayerController _controller;
  bool _showVideo = false;
  bool _showSkipButton = false;

  @override
  void initState() {
    super.initState();

    // Initialize video controller with asset video and set volume
    _controller = VideoPlayerController.asset('assets/videos/Ecstasy_Video.mp4')
      ..initialize().then((_) {
        setState(() {});
      })
      ..setVolume(1.0) // Ensure volume is set
      ..setLooping(false);

    // Add listener to navigate when video finishes
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startVideo() {
    setState(() {
      _showVideo = true;
    });

    _controller.play();

    // Show skip button after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showSkipButton = true;
      });
    });
  }

  void _navigateToNextScreen() {
    _controller.pause();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust padding dynamically based on screen width
    final padding = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _showVideo
            ? Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Transform.scale(
                        scale: 1.5,
                        child: SizedBox(
                        //   width: screenHeight * 1.5, // Adjust width for landscape
                        // height: screenWidth * 0.9, // Adjust height for padding
                          width: screenWidth, 
                          height: screenHeight - padding * 30,
                          child: Transform.rotate(
                            angle: 270 * 3.14159 / 180, // Rotate video 270 degrees for landscape
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Position skip button at the bottom-right of the screen
                  if (_showSkipButton)
                    Positioned(
                      bottom: padding*2,
                      left: padding,
                      child: Transform.rotate(
                        angle: 3*3.14159/2,
                        child: ElevatedButton(
                          onPressed: _navigateToNextScreen,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color.fromRGBO(50, 120, 246, 1),
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text('Skip',style: TextStyle(fontSize: 18),),
                        ),
                      ),
                    ),
                ],
              )
            : GestureDetector(
                onTap: _startVideo,
                child: Image.asset(
                  'assets/images/ticket.png',
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}
