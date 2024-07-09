import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/drop_down.dart';
import 'package:erpnext_logistics_mobile/modules/barcode_scanner.dart';
import 'package:erpnext_logistics_mobile/fields/dotted_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';

class LrForm extends StatefulWidget {
  const LrForm({super.key});

  @override
  State<LrForm> createState() => _LrFormState();
}

class _LrFormState extends State<LrForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController consignor = TextEditingController();
  final TextEditingController consignee = TextEditingController();
  final TextEditingController destination = TextEditingController();
  final TextEditingController boxCount = TextEditingController();
  final TextEditingController boxMismatchFromOrder = TextEditingController();
  final TextEditingController boxMismatchOnRescan = TextEditingController();
  final TextEditingController freight = TextEditingController();
  final TextEditingController lrCharge = TextEditingController();
  final TextEditingController totalFreight = TextEditingController();
  final TextEditingController boxDelivered = TextEditingController();
  final TextEditingController totalItems = TextEditingController();
  final TextEditingController itemName = TextEditingController();
  final TextEditingController itemWeight = TextEditingController();
  final TextEditingController itemVolume = TextEditingController();
  final TextEditingController itemBarcode = TextEditingController();

  String? selectedLrType;
  List<Map<String, String>> items = [];

  void submitData() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      // Form is valid, proceed with submission logic
      print(_formKey.currentState?.value);
    } else {
      // Form is invalid, display validation errors
      print("Validation failed");
    }
  }

  void addItem() {
    setState(() {
      items.add({
        'name': itemName.text,
        'weight': itemWeight.text,
        'volume': itemVolume.text,
        'barcode': itemBarcode.text,
      });
      itemName.clear();
      itemWeight.clear();
      itemVolume.clear();
      itemBarcode.clear();
    });
  }

  void _showItemForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Item Details'),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      LoginText(
                        controller: itemName,
                        labelText: 'Item Name',
                        obscureText: false,
                      ),
                      const SizedBox(height: 15),
                      LoginText(
                        controller: itemWeight,
                        labelText: 'Weight',
                        obscureText: false,
                      ),
                      const SizedBox(height: 15),
                      LoginText(
                        controller: itemVolume,
                        labelText: 'Volume',
                        obscureText: false,
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () => const BarcodeScanner(),
                        child: AbsorbPointer(
                          child: LoginText(
                            controller: itemBarcode,
                            labelText: 'Barcode',
                            obscureText: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MyButton(
                            onTap: () {
                              addItem();
                              setState(() {}); // Ensure the dialog updates
                            },
                            name: 'Add Item',
                          ),
                          MyButton(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            name: 'Save Items',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LR Form'),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 5),
                  DropDown(
                    labelText: 'LR Type',
                    items: const [
                      'By Collection Request',
                      'By Log Sheet',
                      'By Manual'
                    ],
                    selectedItem: selectedLrType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLrType = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  LoginText(
                    controller: consignor,
                    labelText: 'Consignor Name',
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  LoginText(
                    controller: consignee,
                    labelText: 'Consignee Name',
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  LoginText(
                    controller: destination,
                    labelText: 'Destination',
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: LoginText(
                          controller: boxMismatchFromOrder,
                          labelText: 'Box Mismatch from order',
                          obscureText: false,
                        ),
                      ),
                      const SizedBox(width: 1),
                      Flexible(
                        flex: 1,
                        child: LoginText(
                          controller: boxMismatchOnRescan,
                          labelText: 'Box mismatch on rescan',
                          obscureText: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: LoginText(
                          controller: boxCount,
                          labelText: 'Box Count',
                          obscureText: false,
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: LoginText(
                          controller: boxDelivered,
                          labelText: 'Box Delivered',
                          obscureText: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  LoginText(
                    controller: freight,
                    labelText: 'Freight',
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  LoginText(
                    controller: lrCharge,
                    labelText: 'LR Charge',
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  LoginText(
                    controller: totalFreight,
                    labelText: 'Total Freight',
                    obscureText: false,
                    readOnly: true,
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: () => _showItemForm(context),
                    child: const AbsorbPointer(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 3.0),
                        child: DottedInput(
                          labelText: 'Items',
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Items',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16.0,
                                ),
                              ),
                              SizedBox(height: 2),
                              Icon(
                                Icons.add,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  if (items.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Name: ${item['name']}'),
                                  Text('Weight: ${item['weight']}'),
                                  Text('Volume: ${item['volume']}'),
                                  Text('Barcode: ${item['barcode']}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 25),
                    MyButton(onTap: submitData, name: 'Submit'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
