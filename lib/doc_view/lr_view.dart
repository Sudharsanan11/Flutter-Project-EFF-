import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_list/lr_list.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/dialog_text.dart';
import 'package:erpnext_logistics_mobile/fields/multi_select.dart';
import 'package:erpnext_logistics_mobile/fields/text_area.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/modules/auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/barcode_scanner.dart';
import 'package:erpnext_logistics_mobile/modules/dialog_auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/mobile_scanner.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:erpnext_logistics_mobile/modules/scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LRView extends StatefulWidget {
  final String name;
  final Map data;
  const LRView({super.key, this.name = "", required this.data});

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
  final TextEditingController invoiceNo = TextEditingController();
  final TextEditingController boxCount = TextEditingController();
  final TextEditingController freight = TextEditingController();
  final TextEditingController lrCharge = TextEditingController();
  final TextEditingController manualWeight = TextEditingController();
  final TextEditingController loadingCharges = TextEditingController();
  final TextEditingController totalFreight = TextEditingController();
  final TextEditingController releaseDate = TextEditingController();
  final TextEditingController reasonForHold = TextEditingController();
  final TextEditingController deliveredOn = TextEditingController();
  final TextEditingController boxDelivered = TextEditingController();
  final TextEditingController totalItems = TextEditingController();
  final TextEditingController itemName = TextEditingController();
  final TextEditingController itemWeight = TextEditingController();
  final TextEditingController itemVolume = TextEditingController();
  final TextEditingController itemBarcode = TextEditingController();
  final TextEditingController totalVG = TextEditingController();
  final TextEditingController totalWeight = TextEditingController();
  // final TextEditingController selectedLrType = TextEditingController();
  final TextEditingController remarks = TextEditingController();
  final TextEditingController date = TextEditingController();
  final TextEditingController docstatus = TextEditingController();

  String? selectedLrType;
  late Map<String, Map<String, dynamic>> CR;
  late Map<String, Map<String, dynamic>> consigneeDocList;
  List<Map<String, String>> items = [];
  List<Map<String, String>> itemsCount = [];
  bool isLoading = false;

  List<String> requestList = [];
  List<String> logsheetList = [];
  List<String> consignorList = [];
  List<String> consigneeList = [];
  List<String> destinationList = [];
  List<String> selectedItems = [];
  List<String> itemList = [];
  List<String> searchItemList = [];
  bool isDisabled = false;
  String documentStatus = "";
  bool? crossCheckStatus = false;
  bool? calculationBasedOnLRLevel = false;
  bool? manualFreightAmount = false;
  bool? holdLR = false;
  List<String> existingBarcodes = [];
  bool writePermission = false;
  bool cancelPermission = false;
  bool deletePermission = false;
  bool submitPermission = false;
