import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyMessage extends StatefulWidget {
  final arguments;
  const MyMessage({super.key, required this.arguments});

  @override
  State<MyMessage> createState() => _MyMessageState();
}

class _MyMessageState extends State<MyMessage> {
  Map payload = {};
  @override
  Widget build(BuildContext context) {

    // final data = ModalRoute.of(context)!.settings.arguments;
    final data = widget.arguments;

    if (data is RemoteMessage){
      payload = data.data;
    }
  
    if(data is NotificationResponse){
      payload = jsonDecode(data.payload!);
    }
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(payload.toString()),),
    );
  }
}