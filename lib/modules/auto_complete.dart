import 'package:flutter/material.dart';

class AutoComplete extends StatelessWidget {
  final List<String> options;
  final String hintText;
  final ValueChanged<String> onSelected;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  const AutoComplete({
    super.key,
    required this.options,
    required this.hintText,
    required this.onSelected,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: onSelected,
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        textEditingController.text = controller.text;
        
        textEditingController.addListener(() {
          controller.text = textEditingController.text;
        });
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 27.0),
          child: TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            onFieldSubmitted: (String value) {
              onFieldSubmitted();
            },
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
              fillColor: isDarkMode ? Colors.black54 : Colors.white,
              filled: true,
              labelText: hintText,
              labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey[600]),
            ),
          ),
        );
      },
    );
  }
}
