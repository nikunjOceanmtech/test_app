import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:test_app/notification/get_access_token.dart';

Future<void> sendNotification() async {
  const url = 'https://fcm.googleapis.com/v1/projects/test-project-dc65a/messages:send';
  var token = await GetAccessToken.getAccessToken();

  final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};

  final body = json.encode({
    "message": {
      "token": await FirebaseMessaging.instance.getToken(),
      "data": {
        "screen_type": "home",
      },
      "notification": {
        "body": "Test Notification",
        "title": "Test Notification",
        "image": "https://img001.prntscr.com/file/img001/KuLS3AZRR6GrSmrPXwkl6w.png",
      },
    },
  });

  try {
    http.post(Uri.parse(url), headers: headers, body: body);
  } catch (e) {
    print('Error occurred: $e');
  }
}
