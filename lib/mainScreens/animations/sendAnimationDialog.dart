import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class SendAnimationDialog extends StatefulWidget {
  const SendAnimationDialog({Key? key}) : super(key: key);

  @override
  _SendAnimationDialogState createState() => _SendAnimationDialogState();
}

class _SendAnimationDialogState extends State<SendAnimationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showSentText = false;

  static const Duration totalDuration = Duration(seconds: 10);
  static const Duration sentMessageDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    )..addListener(() {
        setState(() {});
      });

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showSentText = true;
        });

        // Close dialog after 2-3 seconds
        Future.delayed(sentMessageDuration, () {
          if (mounted) Navigator.pop(context);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _calculatePlanePosition(Size size, double orbitRadius) {
    final center = Offset(size.width / 2, size.height / 2);
    final t = _controller.value;

    if (t <= 0.4) {
      final t1 = t / 0.4;
      final angle = 2 * pi * t1;
      return center + Offset(cos(angle), sin(angle)) * orbitRadius;
    } else if (t <= 0.7) {
      final t2 = (t - 0.4) / 0.3;
      final start = center + Offset(orbitRadius, 0);
      return Offset.lerp(start, center, t2)!;
    } else {
      final t3 = (t - 0.7) / 0.3;
      final end = center + Offset(-orbitRadius, 0);
      return Offset.lerp(center, end, t3)!;
    }
  }

  double _calculatePlaneScale() {
    final t = _controller.value;
    if (t <= 0.4) {
      return 1.0;
    } else if (t <= 0.7) {
      final t2 = (t - 0.4) / 0.3;
      return lerpDouble(1.0, 5.0, t2)!;
    } else {
      final t3 = (t - 0.7) / 0.3;
      return lerpDouble(5.0, 1.0, t3)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final orbitRadius = min(size.width, size.height) / 4;
          final center = Offset(size.width / 2, size.height / 2);
          final planePos = _calculatePlanePosition(size, orbitRadius);
          final planeScale = _calculatePlaneScale();
          final earthRotationAngle = 2 * pi * _controller.value;

          return SizedBox(
            width: size.width,
            height: size.height,
            child: Center(
              child: _showSentText
                  ? const Text(
                      "Sent",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    )
                  : Stack(
                      children: [
                        Positioned(
                          left: center.dx - 40,
                          top: center.dy - 40,
                          child: Transform.rotate(
                            angle: earthRotationAngle,
                            child: Image.asset("assets/images/globe.png", width: 80, height: 80),
                          ),
                        ),
                        Positioned(
                          left: planePos.dx - 15, // Adjusted to center correctly
                          top: planePos.dy - 15, // Adjusted to center correctly
                          child: Transform.scale(
                            scale: planeScale,
                            child: Image.asset("assets/images/plane.png", width: 30, height: 30),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
