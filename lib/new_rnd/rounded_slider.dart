import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: MaterialApp(
        home: ArcSliderDemo(),
      ),
    );
  }
}

class ArcSliderDemo extends StatefulWidget {
  const ArcSliderDemo({super.key});

  @override
  ArcSliderDemoState createState() => ArcSliderDemoState();
}

class ArcSliderDemoState extends State<ArcSliderDemo> {
  double _value = 0.0; // Value between 0.0 and 1.0 (for the slider)

  // Detect the drag and update the value based on the angle of the arc
  void _onPanUpdate(DragUpdateDetails details, Size size) {
    final localPosition = details.localPosition;
    final center = Offset(size.width / 2, size.height); // Center of the arc
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    final angle = atan2(dy, dx);
    final normalizedAngle = angle >= pi ? angle - 2 * pi : angle;

    // Check if the touch is within the arc bounds
    if (normalizedAngle <= 0 && normalizedAngle >= -pi) {
      setState(() {
        // Reverse the normalization to make left-to-right gesture increase the value
        _value = (normalizedAngle + pi) / pi;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Arc Slider"),
      ),
      body: Center(
        child: GestureDetector(
          onPanUpdate: (details) {
            _onPanUpdate(details, Size(300, 150)); // Size of the painting area
          },
          child: CustomPaint(
            size: Size(300, 150), // Width and height of the slider
            painter: ArcSliderPainter(_value),
          ),
        ),
      ),
    );
  }
}

class ArcSliderPainter extends CustomPainter {
  final double value; // Slider value between 0 and 1
  ArcSliderPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    Paint trackPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint progressPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint thumbPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Draw the background arc (from pi to 2*pi)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, // Start at 180 degrees
      pi, // Sweep for 180 degrees
      false,
      trackPaint,
    );

    // Draw the progress arc based on the value
    double progressAngle = pi * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      progressAngle,
      false,
      progressPaint,
    );

    // Draw the thumb at the end of the progress arc
    final thumbX = center.dx + radius * cos(pi + progressAngle);
    final thumbY = center.dy + radius * sin(pi + progressAngle);
    canvas.drawCircle(Offset(thumbX, thumbY), 12.0, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint when the value changes
  }
}
