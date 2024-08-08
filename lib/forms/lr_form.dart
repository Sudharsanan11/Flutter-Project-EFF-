import 'dart:ffi';

import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_view/lr_view.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/dialog_text.dart';
import 'package:erpnext_logistics_mobile/fields/drop_down.dart';
import 'package:erpnext_logistics_mobile/fields/text_area.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/modules/auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/barcode_scanner.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_navigation/get_navigation.dart';

class LrForm extends StatefulWidget {
  const LrForm({super.key});

  @override
  State<LrForm> createState() => _LrFormState();
}

class _LrFormState extends State<LrForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController lrType = TextEditingController();
  final TextEditingController collectionRequest = TextEditingController();
  final TextEditingController logsheet = TextEditingController();
  final TextEditingController consignor = TextEditingController();
  final TextEditingController consignee = TextEditingController();
  final TextEditingController destination = TextEditingController();
  final TextEditingController invoiceNo = TextEditingController();
  final TextEditingController freight = TextEditingController();
  final TextEditingController lrCharge = TextEditingController();
  final TextEditingController itemName = TextEditingController();
  final TextEditingController itemWeight = TextEditingController();
  final TextEditingController itemVolume = TextEditingController();
  final TextEditingController itemBarcode = TextEditingController();
  final TextEditingController remarks = TextEditingController();


  String? selectedLrType;
  List<Map<String, String>> items = [];

  List<String> requestList = [];
  List<String> logsheetList = [];
  List<String> consignorList = [];
  List<String> consigneeList = [];
  List<String> destinationList = [];
  List<String> itemList = [];
  bool? crossCheckStatus = false;
  bool? calculationBasedOnLRLevel = false;
  bool? manualFreightAmount = false; //
  late Map<String, Map<String, dynamic>> CR;
  late Map<String, Map<String, dynamic>> consigneeDocList;

  Future<List<String>> fetchRequest() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Collection Request",
      "filters" : [["status", "=", "Assigned"]]
    };
    try {
      final response =  await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList , body);
      print('$response ++++++++++++++++++++++++++++++++++++++++++++++++++++++===========================================');
      return response;
    }
    catch(e) {
      throw "Fetch Error";
    }
  }

  Future<List<String>> fetchItem () async {
    // print("date ${date.text}");
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
      "filters" : [["custom_party_type","=","Consignor"]],
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

  // Future<void> fetchConsignee() async {
  //   final ApiService apiService = ApiService();
  //   final body = {
  //     "doctype" : "Customer",
  //     "filters" : [["custom_party_type","=","Consignee"]],
  //     "fields" : ['*'],
  //   };
  //   try {
  //     final response =  await apiService.fetchFieldData(ApiEndpoints.authEndpoints.getList , body);
  //     print(response);
  //     setState(() {
  //       consigneeList = response.map<String>((item) {
  //         return (item as Map<String, dynamic>).keys.first;
  //       }).toList();
  //       consigneeDocList = response;
  //     });
  //     // return response;
  //   }
  //   catch(e) {
  //     throw "Fetch Error";
  //   }
  // }
  Future<void> fetchLocation () async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Customer",
      "filters" : [["custom_party_type","=","Consignee"]],
      "fields" : ['name', 'custom_location']
    };
    try {
      final response =  await apiService.fetchFieldData(ApiEndpoints.authEndpoints.getList , body);
      print("$response ========================location");
      setState(() {
        consigneeDocList = response;
      });
      print("$consigneeDocList ========================location===========================");
      // return response;
    }
    catch(e) {
      throw "Fetch Error";
    }
  }

  Future<void> fetchConsignee(consignorName) async{
    print("consignoer $consignorName");
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Consignor List",
      "filters" : [['consignor', '=', consignorName]],
      "fields" : ['parent'],
      "parent" : "Customer",
    };
    try {
      final response =  await apiService.getList(ApiEndpoints.authEndpoints.getList , body);
      print("response_start0");
      print(response);
      setState(() {
        consigneeList = response.map((item) => item['parent'].toString()).toList();
      });
    }
    catch (e) {
      throw "Fetch Error";
    }
  }

  Future<void> setConsignor () async {
    print("Hiii Consignor====================================");
    final ApiService apiService = ApiService();

    try {
      Object body = {
        "doctype" : "Collection Request",
        "fields" : ['*'],
        "filters" : [['status', '=', 'Assigned']]
      };
      final response =  await apiService.fetchFieldData(ApiEndpoints.authEndpoints.getList, body);
      print("response start");
      print(response);
      print("response end");
      setState(() {
        CR = response;
      });
      print("consignorList $consignorList");
    }
    catch (e) {
      throw "Fetch Error $e";
    }
  }

  @override
  void initState() {
    super.initState();
    setConsignor();
    fetchLocation();
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
                  FutureBuilder<List<String>>(
                    future: fetchItem(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return AutoComplete(
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
                        return AutoComplete(
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
                        return const Text("");
                      }
                    },
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
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20)
                          ),
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

  Future<void> submitData() async{
    // if (_formKey.currentState?.saveAndValidate() ?? false) {
      // print(_formKey.currentState?.value);
      final ApiService apiService = ApiService();
      print(items);
    final body = {
      "lr_type": selectedLrType,
      "logsheet": logsheet.text,
      "collection_request": collectionRequest.text,
      "consignor": consignor.text,
      "consignee": consignee.text,
      "location": destination.text,
      "box_count": 2,
      "cross_check_status" : crossCheckStatus,
      "calculation_based_on_lr_level" : calculationBasedOnLRLevel,
      "lr_charge": lrCharge.text,
      "invoice_number" : invoiceNo.text,
      "remarks" : remarks.text,
      "freight" : freight.text,
      "manual_freight_amount" : manualFreightAmount,
      "items": items,
      "docstatus" : 0,
    };
    try {
      final response = await apiService.createDocument(ApiEndpoints.authEndpoints.LR, body);
      if(response[0] == 200) {
        Fluttertoast.showToast(msg: "Document Saved Successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => LRView(name: response[1])));
      }
    }
    catch (error) {
      print(error);
      throw "Error: Failed to submit data";
    }
    // } else {
    //   print("Validation failed");
    // }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('LR Form'),
      ),
      drawer: const AppDrawer(),
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: 
          // padding: const EdgeInsets.all(10.0),
          SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 5),
                  DropDown(
                    labelText: 'LR Type',
                    // controller: ,
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
                  if(selectedLrType == "By Collection Request")
                    const SizedBox(height: 25),
                  if(selectedLrType == "By Collection Request")
                    FutureBuilder<List<String>>(
                    future: fetchRequest(),
                    builder: (context, snapshot) {
                      if(snapshot.hasError) {
                        return AutoComplete(
                          controller: collectionRequest,
                          readOnly: true,
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
                            // setState(() {
                              int index = consignorList.indexOf(selection);
                              print("index: $index");
                              consignor.text = CR[selection]!['consignor'].toString();
                              fetchConsignee(consignor.text);
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
                  const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                  FieldText(
                    controller: consignor,
                    labelText: "Consignor Name",
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 10),
                AutoComplete(
                  options: consigneeList,
                  hintText: "Consignee Name",
                  onSelected: (String selection){
                    print(selection);
                      destination.text = consigneeDocList[selection]!['custom_location'];
                  },
                  controller: consignee,
                ),
                  const SizedBox(height: 10),
                FieldText(
                  controller: destination,
                  labelText: "Destination",
                  keyboardType: TextInputType.none
                ),
                  const SizedBox(height: 10),
                  FieldText(
                    controller: invoiceNo,
                    labelText: "Invoice Number",
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
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
                    padding: EdgeInsets.symmetric(horizontal: 15),
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
                  if(manualFreightAmount == true)
                  FieldText(
                    controller: freight,
                    labelText: 'Freight',
                    // readOnly: manualFreightAmount == true ? false : true,
                    keyboardType: TextInputType.number,
                    obscureText: false
                  ),
                  const SizedBox(height: 10),
                  FieldText(
                      controller: lrCharge,
                      labelText: 'LR Charge',
                      keyboardType: TextInputType.number,
                      obscureText: false),
                  const SizedBox(height: 10),
                  TextArea(
                    controller: remarks,
                    labelText: "Remarks",
                    keyboardType: TextInputType.multiline
                  ),
                  const SizedBox(height: 10),
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
                  MyButton(onTap: submitData, name: "Save")
                ],
              ),
            ),
          ),
        ),
      bottomNavigationBar: const BottomNavigation(),
      );
  }
}
