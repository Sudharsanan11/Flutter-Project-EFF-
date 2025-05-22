
import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_list/unloading_details_list.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/dialog_text.dart';
import 'package:erpnext_logistics_mobile/fields/multi_select.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:erpnext_logistics_mobile/fields/text_area.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/modules/barcode_scanner.dart';
import 'package:erpnext_logistics_mobile/modules/mobile_scanner.dart';
import 'package:erpnext_logistics_mobile/modules/scanner.dart';
import 'package:erpnext_logistics_mobile/modules/test_scan.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class UnloadingDetailsForm extends StatefulWidget {
  final String name;
  final Map data;
  const UnloadingDetailsForm({super.key, this.name = "", required this.data});

  @override
  State<UnloadingDetailsForm> createState() => _UnloadingDetailsFormState();
}

class _UnloadingDetailsFormState extends State<UnloadingDetailsForm> {

  final TextEditingController supervisor = TextEditingController();
  final TextEditingController gdm = TextEditingController();
  final TextEditingController collectionAssignment = TextEditingController();
  final TextEditingController driver = TextEditingController();
  final TextEditingController unloadingFrom = TextEditingController();
  final TextEditingController unloadingType = TextEditingController();
  final TextEditingController vehicle = TextEditingController();
  final TextEditingController branch = TextEditingController();
  final TextEditingController VehicleType = TextEditingController();
  final TextEditingController loadingStaffs = TextEditingController();
  final TextEditingController totalBoxCount = TextEditingController();
  final TextEditingController lr = TextEditingController();
  final TextEditingController boxCount = TextEditingController();
  final TextEditingController itemName = TextEditingController();
  final TextEditingController itemBoxCount = TextEditingController();
  final TextEditingController itemBarcode = TextEditingController();
  final TextEditingController docstatus = TextEditingController();
  final TextEditingController barcodes = TextEditingController();
  final TextEditingController misMatchItem = TextEditingController();
  final TextEditingController misMatchLR = TextEditingController();
  final TextEditingController misMatchBoxCount = TextEditingController();

  List<Map<String, String>> LRItems = [];
  List<String> selectedLoadingStaffs = [];
  List<Map<String, String>> loadingStaffDict = [];
  List<String> loadingStaffItems = [];
  List<String> itemList = [];
  List<Map<String, String>> items = [];
  List<Map<String, String>> misMatchItems = [];
  List<String> existingBarcodes = [];
  List<Map<String, Map<String, List<String>>>> allowedBarcodes = [];
  bool isLoading = false;
  List<String> barcode_list = [];

  @override
  void initState() {
    super.initState();
    docstatus.text = "-1";
    if(widget.name == "" && widget.data.isNotEmpty){
      setData();
      print(widget.data);
  }
  else if(widget.name != ""){
    fetchData();
  }
  }

  void setData() {
    try{

    setState(() {
        Map data = widget.data;
        supervisor.text = data["supervisor"] ?? "";
        gdm.text = data['gdm'] ?? "";
        collectionAssignment.text = data['collection_assignment'] ?? "";
        driver.text = data['driver'] ?? "";
        vehicle.text = data['vehicle'] ?? "";
        unloadingFrom.text = data['unloading_from'] ?? "";
        unloadingType.text = data['unloading_type'] ?? "";
        VehicleType.text = data['vehicle_type'] ?? "";
        branch.text = data['branch'] ?? "";
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
    print("$allowedBarcodes , alloweddddddddddddddddddddm nabaaaaaaaaaaaaa");

        print(data);
        LRItems = (data['unloading_lrs'] as List).map((item) {
          return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
            }).toList();
    });
    }
    catch(e){
      throw "$e";
    };
  }

