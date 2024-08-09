import 'dart:ffi';

import 'package:erpnext_logistics_mobile/Authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erpnext_logistics_mobile/fields/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation_bar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String name = "";
  final String? imageUrl = null;

  @override
  void initState() {
    super.initState();
    setFullName();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setFullName() async{
  SharedPreferences manager = await SharedPreferences.getInstance();
    if (manager.containsKey('full_name')) {
      setState(() {
      name = manager.getString('full_name')!;
      });
    }
  }

  Future<void> logout () async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    manager.clear();
  }

  String getInitials(String name) {
    List<String> nameParts = name.split(" ");
    String initials = "";
    for (var part in nameParts) {
      initials += part[0];
    }
    return initials;
  }

  Future<void> _confirmSignOut() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            'LOGOUT!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to sign out?'),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                        ),
                      ),
                    ),
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                    ),
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      logout();
                      // Add your sign-out logic here
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            imageUrl != null ? AssetImage(imageUrl!) : null,
                        child: imageUrl == null
                            ? Text(
                                getInitials(name),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Settings section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.dark_mode,
                      title: 'Dark mode',
                      subtitle: 'Automatic',
                      trailing: Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return Switch(
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                            },
                          );
                        },
                      ),
                      onTap: () {},
                    ),
                    _buildSettingsTile(
                      icon: Icons.info,
                      title: 'About',
                      subtitle: 'Learn more about EFF Logistics',
                      onTap: () {
                        // Handle tap
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.feedback,
                      title: 'Send Feedback',
                      subtitle: 'Let us know how we can make EFF App better',
                      onTap: () {
                        // Handle tap
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Account section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSettingsTile(
                      icon: Icons.exit_to_app,
                      title: 'Sign Out',
                      onTap: _confirmSignOut,
                    ),
                    _buildSettingsTile(
                      icon: Icons.email,
                      title: 'Change email',
                      onTap: () {
                        // Handle tap
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required void Function() onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
