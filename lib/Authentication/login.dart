import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/toast.dart';
import 'package:flutter/material.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erpnext_logistics_mobile/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> signUserIn(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final String username = usernameController.text;
      final String password = passwordController.text;

      final String url =
          ApiEndpoints.baseUrl + ApiEndpoints.authEndpoints.loginEmail;

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'usr': username,
            'pwd': password,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          const ToastComponent(message: "Login successful");
          Fluttertoast.showToast(
            msg: "Logedin successfully",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,);
          print('Login successful: $responseData');

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('api', responseData['message']['api_key']);
          prefs.setString('secret', responseData['message']['api_secret']);
          prefs.setString('full_name', responseData['message']['full_name']);
          prefs.setString('email', responseData['message']['email']);

          print('Session token: ${prefs.getString('api')}');
          print('Session token: ${prefs.getString('secret')}');
          print('Full Name: ${prefs.getString('full_name')}');
          print('email ${prefs.getString('email')}');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EFF()),
          );
        } else {
          const ToastComponent(message: "Invalid credentials");
          print('Login failed: ${response.body}');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<String?> getSessionToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Icon(
                    Icons.lock,
                    size: 100,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    "Welcome to EFF!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 3.0),
                    child: TextFormField(
                      controller: usernameController,
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        labelText: 'Username',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 3.0),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  MyButton(
                    name: 'Sign In',
                    onTap: () => signUserIn(context),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a user?',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      TextButton(
                        child: const Text("Register Now", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                        onPressed: () {
                          // Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 4),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

