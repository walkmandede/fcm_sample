import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final data = message.data;
  log(data.toString(), name: 'FCMBG');
}

class FcmService {
  String? fcmToken;
  String? apnsToken;

  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    //requesting notification permission
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await _updateAPNStoken();
    await _updateFCMToken();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //TODO: implement in-app messgage display
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      //TODO: implement bloc when user tap the noti and enter the app
    });
  }

  Future<void> _updateAPNStoken() async {
    apnsToken = await _firebaseMessaging.getAPNSToken();
    if (apnsToken != null) {
      log(apnsToken.toString(), name: 'APNS');
    }
  }

  Future<void> _updateFCMToken() async {
    fcmToken = await _firebaseMessaging.getToken();
  }
}
