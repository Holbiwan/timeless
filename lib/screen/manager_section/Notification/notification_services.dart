import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static Map<String, dynamic> noti = {};

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: android.smallIcon,
            ),
          ),
          payload: jsonEncode(message.data),
        );

        noti = {
          "title": notification.title,
          "body": notification.body,
        };
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await Firebase.initializeApp();
    });

    await FirebaseMessaging.instance.getInitialMessage();
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
  }

  static Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // ✅ Méthode conforme attendue dans le controller
  static Future<String?> getFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      return token;
    } catch (e) {
      print('Erreur lors de la récupération du FCM Token : $e');
      return null;
    }
  }

  static const String serverToken =
      'AAAAmOaKNCQ:APA91bFqbgmjl8dlMHvZpfArI9ekY8dg9NSg7kqOzunggtGggN_kJcq8HalG7VD5J4MpkEu3Mq5H0F7vmugPHC_k8hCbe0GqdBeZA6lwlms4m2NiFJFHD-noCYmN3QuoBvcx8EQlfuhI';

  static Future<void> sendNotification(
      SendNotificationModel notification) async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(notification.toMap()),
    );
  }
}

class SendNotificationModel {
  String? id;
  String? chatId;
  String? title;
  String? body;
  List<String>? fcmTokens;

  SendNotificationModel({
    this.chatId,
    this.title,
    this.body,
    this.id,
    this.fcmTokens,
  });

  Map<String, dynamic> toMap() => {
        "registration_ids": fcmTokens,
        "data": {
          "id": id,
          "chatId": chatId,
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "sound": "default",
        },
        "priority": "high",
        "notification": {
          "title": title,
          "body": body,
        }
      };
}
