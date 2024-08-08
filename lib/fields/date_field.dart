import 'package:flutter/material.dart';


class DateField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  
  const DateField({super.key,
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
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(12.0),
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