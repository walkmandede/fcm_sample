import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final data = message.data;
  log(data.toString(), name: 'FCMBG');
}

FcmService fcmService = FcmService();

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

    apnsToken = await _firebaseMessaging.getAPNSToken();
    if (apnsToken != null) {
      log(apnsToken.toString(), name: 'APNS');
    }

    await _updateToken();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //TODO: implement in-app messgage display
      log('Got a FCM message');
      log(message.toMap().toString());
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("Notification tap from background: ${message.data}");
    });
  }

  Future<void> _updateToken() async {
    final String? vapidKey = kIsWeb ? 'web vapid key' : null;
    fcmToken = await _firebaseMessaging.getToken(vapidKey: vapidKey);
    log(fcmToken.toString(), name: 'FCM');
  }
}
