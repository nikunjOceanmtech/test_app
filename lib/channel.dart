import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

Future<void> showNotificationPopup(RemoteMessage message) async {
  bool hasPermission = await FlutterOverlayWindow.isPermissionGranted();
  if (!hasPermission) {
    bool granted = await FlutterOverlayWindow.requestPermission() ?? false;
    if (!granted) {
      await showNotificationPopup(message);
      return;
    }
  }

  if (await FlutterOverlayWindow.isActive()) return;
  print("=========================");
  await FlutterOverlayWindow.showOverlay(
    enableDrag: false,
    overlayTitle: message.notification?.title ?? "",
    overlayContent: message.notification?.body ?? "",
    flag: OverlayFlag.defaultFlag,
    positionGravity: PositionGravity.auto,
    height: 400,
    width: WindowSize.matchParent,
    startPosition: const OverlayPosition(0, -200),
  );
}
