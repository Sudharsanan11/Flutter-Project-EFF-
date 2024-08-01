import 'package:flutter/material.dart';

class FieldText extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final bool readOnly;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const FieldText({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.readOnly = false,
    required this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 3.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: isDarkMode ? Colors.white : Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: isDarkMode ? Colors.white : Colors.black),
          ),
          fillColor: isDarkMode ? Colors.black : Colors.white,
          filled: true,
          labelText: labelText,
          labelStyle:
              TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[600]),
        ),
      ),
    );
  }
}
