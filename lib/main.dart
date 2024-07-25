import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'api_endpoints.dart';
import 'package:erpnext_logistics_mobile/fields/theme_provider.dart';

Future<void> main() async {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const EFF(),
        );
      },
    );
  }
}

class EFF extends StatefulWidget {
  const EFF({super.key});
  @override
  State<EFF> createState() => _EFFState();
}

class _EFFState extends State<EFF> {
  String value = "";

  Future<void> _apicall() async {
    final ApiService apiService = ApiService();
    print("apicall");
    print(apiService);
    try {
      final response = await apiService.getresources(ApiEndpoints.authEndpoints.employee);
      print(response);
      setState(() {
        value = response.toString();
      });
    } catch (e) {
      print("exception");
      print(e);
      setState(() {
        value = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        elevation: 5.0,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: _apicall, child: const Text("eff")),
            Text(value),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}
