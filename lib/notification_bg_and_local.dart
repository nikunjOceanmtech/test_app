import 'dart:convert';
import 'dart:math';
import 'dart:developer' as log;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:test_app/channel.dart';
import 'package:test_app/firebase_options.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/notification/app_open_working_code.dart';

Future<void> showNotification({required RemoteMessage message}) async {
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
Future<void> handleMessage(RemoteMessage message) async {
  if (message.notification != null) {
    // customNotificationData = message;
    showNotificationPopup(message);
    // await showNotification(message: message);
  }
}

@pragma('vm:entry-point')
Future<void> handleBgMessage(RemoteMessage message) async {
  // await _showNotification(message: message);
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await registerNotificationListeners();

  showNotificationPopup(message);
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
        await handleNotificationTapFromPayload(jsonMap);
      } catch (e) {
        log.log("======================$e");
      }
    },
  );
}

Future<void> handleNotificationTap(RemoteMessage message) async {
  String? screenType = message.data['screen_type'];
  await navigateToScreen(screenType);
}

Future<void> handleNotificationTapFromPayload(Map<String, dynamic> jsonMap) async {
  String? screenType = jsonMap["screen_type"];
  Future.delayed(Duration(seconds: 1), () async => await navigateToScreen(screenType));
}

Future<void> navigateToScreen(String? screenType) async {
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

Future<void> requestNotificationPermissions() async {
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
