// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:test_app/image_view_screen.dart';

Future<void> main() async {
  await dotenv.load(
    fileName: const bool.fromEnvironment('loadEnvFile') ? 'env_files/live_env/.env' : "env_files/dev_env/.env",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff084277),
        title: Text(widget.title, style: TextStyle(color: Colors.white70)),
      ),
      body: imagesList.isEmpty
          ? Center(child: Text("Data Not Found"))
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: imagesList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ImageViewScreen(imageUrl: imagesList[index])),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: imagesList[index],
                    errorWidget: (context, url, error) {
                      return Center(child: Text("Error"));
                    },
                  ),
                );
              },
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              imagesList = [];
              setState(() {});
            },
            tooltip: 'Increment',
            backgroundColor: Color(0xff084277),
            child: const Icon(Icons.clear, color: Colors.white),
          ),
          FloatingActionButton(
            onPressed: () async {
              apiCall();
            },
            tooltip: 'Increment',
            backgroundColor: Color(0xff084277),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> apiCall() async {
    print("==============================${dotenv.env["BASE_URL"].toString()}");
    final url = Uri.parse(dotenv.env["BASE_URL"].toString());

    final headers = {
      'accept': '*/*',
      'accept-language': 'en-US,en;q=0.9,gu;q=0.8',
      'content-type': 'application/json',
      'cookie':
          'sessionId=4213fb82-704e-4bf8-89b6-09038c6f17f3; intercom-id-jlmqxicb=b083c8f9-152d-4f48-bc38-d96469bffedb; intercom-session-jlmqxicb=; intercom-device-id-jlmqxicb=71d14b9a-bf69-44d4-993d-0ad7bd1b20c1; sessionId=8b862df5-fd6d-485f-a74b-15ad80204ea1d',
      'origin': 'https://www.blackbox.ai',
      'priority': 'u=1, i',
      'referer': 'https://www.blackbox.ai/agent/ImageGenerationLV45LJp',
      'sec-ch-ua': '"Chromium";v="128", "Not;A=Brand";v="24", "Google Chrome";v="128"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"macOS"',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-origin',
      'user-agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36'
    };

    final body = jsonEncode(
      {
        'messages': [
          {
            'id': 'YzzEqunm5RcEebt4xRchg',
            'content':
                'to create litle krishna image image size is 1080x1080 and proper hand and proper lag and proper 4 hand',
            'role': 'user'
          }
        ],
        'id': 'YzzEqunm5RcEebt4xRchg',
        'previewToken': null,
        'userId': null,
        'codeModelMode': true,
        'agentMode': {'mode': true, 'id': 'ImageGenerationLV45LJp', 'name': 'Image Generation'},
        'trendingAgentMode': {},
        'isMicMode': false,
        'maxTokens': 1000000000000000000,
        'isChromeExt': false,
        'githubToken': null,
        'clickedAnswer2': false,
        'clickedAnswer3': false,
        'clickedForceWebSearch': false,
        'visitFromDelta': false,
        'mobileClient': false
      },
    );

    for (int i = 0; i < 50; i++) {
      responseGet(url, headers, body);
    }
  }

  List<String> imagesList = [];

  Future<void> responseGet(Uri url, Map<String, String> headers, String body) async {
    var res = await post(url, headers: headers, body: body);
    log("===========================${res.body}");
    if (res.statusCode == 200) {
      imagesList.add(res.body.replaceAll('![Generated Image](', "").replaceAll(')', ''));
      setState(() {});
    }
  }
}
