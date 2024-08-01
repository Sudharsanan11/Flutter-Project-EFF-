import 'package:flutter/material.dart';

class DropDown extends StatelessWidget {
  final String labelText;
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?> onChanged;

  const DropDown({
    super.key,
    required this.labelText,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 3.0),
        child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDarkMode ? Colors.white : Colors.grey,
            ),
          ),
          fillColor: isDarkMode ? Colors.black54 : Colors.white,
          filled: true,
          labelText: labelText,
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: isDarkMode ? Colors.black54 : Colors.white,
        value: selectedItem,
      ),
      //  child: DropdownButton(
      //   hint: Text(labelText),
      //   dropdownColor: Colors.white,
      //   items: items.map((String valueItem){
      //     return DropdownMenuItem<String>(
      //       value: valueItem,
      //       child: Text(valueItem),
      //     );
      //   }).toList(),
      //   onChanged: (String? newValue) {
      //     onChanged(newValue as String?);
      //     controller.text = newValue ?? "";
      //   },
        // underline: SizedBox(),
      //   style: const TextStyle(color: Colors.black),
      //   value: controller,
      //   icon: const Icon(Icons.arrow_drop_down),
      //  ),
    );
  }
}
