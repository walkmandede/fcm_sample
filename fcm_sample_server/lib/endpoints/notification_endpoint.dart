import 'package:serverpod/serverpod.dart';
import '../services/fcm_service.dart';

class NotificationsEndpoint extends Endpoint {
  /// Send push to a single device token (admin or authorized callers)
  Future<String> sendToDevice(Session session, String token, String title, String body) async {
    late final FcmService fcmService = FcmService('./config/fcm-test-c966f-firebase-adminsdk-fbsvc-9ae6c38743.json');

    final resp = await fcmService.sendToDevice(token: token, title: title, body: body, data: {
      'title': title,
    });
    if (resp.statusCode == 200) {
      print(resp.body);
      return 'ok';
    } else {
      // Log body for debugging; could parse error to remove invalid tokens
      session.log('FCM send failed: ${resp.statusCode} ${resp.body}');
      throw Exception(resp.body);
    }
  }
}
