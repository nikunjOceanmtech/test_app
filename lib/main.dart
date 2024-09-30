// ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, avoid_print

import 'dart:convert';
import 'dart:math';
import 'dart:developer' as log;
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/notification/get_access_token.dart';
import 'package:test_app/notification/home_screen.dart';
import 'package:test_app/notification/profile_screen.dart';
import 'package:test_app/notification/send_notification.dart';
import 'package:http/http.dart' as http;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var permission = await Permission.notification.request();

  if (permission.isGranted) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
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
      body: Center(
        child: ElevatedButton(
          onPressed: 1 == 1
              ? _onButtonPressed
              : () async {
                  // sendNotification(); // Ensure this method is defined elsewhere
                },
          child: Text("Send Notification"),
        ),
      ),
    );
  }

  void _onButtonPressed() {
    try {
      // Code that may throw an exception
      throw Exception('Test Exception for Firebase Crashlytics');
    } catch (e, s) {
      // Log the exception
      FirebaseCrashlytics.instance.recordError(e, s);
      print("Error: $e");
    }
  }
}

Future<void> _showNotification({required RemoteMessage message}) async {
  String imageUrl = message.data['image'] ?? '';
  BigPictureStyleInformation? bigPictureStyleInformation;

  // Fetch the image from the URL
  if (imageUrl.isNotEmpty) {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        Uint8List imageData = response.bodyBytes;
        ByteArrayAndroidBitmap byteArrayAndroidBitmap = ByteArrayAndroidBitmap(imageData);
        bigPictureStyleInformation = BigPictureStyleInformation(
          byteArrayAndroidBitmap,
          largeIcon: byteArrayAndroidBitmap,
          contentTitle: message.notification?.title,
          summaryText: message.notification?.body,
        );
      }
    } catch (e) {
      print("Error downloading image: $e");
    }
  }

  // Android notification details with image
  AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    Random().nextDouble().toString(),
    'Test Channel',
    channelDescription: 'Test channel for notifications with image',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    ticker: 'ticker',
    styleInformation: bigPictureStyleInformation,
  );

  // iOS notification details (optional)
  DarwinNotificationDetails iOSNotificationDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  // Platform-specific notification details
  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidNotificationDetails,
    iOS: iOSNotificationDetails,
  );

  // Show the notification
  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? "Notification Title",
    message.notification?.body ?? "Notification Body",
    platformChannelSpecifics,
    payload: jsonEncode(message.data), // Include the payload for later use
  );
}

@pragma('vm:entry-point')
Future<void> _handleMessage(RemoteMessage message) async {
  if (message.notification != null) {
    await _showNotification(message: message);
  }
}

@pragma('vm:entry-point')
Future<void> _handleBgMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await registerNotificationListeners();
  await _showNotification(message: message);
}

Future<void> registerNotificationListeners() async {
  // Create notification channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Initialize settings
  var androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var iOSSettings = DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  var initSetttings = InitializationSettings(android: androidSettings, iOS: iOSSettings);
  await flutterLocalNotificationsPlugin.initialize(
    initSetttings,
    onDidReceiveNotificationResponse: (NotificationResponse payload) async {
      try {
        Map<String, dynamic> jsonMap = jsonDecode(payload.payload ?? "");
        await _handleNotificationTapFromPayload(jsonMap);
      } catch (e) {
        log.log("======================$e");
      }
    },
  );
}

Future<void> _handleNotificationTap(RemoteMessage message) async {
  String? screenType = message.data['screen_type'];
  await _navigateToScreen(screenType);
}

Future<void> _handleNotificationTapFromPayload(Map<String, dynamic> jsonMap) async {
  String? screenType = jsonMap["screen_type"];
  Future.delayed(Duration(seconds: 1), () async => await _navigateToScreen(screenType));
}

Future<void> _navigateToScreen(String? screenType) async {
  await Future.delayed(Duration(seconds: 1), () {
    if (screenType == "home") {
      Get.toNamed('/home');
    } else if (screenType == "profile") {
      Get.toNamed('/profile');
    }
  });
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
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}
