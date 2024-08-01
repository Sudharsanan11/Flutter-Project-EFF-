import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/dialog_text.dart';
import 'package:erpnext_logistics_mobile/fields/drop_down.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/modules/auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/barcode_scanner.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';

class LRView extends StatefulWidget {
  final String name;
  const LRView({super.key, required this.name});

  @override
  State<LRView> createState() => _LRViewState();
}

class _LRViewState extends State<LRView> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController collectionRequest = TextEditingController();
  final TextEditingController logsheet = TextEditingController();
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
  final TextEditingController selectedLrType = TextEditingController();


  // String? selectedLrType;
  List<Map<String, String>> items = [];
  int zero = 0;

  List<String> requestList = [];
  List<String> logsheetList = [];
  List<String> consignorList = [];
  List<String> consigneeList = [];
  List<String> destinationList = [];
  List<String> itemList = [];

  @override
  void initState() {
    super.initState();
    fetchLR();
  }

  Future<List<String>> fetchRequest() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Collection Request",
      "filters" : [["status", "=", "Assigned"]]
    };
    try {
      final response =  await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList , body);
      print(response);
      return response;
    }
    catch(e) {
      throw "Fetch Error";
    }
  }

  Future<Map<String, dynamic>> fetchLR() async{
    final ApiService apiService = ApiService();
    try {
      final response = await apiService.getDocument(ApiEndpoints.authEndpoints.getLR + widget.name);
      setState(() {
        collectionRequest.text = response["collection_request"].toString();
        logsheet.text = response["logsheet"].toString();
        consignor.text = response["consignor"].toString();
        consignee.text = response["consignee"].toString();
        destination.text = response["destination"].toString();
        boxCount.text =  response["box_count"] == 0 ? response["box_count"].toString() : zero.toString();
        boxMismatchFromOrder.text = response["box_mismatch_from_order"].toString();
        boxMismatchOnRescan.text = response["box_mismatch_on_rescan"].toString();
        freight.text = response["freight"].toString();
        lrCharge.text = response["lr_charge"].toString();
        totalFreight.text = response["total_freight"].toString();
        boxDelivered.text = response["box_delivered"].toString();
        totalItems.text = response["total_items"].toString();
        items = response["items"];
        print(response);
      });
      return response;
    }
    catch(e) {
      throw "Fetch Error";
    }
  }

  Future<List<String>> fetchLogsheet() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Logsheet",
      "filters" : [["status", "=", "0"]]
    };
    try {
      final response =  await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList , body);
      print(response);
      return response;
    }
    catch(e) {
      throw "Fetch Error";
    }
  }

  Future<List<String>> fetchConsignor() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Customer",
      "filters" : [["custom_party_type","=","Consignor"]]
    };
    try {
      final response =  await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList , body);
      print(response);
      return response;
    }
    catch(e) {
      throw "Fetch Error";
    }
  }

  Future<List<String>> fetchConsignee() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Customer",
      "filters" : [["custom_party_type","=","Consignee"]]
    };
    try {
      final response =  await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList , body);
      print(response);
      return response;
    }
    catch(e) {
      throw "Fetch Error";
    }
  }

  Future<List<String>> fetchLocation () async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Location",
      // "filters" : [["is_warehouse","=","1"]]
    };
    try {
      final response =  await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList , body);
      print(response);
      return response;
    }
    catch(e) {
      throw "Fetch Error";
    }
  }

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
          content: SizedBox(
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
                    keyboardType: TextInputType.number,
                    labelText: "Weight",
                  ),
                  const SizedBox(height: 10,),
                  DialogTextField(
                    controller: itemVolume,
                    keyboardType: TextInputType.number,
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

  Future<String> submitData() async{
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      print(_formKey.currentState?.value);
      final ApiService apiService = ApiService();
    final body = {
      "logsheet": logsheet.text,
      "collection_request": collectionRequest.text,
      "consignor": consignor.text,
      "consignee": consignee.text,
      "location": destination.text,
      "box_count": boxCount.text,
      "box_mismatch_from_order": boxMismatchFromOrder.text,
      "box_mismatch_on_rescan": boxMismatchOnRescan.text,
      "freight": freight.text,
      "lr_charge": lrCharge.text,
      "items": items,
      "total_freight": totalFreight.text,
      "box_delivered": boxDelivered.text,
      "total_items": totalItems.text,
    };
    try {
      final response = await apiService.createDocument(ApiEndpoints.authEndpoints.createLR, body);
      if(response == "200") {
        Navigator.pop(context);
      }
      return "";
    }
    catch (error) {
      print(error);
      return "Error: Failed to submit data";
    }
    } else {
      print("Validation failed");
      return "";
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
                    controller: selectedLrType,
                    selectedItem: selectedLrType.text,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLrType.text = newValue.toString();
                      });
                    },
                  ),
                  if(selectedLrType == "By Collection Request")
                    const SizedBox(height: 25),
                  if(selectedLrType == "By Collection Request")
                    FutureBuilder<List<String>>(
                    future: fetchRequest(),
                    builder: (context, snapshot) {
                      if(snapshot.hasError) {
                        return AutoComplete(
                          controller: collectionRequest,
                          hintText: 'Collection Request',
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                          options: requestList,
                        );
                      }
                      else if (snapshot.hasData) {
                        requestList = snapshot.data!;
                        return AutoComplete(
                          controller: collectionRequest,
                          hintText: 'Collection Request',
                          onSelected: (String selection) {
                            print(selection);
                          },
                          options: requestList,
                        );
                      } else {
                        return AutoComplete(
                          controller: collectionRequest,
                          hintText: 'Collection Request',
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                          options: requestList,
                        );
                      }
                    },
                  ),
                if(selectedLrType == "By Log Sheet")
                  const SizedBox(height: 25),
                if(selectedLrType == "By Log Sheet")
                FutureBuilder<List<String>>(
                  future: fetchLogsheet(),
                  builder: (context, snapshot) {
                    if(snapshot.hasError) {
                      return AutoComplete(
                        controller: logsheet,
                        hintText: 'Logsheet',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: logsheetList,
                      );
                    }
                    else if (snapshot.hasData) {
                      logsheetList = snapshot.data!;
                      return AutoComplete(
                        controller: logsheet,
                        hintText: 'Logsheet',
                        onSelected: (String selection) {
                          print(selection);
                        },
                        options: logsheetList,
                      );
                    } else {
                      return AutoComplete(
                        controller: logsheet,
                        hintText: 'Logsheet',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: logsheetList,
                      );
                    }
                  },
                ),
                const SizedBox(height: 25),
                  FutureBuilder<List<String>>(
                  future: fetchConsignor(),
                  builder: (context, snapshot) {
                    if(snapshot.hasError) {
                      return AutoComplete(
                        controller: consignor,
                        hintText: 'Consignor Name',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: consignorList,
                      );
                    }
                    else if (snapshot.hasData) {
                      consignorList = snapshot.data!;
                      return AutoComplete(
                        controller: consignor,
                        hintText: 'Consignor Name',
                        onSelected: (String selection) {
                          print(selection);
                        },
                        options: consignorList,
                      );
                    } else {
                      return AutoComplete(
                        controller: consignor,
                        hintText: 'Consignor Name',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: consignorList,
                      );
                    }
                  },
                ),
                  const SizedBox(height: 25),
                  FutureBuilder<List<String>>(
                  future: fetchConsignee(),
                  builder: (context, snapshot) {
                    if(snapshot.hasError) {
                      return AutoComplete(
                        controller: consignee,
                        hintText: 'Consignee Name',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: consigneeList,
                      );
                    }
                    else if (snapshot.hasData) {
                      consigneeList = snapshot.data!;
                      return AutoComplete(
                        controller: consignee,
                        hintText: 'Consignee Name',
                        onSelected: (String selection) {
                          print(selection);
                        },
                        options: consigneeList,
                      );
                    } else {
                      return AutoComplete(
                        controller: consignee,
                        hintText: 'Consignee Name',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: consigneeList,
                      );
                    }
                  },
                ),
                  const SizedBox(height: 25),
                  FutureBuilder<List<String>>(
                  future: fetchLocation(),
                  builder: (context, snapshot) {
                    if(snapshot.hasError) {
                      return AutoComplete(
                        controller: destination,
                        hintText: 'Destination',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: destinationList,
                      );
                    }
                    else if (snapshot.hasData) {
                      destinationList = snapshot.data!;
                      return AutoComplete(
                        controller: destination,
                        hintText: 'Destination',
                        onSelected: (String selection) {
                          print(selection);
                        },
                        options: destinationList,
                      );
                    } else {
                      return AutoComplete(
                        controller: destination,
                        hintText: 'Destination',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: destinationList,
                      );
                    }
                  },
                ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: FieldText(
                          controller: boxMismatchFromOrder,
                          labelText: 'Box Mismatch from order',
                          keyboardType: TextInputType.number,
                          obscureText: false,
                        ),
                      ),
                      const SizedBox(width: 1),
                      Flexible(
                        flex: 1,
                        child: FieldText(
                          controller: boxMismatchOnRescan,
                          labelText: 'Box mismatch on rescan',
                          keyboardType: TextInputType.number,
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
                        const Text("Items"),
                        ElevatedButton(
                          child: const Icon(Icons.add),
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
                      child: SizedBox(
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
                  MyButton(onTap: submitData, name: "Submit")
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}
