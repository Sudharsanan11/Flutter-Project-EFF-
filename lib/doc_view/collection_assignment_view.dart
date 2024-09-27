import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_list/collection_assignment_list.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:erpnext_logistics_mobile/modules/auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/dialog_auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CollectionAssignmentView extends StatefulWidget {
  final String name;
  const CollectionAssignmentView({super.key, required this.name});

  @override
  State<CollectionAssignmentView> createState() => _CollectionAssignmentViewState();
}


class _CollectionAssignmentViewState extends State<CollectionAssignmentView> {

  final List<String> data = [];

  final TextEditingController enteredBy = TextEditingController();
  TextEditingController orderVia = TextEditingController();
  final TextEditingController aproxValueOfGoods = TextEditingController();
  final TextEditingController assignedDriver = TextEditingController();
  final TextEditingController assignedAttender = TextEditingController();
  final TextEditingController assignedVehicle = TextEditingController();
  final TextEditingController routePlaces = TextEditingController();
  
  final TextEditingController collectionRequest = TextEditingController();
  final TextEditingController status = TextEditingController();


  

  // String? orderVia;
  List<Map<String, String>> items = [];
  // String? status;
 
  List<String> stafflist = [];
  List<String> driverList = [];
  List<String> attenderList = [];
  List<String> vehicleList = [];
  List<String> routeList = [];
  List<String> requestList = [];
  bool isDisabled = true;
  late int docstatus = 0;
  late Future<List<String>> fetchVehicleFuture;
late Future<List<String>> fetchAttenderFuture;
late  Future<List<String>> fetchRequestFuture;
late Future<List<String>> fetchDriverFuture;
late Future<List<String>> fetchRoutePlacesFuture;

  @override
  void initState () {
    super.initState();
    // fetchStaff();
    fetchCollectionAssignment();
     
    fetchAttenderFuture = fetchAttender();
    fetchVehicleFuture = fetchVehicle();
    fetchRequestFuture = fetchRequest(routePlaces.text);
    fetchRoutePlacesFuture = fetchRoutePlaces();
    // fetchDriver();
    // fetchAttender();
    // fetchStaff();
    // fetchVehicle();
    // fetchRequest();
  }

  @override
  void dispose() {
    enteredBy.dispose();
    orderVia.dispose();
    aproxValueOfGoods.dispose();
    assignedDriver.dispose();
    assignedVehicle.dispose();
    assignedAttender.dispose();
    collectionRequest.dispose();
    status.dispose();
    items = []; 
    stafflist = [];
    driverList = [];
    attenderList = [];
    vehicleList = [];
    requestList = [];
    super.dispose();
  }

