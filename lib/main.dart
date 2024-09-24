// ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, avoid_print

import 'dart:convert';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/notification/get_access_token.dart';
import 'package:test_app/notification/home_screen.dart';
import 'package:test_app/notification/profile_screen.dart';
import 'package:test_app/notification/send_notification.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var permission = await Permission.notification.request();

  if (permission.isGranted) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseMessaging.instance.subscribeToTopic("global1");
    print("=========================${await FirebaseMessaging.instance.getToken()}");
    print("=========================${await GetAccessToken.getAccessToken()}");

    _requestNotificationPermissions();

    registerNotificationListeners();

    FirebaseMessaging.onBackgroundMessage(_handleBgMessage);
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // Handle notification tap when app was terminated or in the background
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

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
      initialRoute: '/',
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
      body: ElevatedButton(
        onPressed: () async {
          sendNotification();
        },
        child: Text("Send Notification"),
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

@pragma('vm:entry-point')
Future<void> _handleMessage(RemoteMessage message) async {
  // Handle message when the app is in the foreground
  await _showNotification(message: message);
}

@pragma('vm:entry-point')
Future<void> _handleBgMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await registerNotificationListeners();
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  await _showNotification(message: message);
}

Future<void> registerNotificationListeners() async {
  print("============================");
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  var androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var iOSSettings = DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
    onDidReceiveLocalNotification: (id, title, body, payload) => {print("==========================1111$payload")},
  );
  var initSetttings = InitializationSettings(android: androidSettings, iOS: iOSSettings);
  await flutterLocalNotificationsPlugin.initialize(
    initSetttings,
    onDidReceiveNotificationResponse: (NotificationResponse payload) async {
      try {
        print("============================${payload.payload}");
        Map<String, dynamic> jsonMap = jsonDecode(payload.payload ?? "");
        print("============================${jsonMap}");
        await _handleNotificationTapFromPayload(jsonMap); // Handle notification tap from payload
      } catch (e) {
        print("======================$e");
      }
    },
  );
}

Future<void> _handleNotificationTap(RemoteMessage message) async {
  // Extract the screen type from the message
  String? screenType = message.data['screen_type'];
  print("==================== Handle Tap: screenType: $screenType");

  await Future.delayed(
    Duration(seconds: 1),
    () {
      print("=============================");
      if (screenType == "home") {
        Get.toNamed('/home'); // Navigate to home screen
      } else if (screenType == "profile") {
        Get.toNamed('/profile'); // Navigate to profile screen
      }
    },
  );
}

Future<void> _handleNotificationTapFromPayload(Map<String, dynamic> jsonMap) async {
  // Extract the screen type from the payload
  String? screenType = jsonMap["screen_type"];
  print("==================== Handle Payload: screenType: $screenType");

  await Future.delayed(
    Duration(seconds: 1),
    () {
      print("=============================");
      if (screenType == "home") {
        Get.toNamed('/home'); // Navigate to home screen
      } else if (screenType == "profile") {
        Get.toNamed('/profile'); // Navigate to profile screen
      }
    },
  );
}

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'Importance',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);
Future<void> _requestNotificationPermissions() async {
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}
