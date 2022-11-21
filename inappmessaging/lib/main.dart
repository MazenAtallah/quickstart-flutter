// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: (context, child) => const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Firebase In App Messaging'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const Image(
                image: AssetImage('assets/fiam_horizontal_lockup_light.png')),
            const Text(
              'Welcome to the Firebase In-App Messaging Quickstart app. Press the button to trigger an analytics event!',
            ),
            const Text(
              'You may need to background and then re-foreground the app after a fresh install.',
            ),
            Consumer<ApplicationState>(
              builder: (context, appState, _) =>
                  Text('Firebase Installation ID: ${appState.installationId}'),
            ),
            Consumer<ApplicationState>(
              builder: (context, appState, _) => ElevatedButton(
                onPressed: () => appState.logEvent('engagement_party'),
                child: const Text("Trigger 'engagement_party' event"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  late FirebaseAnalytics analytics;
  late FirebaseInAppMessaging firebaseIam;

  String _installationId = "";
  String get installationId => _installationId;

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    analytics = FirebaseAnalytics.instance;
    firebaseIam = FirebaseInAppMessaging.instance;

    await firebaseIam.setAutomaticDataCollectionEnabled(true);
    await firebaseIam.setMessagesSuppressed(false);

    FirebaseInstallations.instance.getId().then((id) {
      _installationId = id;
      debugPrint('Firebase installation id: $id');
      notifyListeners();
    });
  }

  Future<void> logEvent(eventName) async {
    debugPrint('logging event');
    await analytics.logEvent(name: eventName);
    debugPrint('event logged');
  }
}
