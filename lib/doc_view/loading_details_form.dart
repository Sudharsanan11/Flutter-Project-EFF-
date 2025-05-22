import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_list/loading_details_list.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/dialog_text.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:erpnext_logistics_mobile/fields/text_area.dart';
import 'package:erpnext_logistics_mobile/modules/barcode_scanner.dart';
import 'package:erpnext_logistics_mobile/modules/mobile_scanner.dart';
import 'package:erpnext_logistics_mobile/modules/scanner.dart';
import 'package:erpnext_logistics_mobile/modules/test_scan.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class LoadingDetailsForm extends StatefulWidget {
  final String name;
  final Map data;
  const LoadingDetailsForm({super.key, this.name = "", required this.data});

  @override
  State<LoadingDetailsForm> createState() => _LoadingDetailsFormState();
}

class _LoadingDetailsFormState extends State<LoadingDetailsForm> {

  final TextEditingController supervisor = TextEditingController();
  final TextEditingController loadingStaffs = TextEditingController();
  final TextEditingController driver = TextEditingController();
  final TextEditingController totalBoxCount = TextEditingController();
  final TextEditingController gdm = TextEditingController();
  final TextEditingController branch = TextEditingController();
  final TextEditingController status = TextEditingController();
  final TextEditingController lr = TextEditingController();
  final TextEditingController boxCount = TextEditingController();
  final TextEditingController itemName = TextEditingController();
  final TextEditingController itemBoxCount = TextEditingController();
  final TextEditingController itemBarcode = TextEditingController();
  final TextEditingController deliveryType = TextEditingController();
  final TextEditingController vehicle = TextEditingController();
  final TextEditingController barcodes = TextEditingController();
  final TextEditingController docstatus = TextEditingController();
  final TextEditingController misMatchItem = TextEditingController();
  final TextEditingController misMatchLR = TextEditingController();
  final TextEditingController misMatchBoxCount = TextEditingController();

  List<Map<String, String>> LRItems = [];
  List<String> selectedLoadingStaffs = [];
  List<Map<String, String>> loadingStaffDict = [];
  List<String> loadingStaffItems = [];
  List<String> itemList = [];
  List<Map<String, String>> misMatchItems = [];
  List<Map<String, String>> items = [];
  List<Map<String, Map<String ,List<String>>>> allowedBarcodes = [];
  List<String> existingBarcodes = [];
  bool isLoading = false;
  List<String> barcode_list = [];

  @override
  void initState() {
    super.initState();
    docstatus.text = "-1";
    fetchLoadingStaff();
    if(widget.name == "" && widget.data.isNotEmpty){
      setData();
    }
    else if(widget.name != ""){
      fetchLoadingDetails();
    }
  }

  @override
  void dispose() {
    selectedLoadingStaffs = [];
    loadingStaffs.dispose();
    loadingStaffDict = [];
    loadingStaffItems = [];
    super.dispose();
  }

  setData() {
    Map data = widget.data;

  supervisor.text = data['supervisor'] ?? "";
  driver.text = data['driver'] ?? "";
  gdm.text = data['gdm'] ?? "";
  branch.text = data['branch'] ?? "";
  deliveryType.text = data['delivery_type'] ?? "";
  vehicle.text = data['vehicle'] ?? "";

    loadingStaffItems = (data["loading_staffs"] as List).map<String>((item) {
          return item['loading_staff'].toString();
        }).toList();
        loadingStaffDict = (data["loading_staffs"] as List).map<Map<String, String>>((item){
          return {"loading_staff": item['loading_staff'].toString()};
        }).toList();
        selectedLoadingStaffs = loadingStaffItems;
        loadingStaffs.text = loadingStaffItems.join(', ').toString();

    // allowedBarcodes = (data['allowed_barcodes'] as List<dynamic>?)
    // ?.map((e) => e is Map<String, dynamic>
    //     ? e.map((key, value) => MapEntry(key, List<String>.from(value as List)))
    //     : <String, List<String>>{})
    // .toList() ?? [];
    allowedBarcodes = (data['allowed_barcodes'] as List<dynamic>?)
        ?.map((e) => e is Map<String, dynamic>
            ? e.map((key, value) => MapEntry(
                key,
                (value as Map<String, dynamic>).map((itemKey, itemValue) => MapEntry(
                      itemKey,
                      List<String>.from(itemValue as List<dynamic>),
                    )),
              ))
            : <String, Map<String, List<String>>>{})
        .toList() ??
    [];
    print("allowedBarcodes $allowedBarcodes");

    LRItems = (data['loading_lrs'] as List).map((item) {
          return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
            }).toList();
      
  }

