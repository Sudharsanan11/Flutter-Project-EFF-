import 'package:flutter/material.dart';

class MultiSelect extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onSelectedItemsListChanged;

  const MultiSelect({
    required this.items,
    required this.selectedItems,
    required this.onSelectedItemsListChanged,
    super.key,
  });

  @override
  _MultiSelectState createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  late List<String> _tempSelectedItems;

  @override
  void initState() {
    super.initState();
    _tempSelectedItems = List.from(widget.selectedItems); // Use List.from to avoid modifying the original list
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.items
          .map((staff) => CheckboxListTile(
                title: Text(staff),
                value: _tempSelectedItems.contains(staff),
                onChanged: (bool? checked) {
                  setState(() {
                    if (checked == true) {
                      _tempSelectedItems.add(staff);
                    } else {
                      _tempSelectedItems.remove(staff);
                    }
                    widget.onSelectedItemsListChanged(_tempSelectedItems);
                  });
                },
              ))
          .toList(),
    );
  }
}
