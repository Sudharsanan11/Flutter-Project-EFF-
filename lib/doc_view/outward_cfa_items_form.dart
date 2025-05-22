import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/dialog_text.dart';
import 'package:erpnext_logistics_mobile/modules/auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/barcode_scanner.dart';
import 'package:erpnext_logistics_mobile/modules/dialog_auto_complete.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OutwardCFAItemsForm extends StatefulWidget {
  final String name;
  const OutwardCFAItemsForm({super.key, this.name = ""});

  @override
  State<OutwardCFAItemsForm> createState() => _OutwardCFAItemsFormState();
}

class _OutwardCFAItemsFormState extends State<OutwardCFAItemsForm> {

  final TextEditingController docstatus = TextEditingController();
  final TextEditingController consignor = TextEditingController();
  final TextEditingController itemcode = TextEditingController();
  final TextEditingController itemName = TextEditingController();
  final TextEditingController itemWeight = TextEditingController();
  final TextEditingController itemVolume = TextEditingController();
  final TextEditingController itemCount = TextEditingController();
  final TextEditingController itemBarcode = TextEditingController();
  
  List<Map<String, String>> items = [];
  List<Map<String, String>> scannedItems = [];
  List<String> consignorList = [];
  List<String> itemList = [];
  bool isLoading = false;
  bool isDisabled = false;


   @override
  void initState() {
    super.initState();
    fetchConsignor();
  }

