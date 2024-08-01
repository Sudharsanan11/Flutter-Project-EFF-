import 'package:flutter/material.dart';

class DropDown extends StatelessWidget {
  final String labelText;
  final List<String> items;
  final dynamic selectedItem;
  final TextEditingController controller;
  final ValueChanged<String?> onChanged;

  const DropDown({
    super.key,
    required this.labelText,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 3.0),
        child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          fillColor: Colors.white,
          filled: true,
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        // value: controller.text,
        dropdownColor: Colors.white,
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
