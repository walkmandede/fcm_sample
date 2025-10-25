import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

const _fcmScope = 'https://www.googleapis.com/auth/firebase.messaging';

class FcmService {
  ServiceAccountCredentials? _creds;

  final String _serviceAccountPath = './config/firebase_service_account_key.json';

  Future<void> _ensureCredentialsLoaded() async {
    if (_creds != null) return;
    final file = File(_serviceAccountPath);
    if (!await file.exists()) {
      throw Exception('Service account JSON not found at $_serviceAccountPath');
    }
    final jsonStr = await file.readAsString();
    _creds = ServiceAccountCredentials.fromJson(jsonDecode(jsonStr));
  }

  Future<http.Client> _getAuthenticatedClient() async {
    await _ensureCredentialsLoaded();
    final client = await clientViaServiceAccount(_creds!, [_fcmScope]);
    return client;
  }

  Future<String> _projectId() async {
    await _ensureCredentialsLoaded();
    final jsonStr = await File(_serviceAccountPath).readAsString();
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    final projectId = map['project_id'] as String?;
    if (projectId == null) throw Exception('$projectId not found in service account json');
    return projectId;
  }

  Future<http.Response> sendToDevice({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    final client = await _getAuthenticatedClient();
    final projectId = await _projectId();
    final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

    final Map<String, dynamic> payload = {
      'message': {
        'token': token,
        "notification": {
          "body": body,
          "title": title,
        },
        if (data != null && data.isNotEmpty) 'data': data,
      }
    };

    final resp = await client.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(payload),
    );

    client.close();
    return resp;
  }
}
