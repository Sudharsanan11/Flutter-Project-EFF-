import 'package:flutter/material.dart';

class ListView extends StatefulWidget {
  const ListView({super.key});

  @override
  State<ListView> createState() => _ListViewState();
}

class _ListViewState extends State<ListView> {
  final String title = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
      ),
      drawer: const Drawer(
        backgroundColor: Colors.white,
      ),
    );
  }
}