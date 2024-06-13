import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:marcci/auth/BoardingWelcomeScreen.dart';
import 'package:marcci/models/FarmModel.dart';
import 'package:marcci/screens/OnBoardingScreen.dart';
import 'package:marcci/theme/app_theme.dart';
import 'package:marcci/utils/AppConfig.dart';
import 'package:marcci/utils/Utils.dart';

// Setup for local notifications
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Boot system
  Utils.boot_system();
  Utils.init_databse();
  Utils.init_theme();

  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
  periodicConnectivityCheck();
}

void periodicConnectivityCheck() {
  Timer.periodic(Duration(minutes: 1), (Timer t) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      print("Device is online, attempting to sync...");
      // Function to submit online data goes here
      await FarmModel.syncLocalDataToServer();
    } else {
      print("Device is offline.");
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppTheme.init();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: OnBoardingScreen(),
      routes: {
        '/OnBoardingScreen': (context) => OnBoardingScreen(),
        AppConfig.FullApp: (context) => BoardingWelcomeScreen(),
      },
    );
  }
}

Future<void> showNotification(String title, String body) async {
  var androidDetails = AndroidNotificationDetails(
    'channelId',
    'channelDescription',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: false,
  );
  var platformDetails = NotificationDetails(android: androidDetails);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformDetails,
    payload: 'Default_Sound',
  );
}

class GlobalMaterialLocalizations {}