  Future<void> fetchData() async {
    ApiService apiService = ApiService();

    setState(() {
      isLoading = true;
    });

    try{
      final response = await apiService.getDocument('${ApiEndpoints.authEndpoints.unLoadingDetails}/${widget.name}');

        docstatus.text = response['docstatus'].toString();
        supervisor.text = response["supervisor"] ?? "";
        gdm.text = response['gdm'] ?? "";
        collectionAssignment.text = response['collection_assignment'] ?? "";
        driver.text = response['driver'];
        vehicle.text = response['vehicle'];
        unloadingFrom.text = response['unloading_from'];
        unloadingType.text = response['unloading_type'];
        VehicleType.text = response['vehicle_type'];
        branch.text = response['branch'];
        barcodes.text = response['barcodes'];
        totalBoxCount.text = response['total_box_count'].toString();
        setState(() {
        loadingStaffItems = (response["unloading_staffs"] as List).map<String>((item) {
          return item['loading_staff'].toString();
        }).toList();
        loadingStaffDict = (response["unloading_staffs"] as List).map<Map<String, String>>((item){
          return {"loading_staff": item['loading_staff'].toString()};
        }).toList();
        selectedLoadingStaffs = loadingStaffItems;
        loadingStaffs.text = loadingStaffItems.join(', ').toString();
          LRItems = (response['unloading_lrs'] as List).map((item) {
          return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
            }).toList();
          items = (response['unloading_items'] as List).map((item) {
          return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
            }).toList();
          
          misMatchItems = (response['mismatched_items'] as List).map((item) {
          return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
            }).toList();

          existingBarcodes = (response['barcodes'] as String).split(",");
            isLoading = false;
        });
        if(gdm.text.isNotEmpty){
          fetch_allowed_barcodes(gdm.text);
        }
        else{
          fetch_allowed_barcodes(collectionAssignment.text);
        }
    }
    catch(error){
      setState(() {
        isLoading = false;
        throw "$error";
      });
    }
  }

  Future<void> fetch_allowed_barcodes(source_name) async{
    try{
      final ApiService apiService = ApiService();
      final body = {
        "source_name": source_name,
      };

      final response = await apiService.getDoc(ApiEndpoints.authEndpoints.getUnloadingDetails, body);

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

  Future<List<String>> fetchItem() async {
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
      return response;
    } catch (e) {
      throw "Fetch Error";
    }
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
        return response;
      } catch (e) {
        throw "Fetch Error";
      }
    }

