import 'package:flutter/material.dart';

class TextArea extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final bool readOnly;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const TextArea({
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
        minLines: 1,
        maxLines: 10,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: isDarkMode ? Colors.white : Colors.black),
            borderRadius: BorderRadius.circular(12.0),            
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
