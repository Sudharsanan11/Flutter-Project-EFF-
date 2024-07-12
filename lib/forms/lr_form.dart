import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/drop_down.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/modules/barcode_scanner.dart';
import 'package:erpnext_logistics_mobile/fields/dotted_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
      print(_formKey.currentState?.value);
    } else {
      print("Validation failed");
    }
  }

  void _openBarcodeScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScanner(
          onScanResult: (scanResult) {
            setState(() {
              itemBarcode.text = scanResult;
            });
          },
        ),
      ),
    );
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
                      FieldText(
                        controller: itemName,
                        labelText: 'Item Name',
                        obscureText: false,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 15),
                      FieldText(
                          controller: itemWeight,
                          labelText: 'Weight',
                          obscureText: false,
                          keyboardType: TextInputType.name),
                      const SizedBox(height: 15),
                      FieldText(
                          controller: itemVolume,
                          labelText: 'Volume',
                          obscureText: false,
                          keyboardType: TextInputType.name),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: _openBarcodeScanner,
                        child: AbsorbPointer(
                          child: FieldText(
                            controller: itemBarcode,
                            labelText: 'Barcode',
                            keyboardType: TextInputType.name,
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
      drawer: const AppDrawer(),
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
                  FieldText(
                    controller: consignor,
                    labelText: 'Consignor Name',
                    obscureText: false,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 25),
                  FieldText(
                    controller: consignee,
                    labelText: 'Consignee Name',
                    keyboardType: TextInputType.name,
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  FieldText(
                      controller: destination,
                      labelText: 'Destination',
                      keyboardType: TextInputType.name,
                      obscureText: false),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: FieldText(
                          controller: boxMismatchFromOrder,
                          labelText: 'Box Mismatch from order',
                          keyboardType: TextInputType.name,
                          obscureText: false,
                        ),
                      ),
                      const SizedBox(width: 1),
                      Flexible(
                        flex: 1,
                        child: FieldText(
                          controller: boxMismatchOnRescan,
                          labelText: 'Box mismatch on rescan',
                          keyboardType: TextInputType.name,
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
                        child: FieldText(
                            controller: boxCount,
                            labelText: 'Box Count',
                            keyboardType: TextInputType.number,
                            obscureText: false),
                      ),
                      Flexible(
                        flex: 1,
                        child: FieldText(
                            controller: boxDelivered,
                            labelText: 'Box Delivered',
                            keyboardType: TextInputType.number,
                            obscureText: false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  FieldText(
                      controller: freight,
                      labelText: 'Freight',
                      keyboardType: TextInputType.number,
                      obscureText: false),
                  const SizedBox(height: 25),
                  FieldText(
                      controller: lrCharge,
                      labelText: 'LR Charge',
                      keyboardType: TextInputType.number,
                      obscureText: false),
                  const SizedBox(height: 25),
                  FieldText(
                      controller: totalFreight,
                      labelText: 'Total Freight',
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      readOnly: true),
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
