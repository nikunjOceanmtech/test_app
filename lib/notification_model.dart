import 'package:shared_preferences/shared_preferences.dart';

class NotificationModel {
  final String nTitle;
  final String nBody;
  final String nImage;

  NotificationModel({
    required this.nTitle,
    required this.nBody,
    required this.nImage,
  });

  factory NotificationModel.fromJson(dynamic json) => NotificationModel(
        nTitle: json["title"],
        nBody: json["body"],
        nImage: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "title": nTitle,
        "body": nBody,
        "image": nImage,
      };
}

String sharedKey = "notification";

Future<void> setNotificationData({required String data}) async {
  List<String> finalDataList = [];
  SharedPreferences preferences = await SharedPreferences.getInstance();
  List<String> list = await getNotificationData();

  if (list.isEmpty) {
    finalDataList.add(data);
  } else {
    finalDataList.addAll(list);
    finalDataList.add(data);
  }
  preferences.setStringList(sharedKey, finalDataList);
}

Future<List<String>> getNotificationData() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  List<String> list = preferences.getStringList(sharedKey) ?? [];
  return list;
}

List<String> listOfNotification = [];
