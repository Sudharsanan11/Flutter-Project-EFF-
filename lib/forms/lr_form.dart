import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/dialog_text.dart';
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

  Future<void> _showItemDialog({dynamic item, int? index}) async {
    itemName.text = item?['item_code'] ?? "";
    itemWeight.text = item?['item_weight'] ?? "";
    itemVolume.text = item?['item_vloume'] ?? "";
    itemBarcode.text = item?['item_barcode'] ?? "";


    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item == null ? 'Add Item' : 'Edit Item'),
          content: Container(
            width: MediaQuery.of(context).size.width * 1.8,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10,),
                  DialogTextField(
                    controller: itemName,
                    keyboardType: TextInputType.name,
                    labelText: "Item Name",
                  ),
                  const SizedBox(height: 10,),
                  DialogTextField(
                    controller: itemWeight,
                    keyboardType: TextInputType.name,
                    labelText: "Weight",
                  ),
                  const SizedBox(height: 10,),
                  DialogTextField(
                    controller: itemVolume,
                    keyboardType: TextInputType.name,
                    labelText: "Volume",
                  ),
                  const SizedBox(height: 10,),
                  // Row(
                    // children: [
                      // Expanded(
                        DialogTextField(
                          controller: itemBarcode,
                          keyboardType: TextInputType.text,
                          labelText: "Barcode",
                        ),
                      // ),
                      // const SizedBox(width: 2,),
                      // Expanded(
                        TextButton(
                          onPressed: () {
                            _openBarcodeScanner();
                          },
                          child: const Text("Scan")
                          ),
                      // )
                    // ],
                  // ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(item == null ? 'Cancel' : 'Delete'),
              onPressed: () {
                if(item == null){
                  Navigator.of(context).pop();
                }
                else {
                  setState(() {  
                  // items.removeWhere((item) => item.length == index);
                  items.remove(item);
                  });
                  Navigator.of(context).pop();
                }
              }
            ),
            TextButton(
              child: Text(item == null ? 'Add' : 'Save'),
              onPressed: () {
                if(item == null) {
                  setState(() {
                  items.add(
                    {"item_code" : itemName.text,
                     "item_weight" : itemWeight.text,
                     "item_volume" : itemVolume.text,
                     "item_barcode" : itemBarcode.text,
                     }
                  );
                  });
                  itemName.clear();
                  itemWeight.clear();
                  itemVolume.clear();
                  itemBarcode.clear();
                  Navigator.of(context).pop();
                }
                else {
                  setState(() {
                    items[index!]["item_code"] = itemName.text;
                    items[index]["item_weight"] = itemWeight.text;
                    items[index]["item_volume"] = itemVolume.text;
                    items[index]["item_barcode"] = itemBarcode.text;
                  });
                  itemName.clear();
                  itemWeight.clear();
                  itemVolume.clear();
                  itemBarcode.clear();
                  Navigator.of(context).pop();
                }
              },
            )
          ]
        );
      }
    );
  }

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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 3.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Padding(padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0)),
                        Text("Items"),
                        ElevatedButton(
                          child: Icon(Icons.add),
                          onPressed: () {
                            _showItemDialog();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 3.0),
                      child: Column(
                        children: [
                          DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(12.0),
                            strokeWidth: 1,
                            dashPattern: const [8,4],
                            color: Colors.black,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                              child: const Center(
                                child: Text("No Items Found"),
                              )
                            ),
                          )
                        ],
                      ),
                    ),
                    if (items.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 3.0),
                      child: Container(
                        height: 200, // Set a fixed height for the ListView
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                  shape: BoxShape.rectangle,
                                ),
                                child: ListTile(
                                  title: Text(items[index]["item_code"].toString()),
                                  onTap: () {
                                    _showItemDialog(item: items[index], index: index);
                                  },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
