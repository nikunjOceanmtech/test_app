// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/get_access_token.dart';
import 'package:test_app/home_screen.dart';
import 'package:test_app/profile_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var permission = await Permission.notification.request();

  if (permission.isGranted) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("========================${await FirebaseMessaging.instance.getToken()}");
    print("========================${await GetAccessToken.getAccessToken()}");

    // Initialize the plugin for Android and iOS
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        handleNotificationTap(response);
      },
    );
    FirebaseMessaging.onBackgroundMessage(_handleMessage);
    FirebaseMessaging.onMessage.listen(_handleMessage);

    runApp(MyApp());
  } else {
    openAppSettings();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      getPages: [
        GetPage(name: '/', page: () => MyHomePage()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/profile', page: () => ProfileScreen()),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Notifications Demo'),
      ),
    );
  }
}

Future<void> _showNotification({required RemoteMessage message}) async {
  AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    Random().nextDouble().toString(),
    'Test',
    channelDescription: 'channel_description',
    importance: Importance.max,
    priority: Priority.high,
  );

  NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidNotificationDetails);
  String jsonString = jsonEncode(message.data);
  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? "",
    message.notification?.body ?? "",
    platformChannelSpecifics,
    payload: jsonString,
  );
}

Future<void> _handleMessage(RemoteMessage message) async {
  await _showNotification(message: message);
}

void handleNotificationTap(NotificationResponse response) {
  try {
    Map<String, dynamic> jsonMap = jsonDecode(response.payload ?? "");
    if (jsonMap["screen_type"] == "home") {
      Get.toNamed('/home');
    } else if (jsonMap["screen_type"] == "profile") {
      Get.toNamed('/profile');
    }
  } catch (e) {
    print("======================$e");
  }
}
