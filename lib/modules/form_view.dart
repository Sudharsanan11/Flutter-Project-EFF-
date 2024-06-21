import "package:flutter/material.dart";



class FormView extends StatelessWidget {
  final String itemName;

  FormView({required this.itemName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(itemName),
      ),
    );
  }
}