import 'package:flutter/material.dart';

class DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final bool readOnly;
  final TextInputType keyboardType;

  const DialogTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.readOnly = false,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          fillColor: isDarkMode ? Colors.black54 : Colors.white,
          filled: true,
          labelText: labelText,
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
