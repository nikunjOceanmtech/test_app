// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class TrueCallerOverlay extends StatefulWidget {
  const TrueCallerOverlay({super.key});

  @override
  State<TrueCallerOverlay> createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  bool isGold = true;

  final _silverColors = const [
    Color(0xFFAEB2B8),
    Color(0xFFC7C9CB),
    Color(0xFFD7D7D8),
    Color(0xFFAEB2B8),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _silverColors,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                isGold = !isGold;
              });
              FlutterOverlayWindow.getOverlayPosition().then((value) {
                log("Overlay Position: $value");
              });
            },
            child: Stack(
              children: [
                ListTile(
                  title: Text(
                    "model.nTitle",
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("model.nBody"),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: () async {
                      await FlutterOverlayWindow.closeOverlay();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
