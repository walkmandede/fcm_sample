import 'dart:developer';
import 'package:fcm_sample_client/fcm_sample_client.dart';
import 'package:fcm_sample_flutter/fcm_service/fcm_service.dart';
import 'package:fcm_sample_flutter/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

late final Client client;

late String serverUrl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
  final serverUrl = serverUrlFromEnv.isEmpty ? 'http://$localhost:8080/' : serverUrlFromEnv;

  client = Client(serverUrl)..connectivityMonitor = FlutterConnectivityMonitor();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serverpod Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _txtFcmToken = TextEditingController(text: '');
  final TextEditingController _txtApnsKey = TextEditingController(text: '');
  final TextEditingController _txtSendTo = TextEditingController(text: '');
  final TextEditingController _txtTitle = TextEditingController(text: '');
  final TextEditingController _txtBody = TextEditingController(text: '');

  @override
  void initState() {
    fcmService.initialize().then((_) {
      _txtFcmToken.text = fcmService.fcmToken ?? '';
      _txtApnsKey.text = fcmService.apnsToken ?? '';
      _txtSendTo.text = fcmService.fcmToken ?? '';
      _txtTitle.text = 'Hello';
      _txtBody.text = 'Sending message form flutter';
    });

    super.initState();
  }

  Future<void> _sendMessage() async {
    log('Start sending fcm messge');
    await Future.delayed(const Duration(seconds: 3));
    await client.notifications.sendToDevice(_txtSendTo.text, _txtTitle.text, _txtBody.text);
    log('End sending fcm messge');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Divider(),
                TextField(
                  controller: _txtFcmToken,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Device FCM token',
                  ),
                ),
                TextField(
                  controller: _txtApnsKey,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'APNs key',
                  ),
                ),
                const Divider(),
                TextField(
                  controller: _txtSendTo,
                  decoration: InputDecoration(
                    labelText: 'Send To',
                  ),
                ),
                TextField(
                  controller: _txtTitle,
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                TextField(
                  controller: _txtBody,
                  readOnly: false,
                  decoration: InputDecoration(
                    labelText: 'Body',
                  ),
                ),
                FilledButton(
                  onPressed: _sendMessage,
                  child: Text('Send Message'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