  Future<List<String>> fetchConsignor() async {
    print("fetchConsignor =================================================================");
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Customer",
      "filters": [
        ["custom_party_type", "=", "Consignor"]
      ]
    };
    try {
      print(ApiEndpoints.baseUrl + ApiEndpoints.authEndpoints.getList);
      print(body);
      final response =  await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList , body);
      print(response);
      return response;
    } catch (e) {
      throw "Fetch Error";
    }
  }

  Future<List<String>> fetchItem () async {
    final ApiService apiService = ApiService();
    print("COnsignor================= ${consignor.text}");
    final body = {
      "doctype" : "Item",
      "filters" : [["customer","=", consignor.text]]
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
    print("items $items");
    itemName.text = item?['item_code'] ?? "";
    itemCount.text = item?['item_count'] ?? "";


    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item == null ? 'Add Item' : 'Edit Item'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10,),
                  // DialogTextField(
                  //   controller: itemName,
                  //   keyboardType: TextInputType.name,
                  //   labelText: "Item Name",
                  // ),
                  FutureBuilder<List<String>>(
                future: fetchItem(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return DialogAutoComplete(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Item Is Required";
                        }
                        return null;
                      },
                      hintText: 'Item Name',
                      controller: itemName,
                      onSelected: (String selection) {
                        print('You selected: $selection');
                        setState(() {
                          print("sele");
                          itemName.text = selection;
                        });
                      },
                      options: itemList,
                    );
                  } else if (snapshot.hasData) {
                    itemList = snapshot.data!;
                    return DialogAutoComplete(
                      validator:  (value) {
                        if (value == null || value.isEmpty) {
                          return "Item Is Required";
                        }
                        return null;
                      },
                      controller: itemName,
                      hintText: 'Item Name',
                      onSelected: (String selection) {
                        itemName.text = selection;
                        print('You selected: ${consignor.text}');
                      },
                      options: itemList,
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
                  const SizedBox(height: 10,),
                  DialogTextField(
                    controller: itemCount,
                    keyboardType: TextInputType.number,
                    labelText: "Box Count",
                  ),
                  // const SizedBox(height: 10,),
                  // DialogTextField(
                  //   controller: itemVolume,
                  //   keyboardType: TextInputType.name,
                  //   labelText: "Volume",
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
                     "box_count" : itemCount.text
                     }
                  );
                  });
                  itemName.clear();
                  itemCount.clear();
                  Navigator.of(context).pop();
                }
                else {
                  setState(() {
                    items[index!]["item_code"] = itemName.text;
                    items[index]["box_count"] = itemCount.text;
                  });
                  itemName.clear();
                  itemCount.clear();
                  Navigator.of(context).pop();
                }
              },
            )
          ]
        );
      }
    );
  }

  void _openBarcodeScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScanner(
          // onScanResult: (scanResult) {
          //   setState(() {
          //     if (items.isNotEmpty && items[items.length - 1]['barcode'] == '') {
          //       // items.add({
          //       //   'item_code': itemName.text,
          //       //   'barcode': scanResult,
          //       // });
          //       items[items.length - 1]['barcode'] = scanResult;
          //     } else if(items.isEmpty){
          //       items.add({
          //         'item_code': '',
          //         'barcode': scanResult,
          //       });
          //     } else {
          //       items.add({
          //         'item_code': items[items.length - 1]['item_code'].toString(),
          //         'barcode': scanResult,
          //       });
          //     }
          //     itemName.clear();
          //     itemBarcode.clear();
          //   });
          // },
          onSaveBarcodes: (p0) => {},
        ),
      ),
    );
  }

  Future<void> submitData() async {

    ApiService apiService = ApiService();

    final body = {
      "consignor": consignor.text,
      "items": items,
      "scanned_items": scannedItems
    };

    try{
      if(docstatus.text == "1"){
        Fluttertoast.showToast(
            msg: "Cannot save the Submitted Document",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
      }
      if(docstatus.text == "0"){
        final response = await apiService.updateDocument(
            '${ApiEndpoints.authEndpoints.outwardItems}/${widget.name}', body);
        if (response == "200") {
          Fluttertoast.showToast(
            msg: "Document Saved Successfully",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
          if (mounted) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OutwardCFAItemsForm(name: widget.name,)));
          }
        }
      }
      if(docstatus.text == "-1"){
      final response = await apiService.createDocument(ApiEndpoints.authEndpoints.outwardItems, body);

      if(response[0] == 200){
        Fluttertoast.showToast(
            msg: "Document Saved Successfully",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OutwardCFAItemsForm(name: response[1],)));
        }
      }
      }

    }
    catch(error) {
      Fluttertoast.showToast(
            msg: "Failed to Save $error",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5);
    }
  }

  void submitDoc() async{
    final ApiService apiService = ApiService();
    final body = {
      "docstatus" : 1
    };
    try {
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.outwardItems}/${widget.name}', body);
      print(response);
      if(response == "200") {
        Fluttertoast.showToast(msg: "Document Submitted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => OutwardCFAItemsForm(name: widget.name,)));
        }
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
      final response = await apiService.deleteDocument('${ApiEndpoints.authEndpoints.outwardItems}/${widget.name}');
      if(response == "202") {
        Fluttertoast.showToast(msg: "Document deleted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const OutwardCFAItemsForm()));
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
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.outwardItems}/${widget.name}', body);
      if(response == "200") {
        Fluttertoast.showToast(msg: "Document Canceled successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const OutwardCFAItemsForm()));
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inward CFA Items"),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 20),
            child: PopupMenuButton(
              itemBuilder: (context) => [
                if(docstatus.text == "0")
                const PopupMenuItem(
                  value: 1,
                  child: Text('Submit', style: TextStyle(),),
                ),
                if(docstatus.text == "0")
                const PopupMenuItem(
                  value: 0,
                  child: Text('Delete'),
                ),
                if(docstatus.text == "1")
                const PopupMenuItem(
                  value: 2,
                  child: Text('Cancel'),
                ),
              ],
              onSelected: (value) {
                setState(() {
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
      body: isLoading
      ? const Center(child: CircularProgressIndicator(),)
      : SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
                const SizedBox(height: 10,),
                FutureBuilder<List<String>>(
                future: fetchConsignor(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return AutoComplete(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Consignor name is required";
                        }
                        return null;
                      },
                      hintText: 'Consignor Name',
                      controller: consignor,
                      onSelected: (String selection) {
                        print('You selected: $selection');
                        setState(() {
                          print("sele");
                          consignor.text = selection;
                          fetchItem();
                        });
                      },
                      options: consignorList,
                    );
                  } else if (snapshot.hasData) {
                    consignorList = snapshot.data!;
                    return AutoComplete(
                      controller: consignor,
                      hintText: 'Consignor Name',
                      onSelected: (String selection) {
                        print('You selected: ${consignor.text}');
                      },
                      options: consignorList,
                    );
                  } else {
                    return const Text("");
                  }
                },
              ),
              //item couts
              Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Items"),
                          Row(children: [
                            ElevatedButton(
                              child: const Icon(Icons.add),
                              onPressed: () {
                                _showItemDialog();
                              },
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 3.0),
                        child: Column(
                          children: [
                            DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(12.0),
                              strokeWidth: 1,
                              dashPattern: const [8, 4],
                              color: Colors.black,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0, vertical: 20.0),
                                  child: const Center(
                                    child: Text("No Items Found"),
                                  )),
                            )
                          ],
                        ),
                      ),
                    if (items.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 17.0, vertical: 3.0),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.black),
                                      borderRadius: BorderRadius.circular(10),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: ListTile(
                                      leading: Text("${index + 1}."),
                                      title: Text(
                                          '${items[index]["item_code"]}'),
                                      onTap: () {
                                        _showItemDialog(
                                            item: items[index], index: index);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                    //Scanned Items
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Items"),
                          Row(children: [
                            ElevatedButton(
                              child: const Icon(Icons.add),
                              onPressed: () {
                                _showItemDialog();
                              },
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 20)),
                              onPressed: scannedItems.isNotEmpty ? () {
                                _openBarcodeScanner();
                              }: null,
                              child: const Icon(Icons.camera),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (scannedItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 3.0),
                        child: Column(
                          children: [
                            DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(12.0),
                              strokeWidth: 1,
                              dashPattern: const [8, 4],
                              color: Colors.black,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0, vertical: 20.0),
                                  child: const Center(
                                    child: Text("No Items Found"),
                                  )),
                            )
                          ],
                        ),
                      ),
                    if (scannedItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 17.0, vertical: 3.0),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ListView.builder(
                              itemCount: scannedItems.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.black),
                                      borderRadius: BorderRadius.circular(10),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: ListTile(
                                      leading: Text("${index + 1}."),
                                      title: Text(
                                          '${scannedItems[index]["item_code"]}'),
                                      onTap: () {
                                        _showItemDialog(
                                            item: scannedItems[index], index: index);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      MyButton(
                        onTap: isDisabled
                            ? () {
                                Fluttertoast.showToast(
                                    msg: "Can't able to save",
                                    gravity: ToastGravity.BOTTOM,
                                    fontSize: 16.0);
                              }
                            : submitData,
                        name: "Save")
            ],),
        )),
    );
  }
}