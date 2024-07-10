import 'package:flutter/material.dart';


class DateField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  
  DateField({super.key,
  required this.controller,
  required this.labelText,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 3.0
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          fillColor: Colors.white,
          filled: true,
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}