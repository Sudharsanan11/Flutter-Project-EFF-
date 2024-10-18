import 'dart:ffi';

import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_list/lr_list.dart';
import 'package:erpnext_logistics_mobile/doc_list/unloading_details_list.dart';
import 'package:erpnext_logistics_mobile/doc_view/collection_assignment_view.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/dialog_text.dart';
import 'package:erpnext_logistics_mobile/fields/multi_select.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:erpnext_logistics_mobile/forms/collection_assignment_form.dart';
import 'package:erpnext_logistics_mobile/modules/barcode_scanner.dart';
import 'package:erpnext_logistics_mobile/modules/dialog_auto_complete.dart';
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
  final TextEditingController itemBarcode = TextEditingController();
  final TextEditingController docstatus = TextEditingController();

  List<Map<String, String>> LRItems = [];
  List<String> selectedLoadingStaffs = [];
  List<Map<String, String>> loadingStaffDict = [];
  List<String> loadingStaffItems = [];
  List<String> itemList = [];
  List<Map<String, String>> items = [];
  bool isLoading = false;

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
        // LRItems = widget.data['LRItems'];

        LRItems = (data['unloading_lrs'] as List).map((item) {
          return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
            }).toList();
    });
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
        totalBoxCount.text = response['total_box_count'].toString();
        print(response['unloading_lrs']);
        print(response['unloading_items']);
        setState(() {
        loadingStaffItems = (response["unloading_staffs"] as List).map<String>((item) {
          return item['loading_staff'].toString();
        }).toList();
        loadingStaffDict = (response["unloading_staffs"] as List).map<Map<String, String>>((item){
          return {"loading_staff": item['loading_staff'].toString()};
        }).toList();
        selectedLoadingStaffs = loadingStaffItems;
        print(loadingStaffItems);
        loadingStaffs.text = loadingStaffItems.join(', ').toString();
          LRItems = (response['unloading_lrs'] as List).map((item) {
          return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
            }).toList();
          items = (response['unloading_items'] as List).map((item) {
          return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
            }).toList();

            print(loadingStaffs);
            print(LRItems);
            print(items);
            isLoading = false;
        });
    }
    catch(error){
      setState(() {
        isLoading = false;
        print("$error");
      });
    }
  }

  Future<List<String>> fetchItem() async {
    // print("date ${date.text}");
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Item",
      "filters": [
        ["is_customer_provided_item", "=", 1]
      ]
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

  Future<List<String>> fetchLoadingStaff() async {
      final ApiService apiService = ApiService();
      final body = {
        "doctype": "Employee",
        "filters": [
          ["designation", "=", "Loading Staff"],
          ["status", "=", "Active"]
        ]
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

     Future<void> saveData () async{
    final ApiService apiService = ApiService();
    print(loadingStaffDict);
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
      "unloading_lrs": LRItems,
      "unloading_items": items,
    };
    try {
      if(docstatus.text == "-1"){
        final response = await apiService.createDocument(ApiEndpoints.authEndpoints.unLoadingDetails, body);
        print(response);
        if(response[0] == 200) {
          Fluttertoast.showToast(msg: "Document saved successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
          Navigator.push(context, 
          MaterialPageRoute(builder: (context) => UnloadingDetailsForm(name: response[1], data: const {})));
        }
      }
      else if(docstatus.text == "0") {
        final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.unLoadingDetails}/${widget.name}', body);
        print(response);
        if(response == "200") {
          Fluttertoast.showToast(msg: "Document updated successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
          Navigator.push(context, 
          MaterialPageRoute(builder: (context) => UnloadingDetailsForm(name: widget.name, data: const {})));
        }
      }
    }
    catch(error) {
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
      print(response);
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
      print(response);
    }
    catch(e) {
      print(e);
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
      print(response);
    }
    catch(e) {
      print(e);
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

  void _openBarcodeScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScanner(
          onScanResult: (scanResult) {
            setState(() {
              if (items.isNotEmpty && items[items.length - 1]['barcode'] == '') {
                // items.add({
                //   'item_code': itemName.text,
                //   'barcode': scanResult,
                // });
                items[items.length - 1]['barcode'] = scanResult;
              } else if(items.isEmpty){
                items.add({
                  'item_code': '',
                  'barcode': scanResult,
                });
              } else {
                items.add({
                  'item_code': items[items.length - 1]['item_code'].toString(),
                  'barcode': scanResult,
                });
              }
              itemName.clear();
              itemBarcode.clear();
            });
          },
        ),
      ),
    );
  }

  Future<void> _showItemDialog({dynamic item, int? index}) async {
    itemName.text = item?['item_code'] ?? "";
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
                              },
                              options: itemList,
                            );
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      DialogTextField(
                        controller: itemBarcode,
                        keyboardType: TextInputType.text,
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
                      itemBarcode.clear();
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        items[index!]["item_code"] = itemName.text;
                        items[index]["barcode"] = itemBarcode.text;
                      });
                      itemName.clear();
                      itemBarcode.clear();
                      Navigator.of(context).pop();
                    }
                  },
                )
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
              Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Padding(padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0)),
                          const Text("Items"),
                          ElevatedButton(
                            child: const Icon(Icons.add),
                            onPressed: () {
                              _showLRItemDialog();
                            },
                          ),
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
                  const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Padding(padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0)),
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
                          onPressed: () {
                            _openBarcodeScanner();
                          },
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
                  const SizedBox(height: 40,),
                    MyButton(onTap: () => saveData(), name: "Save")
            ],),)),
      ));
  }
}