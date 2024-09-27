import 'package:erpnext_logistics_mobile/Authentication/login.dart';
import 'package:erpnext_logistics_mobile/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences manager = await SharedPreferences.getInstance();
  var api = manager.getString("api");
  
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
      home: isLoggedIn ? const EFF() : const LoginPage(),
    );
  }
}

