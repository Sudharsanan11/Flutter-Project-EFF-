import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_list/lr_list.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/dialog_text.dart';
import 'package:erpnext_logistics_mobile/fields/drop_down.dart';
import 'package:erpnext_logistics_mobile/fields/text_area.dart';
import 'package:erpnext_logistics_mobile/forms/lr_form.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/modules/auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/barcode_scanner.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LRView extends StatefulWidget {
  final String name;
  const LRView({super.key, required this.name});

  @override
  State<LRView> createState() => _LRViewState();
}

class _LRViewState extends State<LRView> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController lrType = TextEditingController();
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
  final TextEditingController deliveredOn = TextEditingController();
  final TextEditingController boxDelivered = TextEditingController();
  final TextEditingController totalItems = TextEditingController();
  final TextEditingController itemName = TextEditingController();
  final TextEditingController itemWeight = TextEditingController();
  final TextEditingController itemVolume = TextEditingController();
  final TextEditingController itemBarcode = TextEditingController();
  final TextEditingController selectedLrType = TextEditingController();
  final TextEditingController remarks = TextEditingController();


  // String? selectedLrType;
  List<Map<String, String>> items = [];

  List<String> requestList = [];
  List<String> logsheetList = [];
  List<String> consignorList = [];
  List<String> consigneeList = [];
  List<String> destinationList = [];
  List<String> itemList = [];
  bool isDisabled = false;
  int docstatus = 0;
  bool? crossCheckStatus = false;
  bool? calculationBasedOnLRLevel = false;
  bool? manualFreightAmount = false;

  @override
  void initState() {
    super.initState();
    fetchConsignee();
    fetchLR();
  }

  @override
  void dispose() {
    lrType.dispose();
    collectionRequest.dispose();
    logsheet.dispose();
    consignor.dispose();
    consignee.dispose();
    destination.dispose();
    boxCount.dispose();
    boxMismatchFromOrder.dispose();
    boxMismatchOnRescan.dispose();
    freight.dispose();
    lrCharge.dispose();
    totalFreight.dispose();
    deliveredOn.dispose();
    boxDelivered.dispose();
    totalItems.dispose();
    itemName.dispose();
    itemWeight.dispose();
    itemVolume.dispose();
    itemBarcode.dispose();
    selectedLrType.dispose();
    remarks.dispose();
    items = [];
    requestList = [];
    logsheetList = [];
    consignorList = [];
    consigneeList = [];
    destinationList = [];
    itemList = [];
    super.dispose();
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
      final response = await apiService.getDocument('${ApiEndpoints.authEndpoints.LR}/${widget.name}');
      print(response);
       setState(() {
        
        lrType.text = response['lr_type'] ?? "";
        collectionRequest.text = response["collection_request"] ?? "";
        logsheet.text = response["logsheet"] ?? "";
        consignor.text = response["consignor"] ?? "";
        consignee.text = response["consignee"] ?? "";
        destination.text = response["destination"] ?? "";
        boxCount.text =  response["box_count"] != 0 ? response["box_count"].toString() : "0";
        boxMismatchFromOrder.text = response["box_mismatch_from_order"] != 0 ? response["box_mismatch_from_order"].toString() : "0";
        boxMismatchOnRescan.text = response["box_mismatch_on_rescan"] != 0 ? response["box_mismatch_on_rescan"].toString() : "0";
        crossCheckStatus = response["cross_check_status"] == 0 ? false : true;
        calculationBasedOnLRLevel = response["calculation_based_on_lr_level"] == 0 ? false : true;
        manualFreightAmount = response["manual_freight_amount"] == 0 ? false : true;
        freight.text = response["freight"] != 0 ? response["freight"].toString() : "0";
        lrCharge.text = response["lr_charge"] != 0 ? response["lr_charge"].toString() : "0";
        totalFreight.text = response["total_freight"] != 0 ? response["total_freight"].toString() : "0";
        deliveredOn.text = response["delivered_on"] ?? "";
        boxDelivered.text = response["box_delivered"] != 0 ? response["box_delivered"].toString() : "0";
        totalItems.text = response["total_items"] != 0 ? response["total_items"].toString() : "0";
        remarks.text = response["remarks"] ?? "";
        docstatus = response["docstatus"];
        print(response['items']);
        items = (response["items"] as List).map((item) {
            return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
      }).toList();
        print(items);
        if(response['docstatus'] != 0){
          isDisabled = true;
        }
      });
        print(response);
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
      setState(() {
        consigneeList = response;
      });
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

  void submitDoc() async{
    final ApiService apiService = ApiService();
    final body = {
      "docstatus" : 1
    };
    try {
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.LR}/${widget.name}', body);
      print(response);
      if(response == "200") {
        Fluttertoast.showToast(msg: "Document Submitted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted) {
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => LRView(name: widget.name)));
        }
        // initState();
      }
      else {
        Fluttertoast.showToast(msg: "Failed to submit document", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      }
      print(response);
    }
    catch(e) {
      print(e);
    }
  }

  void deleteDoc() async {
    final ApiService apiService = ApiService();
    try {
      final response = await apiService.deleteDocument('${ApiEndpoints.authEndpoints.LR}/${widget.name}');
      if(response == "202") {
        Fluttertoast.showToast(msg: "Document deleted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LRList()));
        }
      }
      else {
        Fluttertoast.showToast(msg: "Failed to delete document", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      }
      print(response);
    }
    catch(e) {
      print(e);
    }
  }

  void cancelDoc() async{
    final ApiService apiService = ApiService();
    final body = {
      "docstatus" : 2
    };
    try {
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.LR}/${widget.name}', body);
      if(response == "200") {
        Fluttertoast.showToast(msg: "Document Canceled successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LRList()));
        }
      }
      else {
        Fluttertoast.showToast(msg: "Failed to cancel document", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      }
      print(response);
    }
    catch(e) {
      print(e);
    }
  }

  Future<void> _showItemDialog({dynamic item, int? index}) async {
    itemName.text = item?['item_code'] ?? "";
    itemWeight.text = item?['weight'] ?? "";
    itemVolume.text = item?['volume'] ?? "";
    itemBarcode.text = item?['barcode'] ?? "";

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
                    readOnly: isDisabled,
                    labelText: "Item Name",
                  ),
                  const SizedBox(height: 10,),
                  DialogTextField(
                    controller: itemWeight,
                    keyboardType: TextInputType.number,
                    // readOnly: true,
                    labelText: "Weight",
                  ),
                  const SizedBox(height: 10,),
                  DialogTextField(
                    controller: itemVolume,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    labelText: "Volume",
                  ),
                  const SizedBox(height: 10,),
                  // Row(
                    // children: [
                      // Expanded(
                        DialogTextField(
                          controller: itemBarcode,
                          keyboardType: TextInputType.text,
                          readOnly: isDisabled,
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
                     "weight" : itemWeight.text,
                     "volume" : itemVolume.text,
                     "barcode" : itemBarcode.text,
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
                    items[index]["weight"] = itemWeight.text;
                    items[index]["volume"] = itemVolume.text;
                    items[index]["barcode"] = itemBarcode.text;
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
    print("Submit data");
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      print(_formKey.currentState?.value);
      final ApiService apiService = ApiService();
    final body = {
      "lr_type" : lrType.text,
      "logsheet": logsheet.text,
      "collection_request": collectionRequest.text,
      "consignor": consignor.text,
      "consignee": consignee.text,
      "location": destination.text,
      "box_count": boxCount.text,
      "box_mismatch_from_order": boxMismatchFromOrder.text,
      "box_mismatch_on_rescan": boxMismatchOnRescan.text,
      "cross_check_status" : crossCheckStatus,
      "calculation_based_on_lr_level" : calculationBasedOnLRLevel,
      "freight": freight.text,
      "lr_charge": lrCharge.text,
      "manual_freight_amount" : manualFreightAmount,
      "items": items,
      "total_freight": totalFreight.text,
      "box_delivered": boxDelivered.text,
      "total_items": totalItems.text,
      "remarks" : remarks.text,
      "docstatus" : 0,
    };
    try {
      final response = await apiService.updateDocument(ApiEndpoints.authEndpoints.LR + widget.name, body);
      if(response == "200") {
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => LRView(name: widget.name)));
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if(didPop) {return;}
        Navigator.pushReplacement(context, 
        MaterialPageRoute(builder: (context) => const LRList()));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('LR Form'),
          actions: [
              Padding(padding: const EdgeInsets.only(right: 20),
              child: PopupMenuButton(
                itemBuilder: (context) => [
                  if(docstatus == 0)
                  const PopupMenuItem(
                    value: 1,
                    child: Text('Submit', style: TextStyle(),),
                  ),
                  if(docstatus == 0)
                  const PopupMenuItem(
                    value: 0,
                    child: Text('Delete'),
                  ),
                  if(docstatus == 1)
                  const PopupMenuItem(
                    value: 2,
                    child: Text('Cancel'),
                  ),
                ],
                onSelected: (value) {
                  setState(() {
                    docstatus = value;
                    if(value == 1){
                      submitDoc();
                    }
                    else if(value == 0){
                      deleteDoc();
                    }
                    else if(value == 2) {
                      cancelDoc();
                    }
                  });
                },
              child: const  Icon(
                Icons.more_vert,
                size: 28.0,
              ),
              ),
              ),
            ],
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
                    FieldText(
                      controller: lrType,
                      labelText: "LR Type",
                      readOnly: true,
                      keyboardType: TextInputType.none
                    ),
                      const SizedBox(height: 15),
                    FieldText(
                      controller: collectionRequest,
                      labelText: "Collection Request",
                      keyboardType: TextInputType.none,
                      readOnly: true,
                    ),
                    if(logsheet.text != "")
                    const SizedBox(height: 15),
                    if(logsheet.text != "")
                    FieldText(
                      controller: logsheet,
                      labelText: "Logsheet",
                      keyboardType: TextInputType.none,
                      readOnly: true,
                    ),
                    const SizedBox(height: 15),
                    FieldText(
                      controller: consignor,
                      labelText: "Consignor",
                      keyboardType: TextInputType.none,
                      readOnly: true,
                    ),
                    const SizedBox(height: 15),
                    FieldText(
                      controller: consignee,
                      labelText: "Consignee",
                      keyboardType: TextInputType.none,
                      readOnly: true,
                    ),
                  const SizedBox(height: 15),
                  FieldText(
                    controller: destination,
                    labelText: "Destination",
                    keyboardType: TextInputType.none,
                    readOnly: true,
                  ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: FieldText(
                            controller: boxMismatchFromOrder,
                            labelText: 'Box Mismatch from order',
                            readOnly: true,
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
                            readOnly: true,
                            keyboardType: TextInputType.number,
                            obscureText: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: FieldText(
                              controller: boxCount,
                              labelText: 'Box Count',
                              keyboardType: TextInputType.number,
                              readOnly: isDisabled,
                              obscureText: false),
                        ),
                        Flexible(
                          flex: 1,
                          child: FieldText(
                              controller: boxDelivered,
                              labelText: 'Box Delivered',
                              readOnly: isDisabled,
                              keyboardType: TextInputType.number,
                              obscureText: false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Checkbox(
                          value: crossCheckStatus,
                          onChanged: (newBool) {
                            setState(() {
                              crossCheckStatus = newBool;
                            });
                          },
                          activeColor: Colors.black,
                        ),
                        const SizedBox(width: 10),
                        const Text("Cross-Check Status"),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [                      
                        Checkbox(
                          value: calculationBasedOnLRLevel,
                          onChanged: (newBool) {
                            setState(() {
                              calculationBasedOnLRLevel = newBool;
                            });
                          }, 
                          activeColor: Colors.black,
                        ),
                        const SizedBox(width: 10),
                        const Text("Calculation Based on LR Level"),
                      ]
                    ),
                  ),
                   Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [                      
                        Checkbox(
                          value: manualFreightAmount,
                          onChanged: (newBool) {
                            setState(() {
                              manualFreightAmount = newBool;
                            });
                          }, 
                          activeColor: Colors.black,
                        ),
                        const SizedBox(width: 10),
                        const Text("Manual Freight Amount"),
                      ]
                    ),
                  ),
                  const SizedBox(height: 10),
                    FieldText(
                        controller: freight,
                        labelText: 'Freight',
                        keyboardType: TextInputType.number,
                        readOnly: isDisabled == true && manualFreightAmount != true ? true : false,
                        obscureText: false),
                    const SizedBox(height: 25),
                    FieldText(
                        controller: lrCharge,
                        labelText: 'LR Charge',
                        readOnly: isDisabled,
                        keyboardType: TextInputType.number,
                        obscureText: false),
                    const SizedBox(height: 25),                    
                    FieldText(
                        controller: totalFreight,
                        labelText: 'Total Freight',
                        keyboardType: TextInputType.number,
                        obscureText: false,
                        readOnly: true
                      ),
                    const SizedBox(height: 10),
                    TextArea(
                      controller: deliveredOn,
                      readOnly: true,
                      labelText: "Delivered On",
                      keyboardType: TextInputType.datetime
                    ),
                    const SizedBox(height: 10),                    
                    TextArea(
                      controller: boxDelivered,
                      labelText: "Box Delivered",
                      readOnly: true,
                      keyboardType: TextInputType.number
                    ),
                    const SizedBox(height: 10),
                    TextArea(
                      controller: remarks,
                      labelText: "Remarks",
                      keyboardType: TextInputType.multiline
                    ),
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
                            onPressed: isDisabled ? (){} : () {
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
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  ),
                    MyButton(onTap: isDisabled ? (){Fluttertoast.showToast(msg: "Can't able to save", gravity: ToastGravity.BOTTOM, fontSize: 16.0);} : submitData, name: "Save")
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavigation(),
      ),
    );
  }
}