     Future<void> saveData () async{
      setState(() {
      isLoading = true;
    });
    final ApiService apiService = ApiService();
    final body = {
      "supervisor" : supervisor.text,
      "unloading_staffs" : loadingStaffDict,
      "driver" : driver.text,
      "gdm" : gdm.text,
      "vehicle_type": VehicleType.text,
      "vehicle": vehicle.text,
      "collection_assignment" : collectionAssignment.text,
      "branch" : branch.text,
      "unloading_from": unloadingFrom.text,
      "unloading_type": unloadingType.text,
      "barcodes": barcodes.text,
      "unloading_lrs": LRItems,
    };
    try {
      if(docstatus.text == "-1"){
        final response = await apiService.createDocument(ApiEndpoints.authEndpoints.unLoadingDetails, body);
        if(response[0] == 200) {
          Fluttertoast.showToast(msg: "Document saved successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
          Navigator.push(context, 
          MaterialPageRoute(builder: (context) => UnloadingDetailsForm(name: response[1], data: const {})));
        }
      }
      else if(docstatus.text == "0") {
        final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.unLoadingDetails}/${widget.name}', body);
        if(response == "200") {
          Fluttertoast.showToast(msg: "Document updated successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
          Navigator.push(context, 
          MaterialPageRoute(builder: (context) => UnloadingDetailsForm(name: widget.name, data: const {})));
        }
      }
    }
    catch(error) {
      setState(() {
      isLoading = false;
    });
       Fluttertoast.showToast(msg: "Failed to save document $error", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
    }
  }

  void submitDoc() async{
    final ApiService apiService = ApiService();
    final body = {
      "docstatus" : 1
    };
    try {
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.unLoadingDetails}/${widget.name}', body);
      if(response == "200") {
        Fluttertoast.showToast(msg: "Document Submitted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => UnloadingDetailsForm(name: widget.name, data: const {},)));
        }
      }
      else {
        Fluttertoast.showToast(msg: "Failed to submit document", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      }
    }
    catch(e) {
      throw e;
    }
  }

  void deleteDoc() async {
    final ApiService apiService = ApiService();
    try {
      final response = await apiService.deleteDocument('${ApiEndpoints.authEndpoints.unLoadingDetails}/${widget.name}');
      if(response == "202") {
        Fluttertoast.showToast(msg: "Document deleted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const UnloadingDetailsList()));
        }
      }
      else {
        Fluttertoast.showToast(msg: "Failed to delete document", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      }
    }
    catch(e) {
      throw e;
    }
  }

  void cancelDoc() async{
    final ApiService apiService = ApiService();
    final body = {
      "docstatus" : 2
    };
    try {
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.unLoadingDetails}/${widget.name}', body);
      if(response == "200") {
        Fluttertoast.showToast(msg: "Document Canceled successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const UnloadingDetailsList()));
        }
      }
      else {
        Fluttertoast.showToast(msg: "Failed to cancel document", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      }
    }
    catch(e) {
      throw e;
    }
  }

  void _showLoadingStaffs(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    List<String> filteredItems = loadingStaffItems;

    fetchLoadingStaff()
        .then((response) => {
              setState(() {
                loadingStaffItems = [];
                loadingStaffItems = response;
                // filteredItems = loadingStaffItems;
              })
            })
        .catchError((error) => {throw "Error: $error"});

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Loading Staffs'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: searchController, decoration: InputDecoration( hintText: 'Search...',suffixIcon: IconButton( icon: const Icon(Icons.clear),
                  onPressed: () {searchController.clear(); setState(() { filteredItems = loadingStaffItems;});},
                  ),
              ),
              onChanged: (value) {
                setState(() {
                  filteredItems = loadingStaffItems
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
                    selectedItems: selectedLoadingStaffs,
                    onSelectedItemsListChanged:
                        (List<String> newSelectedItems) {
                      setState(() {
                        selectedLoadingStaffs = newSelectedItems;
                        loadingStaffs.text = selectedLoadingStaffs.join(', ');
                        loadingStaffDict = selectedLoadingStaffs.map((staff) {
                          return {
                            'loading_staff': staff,
                          };
                        }).toList();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

   Future<void> _showLRItemDialog({dynamic item, int? index}) async {
    lr.text = item?['lr_no'] ?? "";
    boxCount.text = item?['box_count'] ?? "";

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
                      //   controller: lr,
                      //   keyboardType: TextInputType.name,
                      //   labelText: "LR ID",
                      // ),
                      DialogTextField(controller: lr,labelText: "LR No.",keyboardType: TextInputType.none,readOnly: true,),
                      const SizedBox(height: 10,),
                      DialogTextField(controller: boxCount, keyboardType: TextInputType.none, labelText: "Box Count", readOnly: true,),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      lr.clear();
                      boxCount.clear();
                        Navigator.of(context).pop();
                    }),
                // TextButton(
                //   child: Text(item == null ? 'Add' : 'Save'),
                //   onPressed: () {
                //     if (item == null) {
                //       setState(() {
                //         LRItems.add({
                //           "lr_no": lr.text,
                //           "box_count": boxCount.text,
                //         });
                //       });
                //       lr.clear();
                //       boxCount.clear();
                //       Navigator.of(context).pop();
                //     } else {
                //       setState(() {
                //         LRItems[index!]["lr_no"] = lr.text;
                //         LRItems[index]["box_count"] = boxCount.text;
                //       });
                //       lr.clear();
                //       boxCount.clear();
                //       Navigator.of(context).pop();
                //     }
                //   },
                // )
              ]);
        });
  }

  void _handleScannedBarcodes(List<String> barcode_list) {
    print(barcode_list);
    print("barocdessssssssssssssssssssssssssssssssssssssssssssssssssssssss");
    setState(() {
      if(barcodes.text.isNotEmpty){
        barcodes.text = "${barcodes.text},${barcode_list.join(",")}";
      }
      else{
        barcodes.text = barcode_list.join(",");
      }
        existingBarcodes = barcodes.text.split(",");
    });
    print(existingBarcodes);
    print("existinggggggggggggggggggggggggg");
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
                          doctype: "Unloading Details",
                          allowedBarcodes: allowedBarcodes,
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
                          allowedBarcodes: allowedBarcodes,
                          doctype: "Unloading Details",
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
              title: const Text('Item'),
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
                    child: const Text('Cancel'),
                    onPressed: () {
                      itemName.clear();
                      itemBoxCount.clear();
                      itemBarcode.clear();
                      Navigator.of(context).pop();
                    }),
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
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {return;}
        Navigator.push(context, MaterialPageRoute(builder: (context) => const UnloadingDetailsList()));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Unloading Details"),
          actions: [
            Padding(padding: const EdgeInsets.only(right: 20),
            child: PopupMenuButton(
              itemBuilder: (context) => [
                if(docstatus.text == "0")
                const PopupMenuItem(
                  value: 1,
                  child: Text('Submit', style: TextStyle(),),
                ),
                if(docstatus.text == "0" || docstatus.text == "2")
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
            child: Column(children: [
              if(supervisor.text.isNotEmpty)
              const SizedBox(height: 10,),
              if(supervisor.text.isNotEmpty)
              FieldText(controller: supervisor, labelText: "Supervisor", keyboardType: TextInputType.none, readOnly: true,),
              const SizedBox(height: 10,),
              FieldText(controller: driver, labelText: "Driver", keyboardType: TextInputType.none, readOnly: true,),
              const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => docstatus.text == "1" ? {} : _showLoadingStaffs(context),
                  child: AbsorbPointer(
                    child: FieldText(
                      controller: loadingStaffs,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Loading staffs required';
                        }
                        return null;
                      },
                      labelText: "Loading Staffs",
                      obscureText: false,
                      keyboardType: TextInputType.name,
                    ),
                  ),
                ),
                if(docstatus.text != "-1")
                const SizedBox(height: 10,),
                if(docstatus.text != "-1")
                FieldText(controller: totalBoxCount, labelText: "Total Box Count", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10),
                FieldText(controller: unloadingFrom, labelText: "Unloading From", keyboardType: TextInputType.none, readOnly: true,),
                if(collectionAssignment.text != "")
                const SizedBox(height: 10,),
                if(collectionAssignment.text != "")
                FieldText(controller: collectionAssignment, labelText: "Collection Assignment", keyboardType: TextInputType.none, readOnly: true,),
                if(gdm.text != "")
                const SizedBox(height: 10,),
                if(gdm.text != "")
                FieldText(controller: gdm, labelText: "GDM", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10),
                FieldText(controller: vehicle, labelText: "Vehicle No.", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10,),
                FieldText(controller: VehicleType, labelText: "Vehicle Type", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10,),
                FieldText(controller: unloadingType, labelText: "Unloading Type", keyboardType: TextInputType.none, readOnly: true,),
                if(VehicleType.text == "For Branch")
                const SizedBox(height: 10),
                if(VehicleType.text == "For Branch")
                FieldText(controller: branch, keyboardType: TextInputType.name,labelText: "Branch", readOnly: true,),
                const SizedBox(height: 10),
                TextArea(controller: barcodes, labelText: "Barcodes", keyboardType: TextInputType.name, readOnly: true,),
                const SizedBox(height: 10),
              Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Padding(padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0)),
                          const Text("LR Items"),
                          // ElevatedButton(
                          //   child: const Icon(Icons.add),
                          //   onPressed: () {
                          //     _showLRItemDialog();
                          //   },
                          // ),
                          TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20)),
                          onPressed: () {
                            _openBarcodeScanner();
                          },
                          child: const Icon(Icons.camera),
                        ),
                        ],
                      )),
                // const Text("LR Items"),
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
                                  title: Text('${index + 1}. ${LRItems[index]["lr_no"]}'),
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
                      Text("Unloading Items"),
                      // Row(children: [
                      //   ElevatedButton(
                      //     child: const Icon(Icons.add),
                      //     onPressed: () {
                      //       _showItemDialog();
                      //     },
                      //   ),
                      // ]),
                    ],
                  ),
                ),
                  if(docstatus.text != "-1")
                const SizedBox(height: 10),
                  if(docstatus.text != "-1")
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
            ],),)),
      ));
  }
}