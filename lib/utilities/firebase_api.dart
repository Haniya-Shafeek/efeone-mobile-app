import 'package:efeone_mobile/view/Group%20Chat/chat_screen.dart';
import 'package:efeone_mobile/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fCMToken");

    // Initialize notifications
    initPushNotifications();
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    // Handle navigation from notification
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => GroupChatScreen(),
    ));
  }

  Future<void> initPushNotifications() async {
    // Handle notifications when the app is in the terminated state
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // Handle notifications when the app is in the background or opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // Handle notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print('Foreground notification: ${message.notification?.title}');
      }
    });
  }

  // Register background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // This handler will be called when the app is in the background or terminated
    print('Handling a background message: ${message.messageId}');
    // Perform any background tasks here if needed (e.g., show notification)
  }
}