   Future<List<String>> fetchLoadingStaff() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Employee",
      "filters": [
        ["designation", "=", "Loading Staff"],
        ["status", "=", "Active"]
      ],
      "limit_page_length": 0,
    };
    try {
      final response = await apiService.getLinkedNames(
          ApiEndpoints.authEndpoints.getList, body);
      print(response);
      return response;
    } catch (e) {
      throw "Fetch Error";
    }
  }

  Future<List<String>> fetchItem() async {
    // print("date ${date.text}");
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Item",
      "filters": [
        ["is_customer_provided_item", "=", 1]
      ],
      "limit_page_length": 0,
    };
    try {
      final response = await apiService.getLinkedNames(
          ApiEndpoints.authEndpoints.getList, body);
      print(response);
      return response;
    } catch (e) {
      throw "Fetch Error";
    }
  }

  Future<void> fetchLoadingDetails () async{
    final ApiService apiService = ApiService();
    setState(() {
      isLoading = true;
    });

    try {
      final response = await apiService.getDocument('${ApiEndpoints.authEndpoints.loadingDetails}/${widget.name}',);
      print(response);
      setState(() {
        deliveryType.text = response["delivery_type"] ?? "";
        loadingStaffItems = (response["loading_staffs"] as List).map<String>((item) {
          return item['loading_staff'].toString();
        }).toList();
        loadingStaffDict = (response["loading_staffs"] as List).map<Map<String, String>>((item){
          return {"loading_staff": item['loading_staff'].toString()};
        }).toList();
        selectedLoadingStaffs = loadingStaffItems;
        loadingStaffs.text = loadingStaffItems.join(', ').toString();
        docstatus.text = response['docstatus'].toString();
        vehicle.text = response['vehicle'] ?? "";
        supervisor.text = response["supervisor"] ?? "";
        driver.text = response["driver"] ?? "";
        totalBoxCount.text = response["total_box_count"]?.toString() ?? "0";
        gdm.text = response["gdm"] ?? "";
        branch.text = response["branch"] ?? "";
        barcodes.text = response['barcodes'];
        status.text = response["status"] ?? "";
        LRItems = (response['loading_lrs'] as List).map((item) {
          return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
            }).toList();
        items = (response['loading_items'] as List).map((item) {
          return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
            }).toList();
        misMatchItems = (response['mismatched_items'] as List).map((item) {
          return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
            }).toList();
        isLoading = false;
      });
    }
    catch (e) {
      print(e);
    }
  }

  Future<void> fetch_allowed_barcodes() async{
    try{
      final ApiService apiService = ApiService();
      final body = {
        "source_name": gdm.text,
      };

      final response = await apiService.getDoc(ApiEndpoints.authEndpoints.gdmloadingDetails, body);

        setState(() {
          allowedBarcodes = (response['allowed_barcodes'] as List<dynamic>?)
              ?.map((e) => e is Map<String, dynamic>
                  ? e.map((key, value) => MapEntry(
                        key,
                        (value as Map<String, dynamic>).map((itemKey, itemValue) => MapEntry(
                              itemKey,
                              List<String>.from(itemValue as List<dynamic>),
                            )),
                      ))
                  : <String, Map<String, List<String>>>{})
              .toList() ??
          [];
        });
    }
    catch(e){
      Fluttertoast.showToast(msg: "Failed to fetch allowed barcodes", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
    }
  }

  Future<void> saveData () async{
    setState(() {
      isLoading = true;
    });
    final ApiService apiService = ApiService();
    final body = {
      "supervisor" : supervisor.text,
      "loading_staffs" : loadingStaffDict,
      "driver" : driver.text,
      "total_box_count" : totalBoxCount.text,
      "gdm" : gdm.text,
      "branch" : branch.text,
      "loading_lrs": LRItems,
      "barcodes": barcodes.text,
    };
    try {
      if(docstatus.text == "-1"){
        final response = await apiService.createDocument(ApiEndpoints.authEndpoints.loadingDetails, body);
        print(response);
        if(response[0] == 200) {
          Fluttertoast.showToast(msg: "Document saved Successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
          Navigator.push(context, 
          MaterialPageRoute(builder: (context) => LoadingDetailsForm(name: response[1],data: const {})));
        }
      }
      else if(docstatus.text == "0") {
        final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.loadingDetails}/${widget.name}', body);
        print(response);
        if(response == "200") {
          Fluttertoast.showToast(msg: "Document updated successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
          Navigator.push(context, 
          MaterialPageRoute(builder: (context) => LoadingDetailsForm(name: widget.name,data: const {})));
        }
      }
      else{
        Fluttertoast.showToast(msg: "Failed to save document", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      }
    }
    catch(error) {
      setState(() {
      isLoading = false;
    });
        Fluttertoast.showToast(msg: "Failed to save document $error", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      print(error);
    }
  }

  void submitDoc() async{
    final ApiService apiService = ApiService();
    final body = {
      "docstatus" : 1
    };
    try {
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.loadingDetails}/${widget.name}', body);
      print(response);
      if(response == "200") {
        Fluttertoast.showToast(msg: "Document Submitted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => LoadingDetailsForm(name: widget.name, data: const {},)));
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
      final response = await apiService.deleteDocument('${ApiEndpoints.authEndpoints.loadingDetails}/${widget.name}');
      if(response == "202") {
        Fluttertoast.showToast(msg: "Document deleted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LoadingDetailsList()));
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
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.loadingDetails}/${widget.name}', body);
      if(response == "200") {
        Fluttertoast.showToast(msg: "Document Canceled successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LoadingDetailsList()));
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

   Future<void> _showLRItemDialog({dynamic item, int? index}) async {
    lr.text = item?['lr_no'] ?? "";
    boxCount.text = item?['box_count'] ?? "";
    itemBarcode.text = item?['barcodes'] ?? "";

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
                      const SizedBox(
                        height: 10,
                      ),
                      // DialogTextField(
                      //   controller: lr,
                      //   keyboardType: TextInputType.name,
                      //   labelText: "LR ID",
                      // ),
                      DialogTextField(controller: lr,labelText: "LR No.",keyboardType: TextInputType.none,readOnly: true,),
                      const SizedBox(
                        height: 10,
                      ),
                      DialogTextField(
                        controller: boxCount,
                        keyboardType: TextInputType.none,
                        labelText: "Account Pay",
                        readOnly: true,
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
                          LRItems.remove(item);
                        });
                        Navigator.of(context).pop();
                      }
                    }),
                TextButton(
                  child: Text(item == null ? 'Add' : 'Save'),
                  onPressed: () {
                    if (item == null) {
                      setState(() {
                        LRItems.add({
                          "lr_no": lr.text,
                          "box_count": boxCount.text,
                        });
                      });
                      lr.clear();
                      boxCount.clear();
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        LRItems[index!]["lr_no"] = lr.text;
                        LRItems[index]["box_count"] = boxCount.text;
                      });
                      lr.clear();
                      boxCount.clear();
                      Navigator.of(context).pop();
                    }
                  },
                )
              ]);
        });
  }

  // void _openBarcodeScanner() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => BarcodeScanner(
  //         onScanResult: (scanResult) {
  //           setState(() {

  //           barcode_list.add(scanResult);
  //           barcodes.text = barcode_list.join(",");
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }

  void _handleScannedBarcodes(List<String> barcode_list) {
    setState(() {
      if(barcodes.text.isNotEmpty){
        barcodes.text = "${barcodes.text},${barcode_list.join(",")}";
      }
      else{
        barcodes.text = barcodes.text + barcode_list.join(",");
      }
      barcode_list.map((barcode) => existingBarcodes.add(barcode));
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
                          doctype: "Loading Details",
                          allowedBarcodes: allowedBarcodes,
                          existingBarcodes:existingBarcodes,
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
                          allowedBarcodes: allowedBarcodes,
                          doctype: "Loading Details",
                          existingBarcodes: existingBarcodes,
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
  }

  Future<void> _showItemDialog({dynamic item, int? index}) async {
    itemName.text = item?['item_code'] ?? "";
    itemBoxCount.text = item?['box_count'] ?? "";
    itemBarcode.text = item?['barcodes'] ?? "";

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
                      // FutureBuilder<List<String>>(
                      //   future: fetchItem(),
                      //   builder: (context, snapshot) {
                      //     if (snapshot.hasError) {
                      //       return DialogAutoComplete(
                      //         validator: (value) {
                      //           if (value == null || value.isEmpty) {
                      //             return "Item Is Required";
                      //           }
                      //           return null;
                      //         },
                      //         hintText: 'Item Name',
                      //         controller: itemName,
                      //         onSelected: (String selection) {
                      //           print('You selected: $selection');
                      //           setState(() {
                      //             print("sele");
                      //             itemName.text = selection;
                      //           });
                      //         },
                      //         options: itemList,
                      //       );
                      //     } else if (snapshot.hasData) {
                      //       itemList = snapshot.data!;
                      //       return DialogAutoComplete(
                      //         validator: (value) {
                      //           if (value == null || value.isEmpty) {
                      //             return "Item Is Required";
                      //           }
                      //           return null;
                      //         },
                      //         controller: itemName,
                      //         hintText: 'Item Name',
                      //         onSelected: (String selection) {
                      //           itemName.text = selection;
                      //         },
                      //         options: itemList,
                      //       );
                      //     } else {
                      //       return DialogAutoComplete(
                      //         validator: (value) {
                      //           if (value == null || value.isEmpty) {
                      //             return "Item Is Required";
                      //           }
                      //           return null;
                      //         },
                      //         controller: itemName,
                      //         hintText: 'Item Name',
                      //         onSelected: (String selection) {
                      //           itemName.text = selection;
                      //         },
                      //         options: itemList,
                      //       );
                      //     }
                      //   },
                      // ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      // DialogTextField(
                      //   controller: itemBarcode,
                      //   keyboardType: TextInputType.text,
                      //   labelText: "Barcode",
                      // ),
                      DialogTextField(controller: itemName, labelText: "Item", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      DialogTextField(controller: itemBoxCount, keyboardType: TextInputType.none, labelText: "Box Count", readOnly: true,),
                      const SizedBox(height: 10,),
                      TextArea(controller: itemBarcode, keyboardType: TextInputType.text, labelText: "Barcode", readOnly: true,
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
                          "barcode": itemBarcode.text,
                        });
                      });
                      itemName.clear();
                      itemBoxCount.clear();
                      itemBarcode.clear();
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        items[index!]["item_code"] = itemName.text;
                        items[index]["barcode"] = itemBarcode.text;
                        items[index]["box_count"] = itemBoxCount.text;
                      });
                      itemName.clear();
                      itemBoxCount.clear();
                      itemBarcode.clear();
                      Navigator.of(context).pop();
                    }
                  },
                )
              ]);
        });
  }

  Future<void> _showMismatchItemDialog({dynamic item, int? index}) async {
    misMatchLR.text = item?['lr'] ?? "";
    misMatchBoxCount.text = item?['box_count'] ?? "";
    misMatchItem.text = item?['item_code'] ?? "";

    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('MisMatched Item'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 1.8,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      DialogTextField(controller: misMatchLR, labelText: "LR", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      DialogTextField(controller: misMatchItem, labelText: "Item Code", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      DialogTextField(controller: misMatchBoxCount, keyboardType: TextInputType.none, labelText: "Box Count", readOnly: true,),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      // DialogTextField(
                      //   controller: itemBarcode,
                      //   keyboardType: TextInputType.text,
                      //   labelText: "Barcode",
                      // ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      misMatchItem.clear();
                      misMatchLR.clear();
                      misMatchBoxCount.clear();
                      Navigator.of(context).pop();
                    }),
              ]);
        });
  }

  // void _showLR(BuildContext context) {
  //   TextEditingController searchController = TextEditingController();
  //   List<String> filteredItems = selectLR;

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: const Text('Select LR'),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextField(
  //                   controller: searchController,
  //                   decoration: InputDecoration(
  //                     hintText: 'Search...',
  //                     suffixIcon: IconButton(
  //                       icon: const Icon(Icons.clear),
  //                       onPressed: () {
  //                         searchController.clear();
  //                         setState(() {
  //                           filteredItems = selectLR;
  //                         });
  //                       },
  //                     ),
  //                   ),
  //                   onChanged: (value) {
  //                     setState(() {
  //                       filteredItems = selectLR
  //                           .where((item) => item
  //                               .toLowerCase()
  //                               .contains(value.toLowerCase()))
  //                           .toList();
  //                     });
  //                   },
  //                 ),
  //                 const SizedBox(height: 10),
  //                 MultiSelect(
  //                   items: filteredItems,
  //                   selectedItems: selectedLr,
  //                   onSelectedItemsListChanged:
  //                       (List<String> newSelectedItems) {
  //                     setState(() {
  //                       selectedLr = newSelectedItems;
  //                       lrSelected.text = selectedLr.join(', ');
  //                     });
  //                   },
  //                 ),
  //               ],
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: const Text('OK'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {return;}
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => const LoadingDetailsList()));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Loading Details"),
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
                // DropDown(
                //   labelText: "Entered By",
                //   items: const ["Supervisor", "Driver"],
                //   selectedItem: selectedEnteredBy,
                //   onChanged: (String? newValue){
                //     setState(() {
                //       selectedEnteredBy = newValue;
                //     });
                //   }
                // ),
                FieldText(controller: supervisor, labelText: "Supervisor", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10),
                FieldText(controller: loadingStaffs, labelText: "Loading Staffs", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10),
                FieldText(controller: vehicle, labelText: "vehicle", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10,),
                FieldText(controller: driver, labelText: "Driver", keyboardType: TextInputType.none, readOnly: true,),
                if(docstatus.text != "-1")
                const SizedBox(height: 10,),
                if(docstatus.text != "-1")
                FieldText(controller: totalBoxCount, labelText: "Total Box Count", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10),
                FieldText(controller: gdm, labelText: "GDM", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10),
                // DropDown(labelText: "Delivery Type", items: const ["Final Delivery", "Delivery to Branch", "Mixed"], selectedItem: deliveryType, onChanged: (String? newValue) {setState(() {
                //   deliveryType = newValue;
                //   dt.text
                // });}),
                FieldText(controller: deliveryType, labelText: "Delivery Type", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10),
                FieldText(controller: branch,keyboardType: TextInputType.name,labelText: "Branch",),
                if(docstatus.text != "-1")
                const SizedBox(height: 10),
                if(docstatus.text != "-1")
                FieldText(controller: status,labelText: "Status",keyboardType: TextInputType.none,readOnly: true,),
                TextArea(controller: barcodes, labelText: "Barcodes", keyboardType: TextInputType.name, readOnly: true,),
                const SizedBox(height: 10),
              const SizedBox(height: 10),
              Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Padding(padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0)),
                          const Text("Loading LRs"),
                           TextButton(
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20)),
                          onPressed: () {
                            _openBarcodeScanner();
                          },
                          child: const Icon(Icons.camera),
                        ),
                        // TextButton(onPressed: () {_openBarcodeScanner();}, child: Icon(Icons.camera),)
                        ],
                      )),
                  const SizedBox(height: 10),
                  if (LRItems.isEmpty)
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
                  if (LRItems.isNotEmpty)
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
                          itemCount: LRItems.length,
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
                                  leading: Text("${index + 1}."),
                                  title: Text('${LRItems[index]["lr_no"]}'),
                                  onTap: () {
                                    _showLRItemDialog(item: LRItems[index], index: index);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Padding(padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0)),
                      Text("Loading Items"),
                      Text(""),
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
                      height: 200, // Set a fixed height for the ListView
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                  shape: BoxShape.rectangle,
                                ),
                                child: ListTile(
                                  leading: Text("${index + 1}."),
                                  title: Text(
                                      items[index]["item_code"].toString()),
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

                  //Mismatch Items
                  if(docstatus.text != "-1")
                  const SizedBox(height: 10),
                  if(docstatus.text != "-1")
                const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Padding(padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0)),
                      Text("Mismatched Items"),
                    ],
                  ),
                ),
                  if(docstatus.text != "-1")
                const SizedBox(height: 10),
                  if(docstatus.text != "-1")
                if (misMatchItems.isEmpty)
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
                if (misMatchItems.isNotEmpty)
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
                          itemCount: misMatchItems.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                  shape: BoxShape.rectangle,
                                ),
                                child: ListTile(
                                  title: Text(
                                      misMatchItems[index]["lr"].toString()),
                                  subtitle: Text(misMatchItems[index]["item_code"].toString()),
                                  onTap: () {
                                    _showMismatchItemDialog(
                                        item: misMatchItems[index], index: index);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40,),
                    MyButton(onTap: () => saveData(), name: "Save")
              ],
            ),
          ),
        ),
      )
    );
  }
}