  Future<String> submitData() async{
    final ApiService apiService = ApiService();
    final body = {
      "entered_by": enteredBy.text,
      "ordered_via": orderVia.text,
      "aprox_value_of_the_goods": aproxValueOfGoods.text,
      "assigned_driver": assignedDriver.text,
      "assigned_attender": assignedAttender.text,
      "assigned_vehicle": assignedVehicle.text,
      "route_name": routePlaces.text,
      "collection_req": items,
      "docstatus": 0,
    };
    try {
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.CollectionAssignment}/${widget.name}', body);
      if(response == "200") {
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => CollectionAssignmentView(name: widget.name)));
      }
      return "";
    }
    catch (error) {
      print(error);
      return "Error: Failed to submit data";
    }
  }

  Future<Map<String, dynamic>> fetchCollectionAssignment() async{
    final ApiService apiService = ApiService();
    try {
      final response = await apiService.getDocument('${ApiEndpoints.authEndpoints.CollectionAssignment}/${widget.name}');
      setState(() {
        enteredBy.text = response['entered_by'];
        orderVia.text = response['ordered_via'].toString();
        // orderVia = "Phone";
        aproxValueOfGoods.text = response['aprox_value_of_the_goods'] != 0 ? response['aprox_value_of_the_goods'].toString() : "0";
        assignedDriver.text = response['assigned_driver'] ?? "";
        assignedAttender.text = response['assigned_attender'] ?? "";
        assignedVehicle.text = response['assigned_vehicle'] ?? "";
        routePlaces.text = response['route_name'] ?? "";
        docstatus = response['docstatus'];
        items = (response['collection_req'] as List).map((item) {
          return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
            }).toList();
        status.text = response['status'];
        if(docstatus == 0) {
          setState(() {
          isDisabled = false;
          });
        }
        print(response);
      });
      return response;
    }
    catch(e) {
      throw "Fetch Error";
    }
  }

  Future<List<String>> fetchStaff() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Employee",
      "filters" : [["designation","=","Staff"], ["status", "=", "Active"]]
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

  // Future<List<String>> fetchDriver() async {
  //   final ApiService apiService = ApiService();
  //   final body = {
  //     "doctype" : "Employee",
  //     "filters" : [["designation","=","Driver"], ["status", "=", "Active"]]
  //   };
  //   try {
  //     final response =  await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList , body);
  //     print(response);
  //     return response;
  //   }
  //   catch(e) {
  //     throw "Fetch Error";
  //   }
  // }
  Future<List<String>> fetchDriver(licensetype) async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Driver",
      "filters": {"driving_license_type": licensetype},
      "txt": "",
      "searchfield": "",
      "start": "",
      "page_len": "",
    };
    try {
      final response = await apiService.getList(ApiEndpoints.authEndpoints.getDriver, body);
      print(response);
      print("'''''''''''''''''''''''''''''''''''''''''''''''");
      setState(() {
        driverList = response.map((item) {
          return "${item[0]}";
        }).toList();
      });
      print(driverList);
      return driverList;
    } catch (e) {
      throw "Fetch Error";
    }
  }
  Future<List<String>> fetchRoutePlaces() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Route Places",
      "filters": [["is_active", "=", 1]]
    };
    try {
      final response = await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList, body);
      routeList = response;
      return response;
    } catch (e) {
      throw "Fetch Error";
    }
  }

  Future<List<String>> fetchAttender() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Employee",
      "filters" : [["designation","=","Attender"], ["status", "=", "Active"]]
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

  // Future<List<String>> fetchAttender() async {
  //   print("Fetchattender");
  //   final ApiService apiService = ApiService();
  //   final body = {
  //     "doctype": "Employee",
  //     "filters": [["designation", "=", "Attender"], ["status", "=", "Active"]],
  //     "fields": ['name', 'employee_name']
  //   };
  //   try {
  //     final response = await apiService.getList(ApiEndpoints.authEndpoints.getList, body);
  //     print("$response ===================================response");
  //     setState(() {
  //       // attenderList = response;
  //       attenderList = response.map((item) {
  //         return "${item['name'] + "," + item['employee_name']}";
  //       }).toList();
  //     });
  //     print("$attenderList ========================================");
  //     return attenderList;
  //   } catch (e) {
  //     print("fetch error");
  //     throw "Fetch Error";
  //   }
  // }

  // Future<List<String>> fetchVehicle() async {
  //   final ApiService apiService = ApiService();
  //   final body = {
  //     "doctype" : "Vehicle",
  //     "filters" : [["is_active", "=", 1]]
  //   };
  //   try {
  //     final response =  await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList , body);
  //     print(response);
  //     return response;
  //   }
  //   catch(e) {
  //     throw "Fetch Error";
  //   }
  // }

   Future<List<String>> fetchVehicle() async {
    print(":vehicle====================");
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Vehicle",
      "txt": "",
      "searchfield": "",
      "start": "",
      "page_len": "",
      "filters": ""
      // "filters": [["is_active", "=", 1]]
    };
    try {
      final response = await apiService.getList(ApiEndpoints.authEndpoints.getVehicle, body);
      print(response);
      print("reposne");
      setState(() {
        vehicleList = response.map((item) {
          return "${item[0]}" ;
        }).toList();
      });
      return vehicleList;
    } catch (e) {
      throw "Fetch Error";
    }
  }
  void submitDoc() async{
    final ApiService apiService = ApiService();
    final body = {
      "docstatus" : 1
    };
    try {
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.CollectionAssignment}/${widget.name}', body);
      print(response);
      if(response == "200") {
        Fluttertoast.showToast(msg: "Document Submitted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CollectionAssignmentList()));
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
      final response = await apiService.deleteDocument('${ApiEndpoints.authEndpoints.CollectionAssignment}/${widget.name}');
      if(response == "202") {
        Fluttertoast.showToast(msg: "Document deleted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CollectionAssignmentList()));
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
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.CollectionAssignment}/${widget.name}', body);
      if(response == "200") {
        Fluttertoast.showToast(msg: "Document Canceled successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CollectionAssignmentList()));
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


  // Future<List<String>> fetchRequest() async {
  //   final ApiService apiService = ApiService();
  //   final body = {
  //     "doctype" : "Collection Request",
  //     "filters" : [["status", "=", "Open"]]
  //   };
  //   try {
  //     final response =  await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList , body);
  //     print(response);
  //     return response;
  //   }
  //   catch(e) {
  //     throw "Fetch Error";
  //   }
  // }

   Future<List<String>> fetchRequest(route_name) async {
    print(route_name);
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Collection Request",
      "filters": {"route_name": route_name},
      "txt": "",
      "searchfield": "",
      "start": "",
      "page_len": 0,
    };
    try {
      final response = await apiService.getList(ApiEndpoints.authEndpoints.getRequest, body);
      print(response);
      setState(() {
        requestList = response.map((item) {
          return "${item[0]}" ;
        }).toList();
      });
      return requestList;
    } catch (e) {
      throw "Fetch Error";
    }
  }


  Future<void> _showItemDialog({dynamic item, int? index}) async {
    print("item $items");
    collectionRequest.text = item?['collection_request'] ?? "";

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item == null ? 'Add Item' : 'Edit Item'),
          content: FutureBuilder<List<String>>(
                  future: fetchRequestFuture,
                  builder: (context, snapshot) {
                    if(snapshot.hasError) {
                      return DialogAutoComplete(
                        controller: collectionRequest,
                        readOnly: isDisabled,
                        hintText: 'Collection Request',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: requestList,
                      );
                    }
                    else if (snapshot.hasData) {
                      requestList = snapshot.data!;
                      return DialogAutoComplete(
                        controller: collectionRequest,
                        readOnly: isDisabled,
                        hintText: 'Collection Request',
                        onSelected: (String selection) {
                          print(selection);
                        },
                        options: requestList,
                      );
                    } else {
                      return DialogAutoComplete(
                        controller: collectionRequest,
                        readOnly: isDisabled,
                        hintText: 'Collection Request',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: requestList,
                      );
                    }
                  },
                ),
          actions: <Widget>[
            if(docstatus == 0)
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
            if(docstatus == 0)
            TextButton(
              child: Text(item == null ? 'Add' : 'Save'),
              onPressed: () {
                if(item == null) {
                  setState(() {
                  items.add(
                    {"collection_request" : collectionRequest.text}
                  );
                  });
                  collectionRequest.clear();
                  Navigator.of(context).pop();
                }
                else {
                  setState(() {
                    items[index!]["collection_request"] = collectionRequest.text;
                  });
                  collectionRequest.clear();
                  Navigator.of(context).pop();
                }
              },
            )
          ]
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if(didPop) {return;}
        Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const CollectionAssignmentList()));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Collection Assignment Form"),
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10,),
                // FutureBuilder<List<String>>(
                //     future: fetchStaff(),
                //     builder: (context, snapshot) {
                //       if(snapshot.hasError) {
                //         return AutoComplete(
                //           controller: enteredBy,
                //           hintText: 'Entered By',
                //           onSelected: (String selection) {
                //             print('You selected: $selection');
                //           },
                //           options: stafflist,
                //         );
                //       }
                //       else if (snapshot.hasData) {
                //         stafflist = snapshot.data!;
                //         return AutoComplete(
                //           controller: enteredBy,
                //           hintText: 'Enter By',
                //           onSelected: (String selection) {
                //             print(selection);
                //           },
                //           options: stafflist,
                //         );
                //       } else {
                //         return AutoComplete(
                //           controller: enteredBy,
                //           hintText: 'Entered By',
                //           onSelected: (String selection) {
                //             print('You selected: $selection');
                //           },
                //           options: stafflist,
                //         );
                //       }
                //     },
                //   ),
                FieldText(
                  controller: enteredBy,
                  labelText: "Entered By",
                  readOnly: true,
                  keyboardType: TextInputType.name
                ),
                const SizedBox(height: 10,),
                FieldText(controller: orderVia, labelText: "Oredered Via", keyboardType: TextInputType.none, readOnly: true,),
                // const SizedBox(height: 10,),
                // // DropDown(
                // //   labelText: "Order Via",
                // //   items: const [
                // //     "WhatApp",
                // //     "Phone",
                // //     "Email",
                // //     "App",
                // //   ],
                // //   controller: orderVia,
                // //   selectedItem: orderVia,
                // //   onChanged: (String? newValue) {
                // //           setState(() {
                // //             print("newValue $newValue");
                // //             orderVia.value = newValue;
                // //           });
                // //         },
                // //   ),
                const SizedBox(height: 15,),
                FieldText(
                  controller: aproxValueOfGoods,
                  readOnly: isDisabled,
                  labelText: "Aprox. Value of Goods", 
                  keyboardType: TextInputType.number
                ),
                const SizedBox(height: 10,),
                FutureBuilder<List<String>>(
                    future: fetchVehicleFuture,
                    builder: (context, snapshot) {
                      if(snapshot.hasError) {
                        return AutoComplete(
                          controller: assignedVehicle,
                          readOnly: true,
                          hintText: 'Assign Vehicle',
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                          options: vehicleList,
                        );
                      }
                      else if (snapshot.hasData) {
                        vehicleList = snapshot.data!;
                        return AutoComplete(
                          controller: assignedVehicle,
                          readOnly: isDisabled,
                          hintText: 'Assign Vehicle',
                          onSelected: (String selection) {
                            print(selection);
                          },
                          options: vehicleList,
                        );
                      } else {
                        return AutoComplete(
                          controller: assignedVehicle,
                          readOnly: isDisabled,
                          hintText: 'Assign Vehicle',
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                          options: vehicleList,
                        );
                      }
                    },
                  ),
                const SizedBox(height: 10,),
                FutureBuilder<List<String>>(
                    future: fetchDriverFuture,
                    builder: (context, snapshot) {
                      if(snapshot.hasError) {
                        return AutoComplete(
                          controller: assignedDriver,
                          readOnly: isDisabled,
                          hintText: 'Assign Driver',
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                          options: driverList,
                        );
                      }
                      else if (snapshot.hasData) {
                        driverList = snapshot.data!;
                        return AutoComplete(
                          controller: assignedDriver,
                          readOnly: isDisabled,
                          hintText: 'Assign Driver',
                          onSelected: (String selection) {
                            print(selection);
                          },
                          options: driverList,
                        );
                      } else {
                        return AutoComplete(
                          controller: assignedDriver,
                          readOnly: isDisabled,
                          hintText: 'Assign Driver',
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                          options: driverList,
                        );
                      }
                    },
                  ),
                const SizedBox(height: 10,),
                FutureBuilder<List<String>>(
                    future: fetchAttenderFuture,
                    builder: (context, snapshot) {
                      if(snapshot.hasError) {
                        return AutoComplete(
                          controller: assignedAttender,
                          hintText: 'Assign Attender',
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                          options: attenderList,
                        );
                      }
                      else if (snapshot.hasData) {
                        attenderList = snapshot.data!;
                        return AutoComplete(
                          controller: assignedAttender,
                          readOnly: isDisabled,
                          hintText: 'Assign Attender',
                          onSelected: (String selection) {
                            print(selection);
                          },
                          options: attenderList,
                        );
                      } else {
                        return AutoComplete(
                          controller: assignedAttender,
                          hintText: 'Assign Attender',
                          readOnly: isDisabled,
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                          options: attenderList,
                        );
                      }
                    },
                  ),
                   const SizedBox(height: 10),
                FutureBuilder<List<String>>(
                  future: fetchRoutePlacesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return AutoComplete(
                        controller: routePlaces,
                        hintText: 'Route Name',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: routeList,
                      );
                    } else if (snapshot.hasData) {
                      routeList = snapshot.data!;
                      return AutoComplete(
                        controller: routePlaces,
                        hintText: 'Route Name',
                        onSelected: (String selection) {
                          print(selection);

                          fetchRequestFuture = fetchRequest(selection);
                        },
                        options: routeList,
                      );
                    } else {
                      return AutoComplete(
                        controller: routePlaces,
                        hintText: 'Route Name',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: routeList,
                      );
                    }
                  },
                ),
                const SizedBox(height: 10,),
                FieldText(
                  controller: status,
                  readOnly: true,
                  labelText: "Status",
                  keyboardType: TextInputType.none
                ),
                // DropDown(
                //   labelText: "Status",
                //   items: const [
                //     "Pending",
                //     "Partially collected",
                //     "Completed",
                //     "Overdue"
                //   ],
                //   selectedItem: status,
                //   onChanged: (String? newValue) {
                //           setState(() {
                //             status = newValue;
                //           });
                //         }
                // ),
                // const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Padding(padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0)),
                      const Text("Items"),
                      ElevatedButton(
                        onPressed: docstatus == 0 ? () {
                          _showItemDialog();} : (){},
                        child: const Icon(Icons.add),
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
                                  title: Text(items[index]["collection_request"].toString()),
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
                    const SizedBox(height: 40,),
                    MyButton(onTap: docstatus == 0 ? submitData : (){Fluttertoast.showToast(msg: "Can't able to save", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);}, name: "Save")
              ],
              ),
          ),
        ),
        bottomNavigationBar: const BottomNavigation(),
      ),
    );
  }
}