late Future<List<String>> fetchConsigneeFuture;

  @override
  void initState() {
    super.initState();
    setConsignor();
    fetchLocation();
    checkCancelPermission();
    checkSubmitPermission();
    checkWritePermission();
    checkdeletePermission();
    docstatus.text = "-1";
    fetchConsigneeFuture = fetchConsignee();
    if (widget.name != "" && widget.data.isEmpty) {
      fetchLR();
      setState(() {
        documentStatus = "Not Saved";
      });
    }
    else{
      setData();
    }
    setDate();
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
    freight.dispose();
    lrCharge.dispose();
    manualWeight.dispose();
    loadingCharges.dispose();
    totalFreight.dispose();
    deliveredOn.dispose();
    boxDelivered.dispose();
    totalItems.dispose();
    itemName.dispose();
    itemWeight.dispose();
    itemVolume.dispose();
    itemBarcode.dispose();
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

  setDate() {
    final DateTime now = DateTime.now();
    DateTime formattedDate = DateTime(now.year, now.month, now.day);
    if (docstatus.text == "-1") {
      date.text = formattedDate.toString().split(" ")[0];
    }
  }

  void setData() {
    Map data = widget.data;
    print(data);

    lrType.text = data["lr_type"]?? "";
    collectionRequest.text = data["collection_request"]?? "";
    consignor.text = data["consignor"]?? "";

    fetchConsigneeFuture  = fetchConsignee();
  }

   Future<void> checkWritePermission() async {
    ApiService apiService = ApiService();
    try {
      Object body = {
        "doctype": "LR",
        "perm_type": "write",
      };
      final response =  await apiService.checkPermission(ApiEndpoints.authEndpoints.hasPermission, body);
      setState(() {
        writePermission = response;
      });
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> checkdeletePermission() async {
    ApiService apiService = ApiService();
    try {
      Object body = {
        "doctype": "LR",
        "perm_type": "delete",
      };
      final response =  await apiService.checkPermission(ApiEndpoints.authEndpoints.hasPermission, body);
      setState(() {
        deletePermission = response;
      });
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> checkCancelPermission() async {
    ApiService apiService = ApiService();
    try {
      Object body = {
        "doctype": "LR",
        "perm_type": "cancel",
      };
      final response =  await apiService.checkPermission(ApiEndpoints.authEndpoints.hasPermission, body);
      setState(() {
        cancelPermission = response;
      });
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> checkSubmitPermission() async {
    ApiService apiService = ApiService();
    try {
      Object body = {
        "doctype": "LR",
        "perm_type": "write",
      };
      final response =  await apiService.checkPermission(ApiEndpoints.authEndpoints.hasPermission, body);
      setState(() {
        submitPermission = response;
      });
    }
    catch (e) {
      rethrow;
    }
  }

  Future<List<String>> fetchRequest() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Collection Request",
      "filters": [
        ["status", "=", "Ready to Load"]
      ],
      "limit_page_length": 0,
    };
    try {
      final response = await apiService.getLinkedNames(
          ApiEndpoints.authEndpoints.getList, body);
      return response;
    } catch (e) {
      throw "Fetch Error";
    }
  }

  Future<Map<String, dynamic>> fetchLR() async {
    setState(() {
      isLoading = true;
    });
    final ApiService apiService = ApiService();
    try {
      final response = await apiService
          .getDocument('${ApiEndpoints.authEndpoints.LR}/${widget.name}');
      setState(() {
        date.text = response["date"] ?? "";
        collectionRequest.text = response["collection_request"] ?? "";
        logsheet.text = response["logsheet"] ?? "";
        consignor.text = response["consignor"] ?? "";
        consignee.text = response["consignee"] ?? "";
        destination.text = response["destination"] ?? "";
        boxCount.text =
            response["box_count"] != 0 ? response["box_count"].toString() : "0";
        crossCheckStatus = response["cross_check_status"] == 0 ? false : true;
        calculationBasedOnLRLevel =
            response["calculation_based_on_lr_level"] == 0 ? false : true;
        manualWeight.text = response["manual_weight"] != 0
            ? response["manual_weight"].toString()
            : "0";
        manualFreightAmount =
            response["manual_freight_amount"] == 0 ? false : true;
        freight.text =
            response["freight"] != 0 ? response["freight"].toString() : "0";
        lrCharge.text = response["lr_charges"] != 0
            ? response["lr_charges"].toString()
            : "0";
        loadingCharges.text = response["loading_charges"] != 0
            ? response["loading_charges"].toString()
            : "0";
        totalFreight.text = response["total_freight"] != 0
            ? response["total_freight"].toString()
            : "0";
        invoiceNo.text = response["invoice_number"] != "" ? response["invoice_number"].toString() : "";
        holdLR = response["hold_lr"] != 0 ? true : false;
        releaseDate.text = response["release_date"] ?? "";
        reasonForHold.text = response["reason_for_the_hold"] ?? "";
        deliveredOn.text = response["delivered_on"] ?? "";
        totalItems.text = response["total_items"] != 0
            ? response["total_items"].toString()
            : "0";
        remarks.text = response["remarks"] ?? "";
        docstatus.text = response["docstatus"].toString();
        totalVG.text = response['value_of_the_goods'].toString();
        totalWeight.text = response["total_weight"].toString();
        documentStatus = response["docstatus"] == 0 ? "Draft" : response["docstatus"] == 1 ? "Submitted" : "Cancelled";
        items = (response["items"] as List).map((item) {
          return (item as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, value.toString()));
        }).toList();
        if(response['items_count'].length > 0){
          itemsCount = (response['items_count'] as List).map((item) {
            return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
          }).toList();
        }
        if (response['docstatus'] != 0) {
          isDisabled = true;
        }
        isLoading = false;
      });
      return response;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      throw "Fetch Error $e";
    }
  }

  Future<void> setConsignor() async {
    final ApiService apiService = ApiService();

    try {
      Object body = {
        "doctype": "Collection Request",
        "fields": ['*'],
        "filters": [
          ['status', '=', 'Ready to Load']
        ],
        "limit_page_length": 0,
      };
      final response = await apiService.fetchFieldData(
          ApiEndpoints.authEndpoints.getList, body);
      setState(() {
         Map<String, Map<String, dynamic>> transformData = {};
      for(var item in response) {
          var name = item['name'];
          transformData[name] = item;
      }
      print(transformData);
        CR = transformData;
      });
      print("consignorList $consignorList");
    } catch (e) {
      throw "Fetch Error $e";
    }
  }

  Future<List<String>> fetchItem() async {
    // print("date ${date.text}");
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Item",
      "filters": [
        ["customer", "=", consignor.text]
      ],
      // "fields": ['name', ]
      "limit_page_length": 0,
    };
    try {
      final response = await apiService.getLinkedNames(
          ApiEndpoints.authEndpoints.getList, body);
      return response;
    } catch (e) {
      throw "Fetch Error";
    }
  }

  Future<List<String>> fetchLogsheet() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Logsheet",
      "filters": [
        ["status", "=", "0"]
      ],
      "limit_page_length": 0,
    };
    try {
      final response = await apiService.getLinkedNames(
          ApiEndpoints.authEndpoints.getList, body);
      return response;
    } catch (e) {
      throw "Fetch Error";
    }
  }

  Future<List<String>> fetchConsignor() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Customer",
      "filters": [
        ["custom_party_type", "=", "Consignor"]
      ],
      "limit_page_length": 0,
    };
    try {
      final response = await apiService.getLinkedNames(
          ApiEndpoints.authEndpoints.getList, body);
      return response;
    } catch (e) {
      throw "Fetch Error";
    }
  }
  Future<List<String>> fetchConsignee() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Consignor List",
      "filters": [
        ['consignor', '=', consignor.text]
      ],
      "fields": ['parent'],
      "parent": "Customer",
      "limit_page_length": 0,
    };
    try {
      final response =
          await apiService.getList(ApiEndpoints.authEndpoints.getList, body);
      print("response_start0");
      print(response);
      setState(() {
        consigneeList =
            response.map((item) => item['parent'].toString()).toList();
      });
      print(consigneeList);
      return consigneeList;
    } catch (e) {
      throw "Fetch Error";
    }
  }

  Future<void> fetchLocation() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Customer",
      "filters": [
        ["custom_party_type", "=", "Consignee"]
      ],
      "fields": ['name', 'custom_location'],
      "limit_page_length": 0,
    };
    try {
      final response = await apiService.fetchFieldData(
          ApiEndpoints.authEndpoints.getList, body);
      print("$response ========================location");
      setState(() {
        Map<String, Map<String, dynamic>> transformData = {};
      for(var item in response) {
          var name = item['name'];
          transformData[name] = item;
      }
        consigneeDocList = transformData;
      });
    } catch (e) {
      throw "Fetch Error";
    }
  }

  void submitDoc() async {
    final ApiService apiService = ApiService();
    final body = {"docstatus": 1};
    try {
      final response = await apiService.updateDocument(
          '${ApiEndpoints.authEndpoints.LR}/${widget.name}', body);
      if (response == "200") {
        Fluttertoast.showToast(
            msg: "Document Submitted successfully",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LRView(name: widget.name, data: const {},)));
        }
        // initState();
      } else {
        
      }
    } catch (e) {
      Fluttertoast.showToast(
            msg: "Failed to submit document $e",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
    }
  }

  void deleteDoc() async {
    final ApiService apiService = ApiService();
    try {
      final response = await apiService
          .deleteDocument('${ApiEndpoints.authEndpoints.LR}/${widget.name}');
      if (response == "202") {
        Fluttertoast.showToast(
            msg: "Document deleted successfully",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
        if (mounted) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const LRList()));
        }
      } else {
        Fluttertoast.showToast(
            msg: "Failed to delete document",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
      }
    } catch (error) {
       Fluttertoast.showToast(
            msg: "Failed to delete document $error",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
    }
  }

  void cancelDoc() async {
    final ApiService apiService = ApiService();
    final body = {"docstatus": 2};
    try {
      final response = await apiService.updateDocument(
          '${ApiEndpoints.authEndpoints.LR}/${widget.name}', body);
      if (response == "200") {
        Fluttertoast.showToast(
            msg: "Document Canceled successfully",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
        if (mounted) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const LRList()));
        }
      } else {
        Fluttertoast.showToast(
            msg: "Failed to cancel document",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
      }
    } catch (error) {
      Fluttertoast.showToast(
            msg: "Failed to cancel document $error",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
    }
  }

  Future<void> _showItemDialog({dynamic item, int? index}) async {
    itemName.text = item?['item_code'] ?? "";
    itemWeight.text = item?['weight'] ?? "";
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
                      const SizedBox(
                        height: 10,
                      ),
                      // DialogTextField(
                      //   controller: itemName,
                      //   keyboardType: TextInputType.name,
                      //   readOnly: isDisabled,
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
                              validator: (value) {
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
                            return DialogAutoComplete(
                              validator: (value) {
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
                          }
                        },
                      ),
                      const SizedBox(height: 10,),
                      DialogTextField(
                        controller: itemWeight,
                        keyboardType: TextInputType.number,
                        readOnly: isDisabled,
                        labelText: "Weight",
                      ),
                      const SizedBox(height: 10,),
                      DialogTextField(
                        controller: itemBarcode,
                        keyboardType: TextInputType.text,
                        readOnly: isDisabled,
                        labelText: "Barcode",
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                    child: Text(item == null ? 'Cancel' : 'Delete'),
                    onPressed: () {
                      if (item == null) {
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          // items.removeWhere((item) => item.length == index);
                          items.remove(item);
                          existingBarcodes.remove(itemBarcode.text);
                        });
                        Navigator.of(context).pop();
                      }
                    }),
                TextButton(
                  child: Text(item == null ? 'Add' : 'Save'),
                  onPressed: () {
                    if (item == null) {
                      setState(() {
                        items.add({
                          "item_code": itemName.text,
                          "weight": itemWeight.text,
                          "barcode": itemBarcode.text,
                        });
                      });
                      itemName.clear();
                      itemWeight.clear();
                      itemBarcode.clear();
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        items[index!]["item_code"] = itemName.text;
                        items[index]["weight"] = itemName.text;
                        items[index]["barcode"] = itemBarcode.text;
                      });
                      itemName.clear();
                      itemWeight.clear();
                      itemBarcode.clear();
                      Navigator.of(context).pop();
                    }
                  },
                )
              ]);
        });
  }

  void _showItems(BuildContext context){
    TextEditingController searchController = TextEditingController();
    List<String> filteredItems = searchItemList;


    fetchItem()
      .then((response) => {
      setState(() {
        searchItemList = [];
        searchItemList = response;
        filteredItems = searchItemList;
      })
    }).catchError((onError) => {throw "Error: " + onError});

    showDialog(
      context: context,
      builder: (BuildContext context){
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Selecting Items"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search......',
                  suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            filteredItems = searchItemList;
                          });
                        },
                      ),
                      ),
                      onChanged: (value) {
                      setState(() {
                        filteredItems = searchItemList
                            .where((item) => item
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                ),
                const SizedBox(height: 10),
                  MultiSelect(
                    items: filteredItems,
                    selectedItems: selectedItems,
                    onSelectedItemsListChanged:
                        (List<String> newSelectedItems) {
                      setState(() {
                        selectedItems = newSelectedItems;
                        // loadingStaffs.text = selectedLoadingStaffs.join(', ');
                        // loadingStaffDict = selectedLoadingStaffs.map((staff) {
                        //   return {
                        //     'loading_staff': staff,
                        //   };
                        // }).toList();
                        selectedItems.map((item) {
                          items.add({"item_code": item});
                        });
                      });
                    },
                  ),
              ],),
          );
        });
    });
  }

  Future<void> submitData() async {
      setState(() {
        isLoading = true;
      });
      final ApiService apiService = ApiService();
      final body = {
        "doctype": "LR",
        "date": date.text,
        "collection_request": collectionRequest.text,
        "consignor": consignor.text,
        "consignee": consignee.text,
      "invoice_number": invoiceNo.text,
        "destination": destination.text,
        "box_count": boxCount.text,
        "cross_check_status": crossCheckStatus,
        "calculation_based_on_lr_level": calculationBasedOnLRLevel,
        "manual_weight": manualWeight.text,
        "freight": freight.text,
        "lr_charge": lrCharge.text,
        "loading_charges": loadingCharges.text,
        "manual_freight_amount": manualFreightAmount,
        "hold_lr": holdLR,
        "release_date": releaseDate.text,
        "reason_for_the_hold": reasonForHold.text,
        "items": items,
        "total_freight": totalFreight.text,
        "box_delivered": boxDelivered.text,
        "total_items": totalItems.text,
        "remarks": remarks.text,
        "docstatus": 0,
      };
      try {
        if(docstatus.text ==  "1"){
          Fluttertoast.showToast(
            msg: "Cannot save the Submitted Document",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
        }
        if(docstatus.text =="0"){
          final response = await apiService.updateDocument(
            '${ApiEndpoints.authEndpoints.LR}/${widget.name}', body);
        if (response == "200") {
          Fluttertoast.showToast(
            msg: "Document Saved Successfully",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
          if (mounted) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LRView(name: widget.name, data: const {},)));
          }
        }
        }
        if(docstatus.text == "-1") {
          final response =
          await apiService.createDocument(ApiEndpoints.authEndpoints.LR, body);
      if (response[0] == 200) {
        Fluttertoast.showToast(
            msg: "Document Saved Successfully",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LRView(data: {"collection_request": collectionRequest.text, "consignor": consignor.text},)));
        }
        }
        }
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Failed to Save $error",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5);
      }
  }

  // void _openBarcodeScanner() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => BarcodeScanner(
  //         onScanResult: (scanResult) {
  //           setState(() {
  //             if (items.isEmpty) {
  //               items.add({
  //                 'item_code': itemName.text,
  //                 'barcode': scanResult,
  //               });
  //             } else {
  //               items.add({
  //                 'item_code': items[items.length - 1]['item_code'].toString(),
  //                 'barcode': scanResult,
  //               });
  //             }
  //             itemName.clear();
  //             itemBarcode.clear();
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }
  // void _openBarcodeScanner() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => BarcodeScanner(
  //         onScanResult: (scanResult) {
  //           print("$scanResult scanresult: ");
  //           setState(() {
  //             if (items.isNotEmpty && items[items.length - 1]['barcode'] == '') {
  //               // items.add({
  //               //   'item_code': itemName.text,
  //               //   'barcode': scanResult,
  //               // });
  //               items[items.length - 1]['barcode'] = scanResult;
  //             } else if(items.isEmpty){
  //               items.add({
  //                 'item_code': '',
  //                 'weight': '',
  //                 'barcode': scanResult,
  //               });
  //             } else {
  //               items.add({
  //                 'item_code': items[items.length - 1]['item_code'].toString(),
  //                 'weight': items[items.length - 1]['weight'].toString(),
  //                 'barcode': scanResult,
  //               });
  //             }
  //             itemName.clear();
  //             itemBarcode.clear();
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }

  void _handleScannedBarcodes(List<String> barcodes) {
    setState(() {
      for (String barcode in barcodes) {
          setState(() {
            existingBarcodes.add(barcode);
          });
        // items.add({
        //   'item_code': '', // Placeholder for item code
        //   'barcode': barcode, // Add the scanned barcode
        // });
        if (items.isNotEmpty && items[items.length - 1]['barcode'] == '') {
                items[items.length - 1]['barcode'] = barcode;
              } else {
                items.add({
                  'item_code': items[items.length - 1]['item_code'].toString(),
                  'barcode': barcode,
                });
              }
              itemName.clear();
              itemBarcode.clear();
      }
    });
  }

  void _openBarcodeScanner() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            'Scan Barcodes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Choose a Scanning Device'),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                        ),
                      ),
                    ),
                    child: const Text('Mobile Scanner'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MobileScanner(
                          allowedBarcodes: [],
                          doctype: "LR",
                          existingBarcodes: existingBarcodes,
                          onSaveBarcodes: (barcodes) => _handleScannedBarcodes(barcodes),
                        ),
                      ),
                    );
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                    ),
                    child: const Text('Bluetooth Scanner'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BluetoothBarcodeScanner(
                          doctype: "LR",
                          existingBarcodes: existingBarcodes,
                          allowedBarcodes: [],
                          onSaveBarcodes: _handleScannedBarcodes,
                        ),
                      ),
                    );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    
    
    
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => BluetoothBarcodeScanner(
    //       onSaveBarcodes: _handleScannedBarcodes,
    //     ),
    //   ),
    // );
  }


  Future<void> _showDatePicket(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2150),
    );

    if (picked != null) {
      setState(() {
        releaseDate.text = "${picked.toLocal()}".split(" ")[0];
      });
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const LRList()));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('LR Form $documentStatus'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: PopupMenuButton(
                itemBuilder: (context) => [
                  if (docstatus.text =="0" && submitPermission)
                    const PopupMenuItem(
                      value: 1,
                      child: Text(
                        'Submit',
                        style: TextStyle(),
                      ),
                    ),
                  if (docstatus.text =="0" && deletePermission)
                    const PopupMenuItem(
                      value: 0,
                      child: Text('Delete'),
                    ),
                  if (docstatus.text ==  "1" && cancelPermission)
                    const PopupMenuItem(
                      value: 2,
                      child: Text('Cancel'),
                    ),
                ],
                onSelected: (value) {
                  setState(() {
                    if (value == 1) {
                      submitDoc();
                    } else if (value == 0) {
                      deleteDoc();
                    } else if (value == 2) {
                      cancelDoc();
                    }
                  });
                },
                child: const Icon(
                  Icons.more_vert,
                  size: 28.0,
                ),
              ),
            ),
          ],
          // flexibleSpace: SafeArea(child: Text(documentStatus, style: TextStyle(color: Colors.red),Align(alignment: Alignment.centerLeft,),),left: false,),
        ),
        drawer: const AppDrawer(),
        backgroundColor: Colors.white,
        body: isLoading
        ? const Center(child: CircularProgressIndicator(),)
        : SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 5),
                    FieldText(
                        controller: date,
                        labelText: "Date",
                        readOnly: true,
                        keyboardType: TextInputType.none),
                    // if (docstatus.text == "-1" && widget.data.isEmpty) const SizedBox(height: 5),
                    // if (docstatus.text == "-1" && widget.data.isEmpty)
                    //   DropDown(
                    //     labelText: 'LR Type',
                    //     // controller: ,
                    //     items: const [
                    //       'By Collection Request',
                    //       'By Log Sheet',
                    //     ],
                    //     selectedItem: selectedLrType,
                    //     onChanged: (String? newValue) {
                    //       setState(() {
                    //         selectedLrType = newValue;
                    //         lrType.text = newValue.toString();
                    //       });
                    //     },
                    //   ),
                    // if (docstatus.text != "-1" || widget.data.isNotEmpty) const SizedBox(height: 5),
                    // if (docstatus.text != "-1" || widget.data.isNotEmpty)
                    //   FieldText(
                    //       controller: lrType,
                    //       labelText: "LR Type",
                    //       readOnly: true,
                    //       keyboardType: TextInputType.none),
                    // if (lrType.text == "By Collection Request" && widget.data.isNotEmpty)
                    if (widget.data.isNotEmpty || docstatus.text != "-1")
                    const SizedBox(height: 15),
                    // if (lrType.text == "By Collection Request" && widget.data.isNotEmpty)
                    if (widget.data.isNotEmpty || docstatus.text != "-1")
                    FieldText(
                      controller: collectionRequest,
                      labelText: "Collection Request",
                      keyboardType: TextInputType.none,
                      readOnly: true,
                    ),
                    // if (selectedLrType == "By Collection Request" && docstatus.text == "-1" && widget.data.isEmpty)
                    if(docstatus.text == "-1" && widget.data.isEmpty)
                  const SizedBox(height: 25),
                // if (selectedLrType == "By Collection Request" && docstatus.text == "-1" && widget.data.isEmpty)
                    if(docstatus.text == "-1" && widget.data.isEmpty)
                  FutureBuilder<List<String>>(
                    future: fetchRequest(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return AutoComplete(controller: collectionRequest, readOnly: true, hintText: 'Collection Request',
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                          options: requestList,
                        );
                      } else if (snapshot.hasData) {
                        requestList = snapshot.data!;
                        return AutoComplete(
                          controller: collectionRequest,
                          hintText: 'Collection Request',
                          onSelected: (String selection) {
                            print(selection);
                            // // setState(() {
                            // int index = consignorList.indexOf(selection);
                            // print("index: $index");
                            consignor.text =
                                CR[selection]!['consignor'] ?? "";
                            fetchConsigneeFuture = fetchConsignee();
                          },
                          options: requestList,
                        );
                      } else {
                        // return AutoComplete(
                        //   controller: collectionRequest,
                        //   hintText: 'Collection Request',
                        //   onSelected: (String selection) {
                        //     print('You selected: $selection');
                        //   },
                        //   options: requestList,
                        // );
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                    if (logsheet.text != "") const SizedBox(height: 15),
                    if (logsheet.text != "")
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
                    if(docstatus.text != "-1")
                    const SizedBox(height: 15),
                    if(docstatus.text != "-1")
                    FieldText(
                      controller: consignee,
                      labelText: "Consignee",
                      keyboardType: TextInputType.none,
                      readOnly: true,
                    ),
                    if(docstatus.text == "-1")
                    const SizedBox(height: 10),
                    if(docstatus.text == "-1")
                // AutoComplete(
                //   options: consigneeList,
                //   hintText: "Consignee Name",
                //   onSelected: (String selection) {
                //     print(selection);
                //     destination.text =
                //         consigneeDocList[selection]!['custom_location'];
                //   },
                //   controller: consignee,
                // ),
                 FutureBuilder<List<String>>(
                    future: fetchConsigneeFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return AutoComplete(controller: consignee, readOnly: true, hintText: 'Consignee',
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                          options: consigneeList,
                        );
                      } else if (snapshot.hasData) {
                        consigneeList = snapshot.data!;
                        return AutoComplete(
                          controller: consignee,
                          hintText: "Consignee",
                          onSelected: (String selection) {
                            print(selection);
                            // setState(() {
                            destination.text =
                          consigneeDocList[selection]!['custom_location'];
                          },
                          options: consigneeList,
                        );
                      } else {
                        // return FieldText(controller: consignee, labelText: "Consignee", keyboardType: TextInputType.none, readOnly: false,);
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                    const SizedBox(height: 15),
                    FieldText(
                      controller: destination,
                      labelText: "Destination",
                      keyboardType: TextInputType.none,
                      readOnly: true,
                    ),
                     const SizedBox(height: 10),
                FieldText(
                  controller: invoiceNo,
                  labelText: "Invoice Number",
                  keyboardType: TextInputType.name,
                ),
                    if(docstatus.text != "-1")
                    const SizedBox(height: 15),
                    if(docstatus.text != "-1")
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
                    if (calculationBasedOnLRLevel == true)
                      FieldText(
                        controller: manualWeight,
                        labelText: "Manual Weight",
                        readOnly: isDisabled,
                        keyboardType: TextInputType.number,
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 15),
                    //   child: Row(children: [
                        // Checkbox(
                        //   value: manualFreightAmount,
                        //   onChanged: (newBool) {
                        //     if (isDisabled == false) {
                        //       setState(() {
                        //         manualFreightAmount = newBool;
                        //         freight.text = "";
                        //       });
                        //     }
                        //   },
                        //   activeColor: Colors.black,
                        // ),
                        // const SizedBox(width: 10),
                        // const Text("Manual Freight Amount"),
                      // ]),
                    // ),
                    // if(docstatus.text != "-1")
                    // const SizedBox(height: 25),
                    // if(docstatus.text != "-1")
                    // FieldText(
                    //     controller: lrCharge,
                    //     labelText: 'LR Charge',
                    //     readOnly: true,
                    //     keyboardType: TextInputType.number,
                    //     obscureText: false),
                    if(docstatus.text != "-1")
                    const SizedBox(height: 10),
                    if(docstatus.text != "-1")
                    FieldText(
                        controller: totalFreight,
                        labelText: 'Total Freight',
                        keyboardType: TextInputType.number,
                        obscureText: false,
                        readOnly: true),
                        if(docstatus.text != "-1")
                    const SizedBox(height: 10),
                        if(docstatus.text != "-1")
                    if(deliveredOn.text != "")
                    TextArea(
                        controller: deliveredOn,
                        readOnly: true,
                        labelText: "Delivered On",
                        keyboardType: TextInputType.datetime),
                    const SizedBox(height: 10,),
                    FieldText(controller: totalVG, labelText: "Total Value of the Goods", keyboardType: TextInputType.number, readOnly: isDisabled,),
                    if(docstatus.text == "1")
                    const SizedBox(height: 10,),
                    if(docstatus.text == "1")
                    FieldText(controller: totalWeight, labelText: "Total Weight", keyboardType: TextInputType.none, readOnly: true,),
                    const SizedBox(height: 25),
                    if(itemsCount.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Items Count"),
                        ],
                      ),
                    ),
                    if(itemsCount.isNotEmpty)
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
                              itemCount: itemsCount.length,
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
                                      trailing: Text("${itemsCount[index]['count']}"),
                                      title: Text(
                                          '${itemsCount[index]["item_code"]}'),
                                      // onTap: () {setState(() {
                                      //   itemsCount[index]['count'] = "${(itemsCount[index]['count']) + 1}";
                                      // });},
                                      onTap: null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
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
                              onPressed: items.isNotEmpty ? () {
                                _openBarcodeScanner();
                              }: null,
                              child: const Icon(Icons.camera),
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
                    MyButton(
                        onTap: isDisabled && writePermission
                            ? () {
                                Fluttertoast.showToast(
                                    msg: "Can't able to save",
                                    gravity: ToastGravity.BOTTOM,
                                    fontSize: 16.0);
                              }
                            : submitData,
                        name: "Save")
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
