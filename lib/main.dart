import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State {
  final scaffoldState = GlobalKey();
  final firebaseMessaging = FirebaseMessaging();
  final controllerTopic = TextEditingController();
  bool isSubscribed = false;
  String token = '';

  static Future onBackgroundMessage(Map message) {
    print('onBackgroundMessage: $message');
    return null;
  }

  @override
  void initState() {
    firebaseMessaging.configure(
      onMessage: (Map message) async {
        print('onMessage: $message');
      },
      onBackgroundMessage: onBackgroundMessage,
      onResume: (Map message) async {
        print('onResume: $message');
      },
      onLaunch: (Map message) async {
        print('onLaunch: $message');
      },
    );
    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: true),
    );
    firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      debugPrint('Settings registered: $settings');
    });
    firebaseMessaging.getToken().then((token) => setState(() {
          this.token = token;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('token: $token');
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        title: Text('Flutter Test FCM'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'TOKEN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(token),
            Divider(thickness: 1),
            Text(
              'TOPIC',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: controllerTopic,
              enabled: !isSubscribed,
              decoration: InputDecoration(
                hintText: 'Enter a topic',
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RaisedButton(
                    child: Text('Subscribe'),
                    onPressed: isSubscribed
                        ? null
                        : () {
                            String topic = controllerTopic.text;
                            if (topic.isEmpty) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Topic invalid'),
                              ));

                              return;
                            }
                            firebaseMessaging.subscribeToTopic(topic);
                            setState(() {
                              isSubscribed = true;
                            });
                          },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: RaisedButton(
                    child: Text('Unsubscribe'),
                    onPressed: !isSubscribed
                        ? null
                        : () {
                            String topic = controllerTopic.text;
                            firebaseMessaging.unsubscribeFromTopic(topic);
                            setState(() {
                              isSubscribed = false;
                            });
                          },
                  ),
                ),
              ],
            ),
            Divider(thickness: 1),
          ],
        ),
      ),
    );
  }
}
