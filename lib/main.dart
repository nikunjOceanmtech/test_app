import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/notification/get_access_token.dart';
import 'package:test_app/notification/home_screen.dart';
import 'package:test_app/notification/profile_screen.dart';
import 'package:test_app/notification/send_notification.dart';
import 'package:test_app/notification_bg_and_local.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var permission = await Permission.notification.request();

  if (permission.isGranted) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    print("=========================${await FirebaseMessaging.instance.getToken()}");
    print("=========================${await GetAccessToken.getAccessToken()}");

    requestNotificationPermissions();
    registerNotificationListeners();

    FirebaseMessaging.onBackgroundMessage(handleBgMessage);
    FirebaseMessaging.onMessage.listen(handleMessage);

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationTap(initialMessage);
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
          onPressed: 1 != 1
              ? _onButtonPressed
              : () async {
                  sendNotification();
                },
          child: Text("Send Notification"),
        ),
      ),
    );
  }

  void _onButtonPressed() {
    try {
      throw Exception('Test Exception for Firebase Crashlytics');
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      print("Error: $e");
    }
  }
}
