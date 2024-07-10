import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:flutter/material.dart';

class CollectionAssignmentForm extends StatefulWidget {
  const CollectionAssignmentForm({super.key});

  @override
  State<CollectionAssignmentForm> createState() => _CollectionAssignmentFormState();
}

class _CollectionAssignmentFormState extends State<CollectionAssignmentForm> {

  final TextEditingController entered_by = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Collection Assignment Form"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            FieldText(
              controller: entered_by,
              labelText: "Entered By",
              obscureText: false,
              keyboardType: TextInputType.none)
          ],
          ),
      ),
    );
  }
}