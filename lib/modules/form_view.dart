import "package:flutter/material.dart";



class FormView extends StatelessWidget {
  final String itemName;

  const FormView({super.key, required this.itemName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(itemName),
      ),
    );
  }
}