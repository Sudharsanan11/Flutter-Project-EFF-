
import 'dart:async';
import 'dart:convert';

import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_view/collection_assignment_view.dart';
import 'package:erpnext_logistics_mobile/doc_view/gdm_view.dart';
import 'package:erpnext_logistics_mobile/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin 
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true
      );

      // await Future.delayed(const Duration(seconds: 2));
    
    
    // final token = await _firebaseMessaging.getToken();

     String? token;
  int retries = 3;
  while (retries > 0 && token == null) {
   try {
      token = await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error fetching token: $e');
      retries--;
      if (retries > 0) {
        await Future.delayed(const Duration(seconds: 1)); // Retry delay
      }
    }
  }

    // await storeToken(token);
    final ApiService apiService = ApiService();

    await apiService.storetoken(token!);

    print(token);

  }

  static Future localNotiInit() async {

    const AndroidInitializationSettings 
        androidInitializationSettings = AndroidInitializationSettings(
          "@mipmap/ic_launcher");

    final DarwinInitializationSettings 
        darwinInitializationSettings = DarwinInitializationSettings(
          onDidReceiveLocalNotification: (id, title, body, payload) {});

    const LinuxInitializationSettings 
        linuxInitializationSettings = LinuxInitializationSettings(
          defaultActionName: "Open Notification");

    final InitializationSettings 
        initializationSettings = InitializationSettings(
          android: androidInitializationSettings,
          iOS: darwinInitializationSettings,
          linux: linuxInitializationSettings,
        );

        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

        _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap,);

     }
        static void onNotificationTap(NotificationResponse notificationResponse) {
          // navigatorKey.currentState?.push(
          //   MaterialPageRoute(builder: (context) => MyMessage(arguments: notificationResponse,),)
          // );
          manageNotification(notificationResponse);
          
        }

       static Future manageNotification(response) async{
          print("Manage notification");
          Map payload = {};
          if(response is RemoteMessage){
            payload = response.data;
          }

          if(response is NotificationResponse){
            payload = jsonDecode(response.payload!);
          }

          print(payload);
          print("oijoinubnklbhubhjnhgvuhjng uhjnguvhjkguvh");
          if(payload['doctype'] == "Collection Assignment"){
            print("if condition");
            navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => CollectionAssignmentView(name: payload['docname'])));
          }
          else if(payload['doctype'] == "GDM"){
            print("if condition");
            navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => GDMView(name: payload['docname'])));
          }
        }

        

        static Future showSimpleNotification({
            required title,
            required body,
            required payload,
          })async {
            const AndroidNotificationDetails androidNotificationDetails =
                AndroidNotificationDetails(
                  'channel_id',
                  'Channel Name',
                  channelDescription: '',
                  importance: Importance.max,
                  priority: Priority.high,
                  ticker: 'ticker');
          
            const NotificationDetails notificationDetails =
                NotificationDetails(
                  android: androidNotificationDetails,);

              await _flutterLocalNotificationsPlugin
              .show(0, title, body, notificationDetails, payload: payload);
          }


}
