import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';


class FallingAnimation extends StatefulWidget {
  const FallingAnimation({Key? key}) : super(key: key);

  @override
  _FallingAnimationState createState() => _FallingAnimationState();
}

class _FallingAnimationState extends State<FallingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<FallingObject> _objects = [];
  final int objectCount = 50;
  late double screenWidth;
  late double screenHeight;
  final Random _random = Random();
  bool _animationRunning = true;
  
  // List of your 6 image assets
  final List<String> imageAssets = [
    
    
    
    
    'assets/images/Tomato_icon_4.png',
    'assets/images/Tomato_icon_3.png',
    
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addListener(_update);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      screenWidth = size.width;
      screenHeight = size.height;
      _initializeObjects();
      _controller.repeat();

      Timer(const Duration(seconds: 6), () {
        setState(() {
          _animationRunning = false;
        });
        _controller.stop();
        _controller.dispose();
      });
    });
  }

  void _initializeObjects() {
    _objects.clear();
    for (int i = 0; i < objectCount; i++) {
      double x = _random.nextDouble() * screenWidth;
      double y = -_random.nextDouble() * screenHeight;
      double speed = 200 + _random.nextDouble() * 300;
      double rotation = _random.nextDouble() * 360;
      double scale = 1 + _random.nextDouble();
      // Randomly select an image from the list
      String imagePath = imageAssets[_random.nextInt(imageAssets.length)];
      _objects.add(FallingObject(
        x: x,
        y: y,
        speed: speed,
        rotation: rotation,
        scale: scale,
        imagePath: imagePath,
      ));
    }
  }

  void _update() {
    if (!_animationRunning) return;

    const double frameTime = 1 / 60.0;
    for (var obj in _objects) {
      obj.y += obj.speed * frameTime;
      obj.rotation += 1.5;
      if (obj.y > screenHeight) {
        obj.y = -20;
        obj.x = _random.nextDouble() * screenWidth;
        // Optional: Randomize image again when object resets
        obj.imagePath = imageAssets[_random.nextInt(imageAssets.length)];
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _animationRunning
          ? _objects.map((obj) {
              return Positioned(
                left: obj.x,
                top: obj.y,
                child: Transform.rotate(
                  angle: obj.rotation * pi / 180,
                  child: Transform.scale(
                    scale: obj.scale,
                    child: Image.asset(
                      obj.imagePath, // Use the object's specific image
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              );
            }).toList()
          : [],
    );
  }
}

class FallingObject {
  double x;
  double y;
  double speed;
  double rotation;
  double scale;
  String imagePath; // Added image path property

  FallingObject({
    required this.x,
    required this.y,
    required this.speed,
    required this.rotation,
    required this.scale,
    required this.imagePath,
  });
}