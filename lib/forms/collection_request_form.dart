import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:flutter/material.dart';



class CollectionRequestForm extends StatefulWidget {
  const CollectionRequestForm({super.key});
  

  @override
  State<CollectionRequestForm> createState() => _CollectionRequestFormState();
}

class _CollectionRequestFormState extends State<CollectionRequestForm> {

  final TextEditingController consignor = TextEditingController();
  final TextEditingController consignorName = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Request'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Textfield(
              controller: consignor,
              hintText: "Consignor",
              obscureText: false,
              keyboardType: TextInputType.text
            ),
            const SizedBox(height: 10.0,),
            Textfield(
              controller: consignor,
              hintText: "Consignor",
              obscureText: false,
              keyboardType: TextInputType.text
            ),
          ],
        ),
      ),
    );
  }
}