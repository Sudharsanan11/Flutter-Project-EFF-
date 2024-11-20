import 'dart:convert';

import 'package:erpnext_logistics_mobile/Authentication/login.dart';
import 'package:erpnext_logistics_mobile/doc_list/lr_list.dart';
import 'package:erpnext_logistics_mobile/home.dart';
import 'package:erpnext_logistics_mobile/message.dart';
import 'package:erpnext_logistics_mobile/push_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future _firebaseBackgroundMessage(RemoteMessage message) async{
  print(message);
  if(message.notification != null){
    print("Some notification Received: ");
  }
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences manager = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);


FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // print('Received a message while in the foreground: ${message.messageId}');
  // print(message.from);
  // print(message.data);
  // print(message.notification!.android);
  // print(message.notification!.title.toString());
  // print(message.notification!.body.toString());
  // print(message.notification!..toString());
  // if (message.notification != null) {
  //   print('Message also contained a notification: ${message.notification!.title.toString()}');
  // }
  String payloadData = jsonEncode(message.data);
  if (message.notification != null) {
    PushNotifications.showSimpleNotification(title: message.notification!.title, body: message.notification!.body, payload: payloadData);
  }
});

final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();

      if (message!= null) {
        Future.delayed(const Duration(seconds: 1), () {
          navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (context) => const LRList())
          );
        });
      }

// FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//   if (message.notification != null){
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (context) => MyMessage(arguments: message))
//     );
//   }
// });

  var api = manager.getString("sid");
  var cookies = manager.getString("cookies");
  
  bool isLoggedIn = api != null ? true : false;
  runApp(
    ProviderScope(
      // create: (_) => ThemeProvider(),
      // child: api == null ? const LoginPage() : const EFF(),
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
  // runApp(api == null ? const LoginPage() : const EFF(),);
  // runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
   const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {

    // return Consumer<ThemeProvider>(
    //   builder: (context, themeProvider, child){
    //     return MaterialApp(
    //       theme: ThemeData.light(),
    //       darkTheme: ThemeData.dark(),
    //       themeMode:
    //           themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    //       home: isLoggedIn ? const EFF() : const LoginPage(),
    //     );
    //   },
    // );
    return MaterialApp(
      title: "EFF",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey)
        // colorScheme: ColorScheme.ligh)
      ),
      navigatorKey: navigatorKey,
      home: isLoggedIn ? const EFF() : const LoginPage(),
    );
  }
}

