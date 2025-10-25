import 'package:serverpod/serverpod.dart';
import '../services/fcm_service.dart';

class NotificationsEndpoint extends Endpoint {
  Future<String> sendToDevice(Session session, String token, String title, String body) async {
    late final FcmService fcmService = FcmService('./config/firebase_service_account_key.json');

    final resp = await fcmService.sendToDevice(token: token, title: title, body: body, data: {
      'title': title,
    });
    return resp.body;
  }
}
