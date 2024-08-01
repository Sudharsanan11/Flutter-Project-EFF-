import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/drop_down.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:erpnext_logistics_mobile/modules/auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionAssignmentForm extends StatefulWidget {
  const CollectionAssignmentForm({super.key});

  @override
  State<CollectionAssignmentForm> createState() =>
      _CollectionAssignmentFormState();
}

class _CollectionAssignmentFormState extends State<CollectionAssignmentForm> {
  final List<String> data = [];

  final TextEditingController enteredBy = TextEditingController();
  // TextEditingController orderVia = TextEditingController();
  final TextEditingController aproxValueOfGoods = TextEditingController();
  final TextEditingController assignedDriver = TextEditingController();
  final TextEditingController assignedAttender = TextEditingController();
  final TextEditingController assignedVehicle = TextEditingController();
  final TextEditingController collectionRequest = TextEditingController();

  String? orderVia;
  List<Map<String, String>> items = [];
  String? status;
 
  List<String> stafflist = [];
  List<String> driverList = [];
  List<String> attenderList = [];
  List<String> vehicleList = [];
  List<String> requestList = [];

  @override
  void initState () {
    super.initState();
    // fetchStaff();
    setEnterBy();
    fetchDriver();
    fetchAttender();
    fetchVehicle();
    fetchRequest();
  }

  Future<String> submitData() async{
    final ApiService apiService = ApiService();
    final body = {
      "entered_by": enteredBy.text,
      "order_via": orderVia,
      "aprox_value_of_the_goods": aproxValueOfGoods.text,
      "assigned_driver": assignedDriver.text,
      "assigned_attender": assignedAttender.text,
      "assigned_vehicle": assignedVehicle.text,
      "collection_req": items,
      "docstatus": 1,
    };
    try {
      final response = await apiService.createDocument(ApiEndpoints.authEndpoints.createCollectionAssignment, body);
      if(response == "200") {
        Navigator.pop(context);
      }
      return "";
    }
    catch (error) {
      print(error);
      return "Error: Failed to submit data";
    }
  }

  // Future<List<String>> fetchStaff() async {
  //   final ApiService apiService = ApiService();
  //   final body = {
  //     "doctype" : "Employee",
  //     "filters" : [["designation","=","Staff"], ["status", "=", "Active"]]
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

  void setEnterBy() async{
    SharedPreferences manager = await SharedPreferences.getInstance();
    setEnterBy(){
      enteredBy.text = manager.getString('username')?? "";
    }
  }

  Future<List<String>> fetchDriver() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Employee",
      "filters" : [["designation","=","Driver"], ["status", "=", "Active"]]
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

  Future<List<String>> fetchVehicle() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Vehicle",
      "filters" : [["is_active", "=", 1]]
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

  Future<List<String>> fetchRequest() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Collection Request",
      "filters" : [["status", "=", "Open"]]
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
  final _formKey = GlobalKey<FormState>();


  Future<void> _showItemDialog({dynamic item, int? index}) async {
    print("item $items");
    collectionRequest.text = item?['collection_request'] ?? "";

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item == null ? 'Add Item' : 'Edit Item'),
          content: FutureBuilder<List<String>>(
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
                  if (_formKey.currentState!.validate()) {
                    if (item == null) {
                      setState(() {
                        items.add(
                            {"collection_request": collectionRequest.text});
                      });
                      collectionRequest.clear();
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        items[index!]["collection_request"] =
                            collectionRequest.text;
                      });
                      collectionRequest.clear();
                      Navigator.of(context).pop();
                    }
                  }
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collection Assignment Form"),
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
              // DropDown(
              //   labelText: "Order Via",
              //   items: const [
              //     "WhatApp",
              //     "Phone",
              //     "Email",
              //     "App",
              //   ],
              //   selectedItem: orderVia,
              //   onChanged: (String? newValue) {
              //           setState(() {
              //             orderVia = newValue;
              //           });
              //         },
              //   ),
              const SizedBox(height: 10,),
              FieldText(
                controller: aproxValueOfGoods, 
                labelText: "Aprox. Value of Goods", 
                keyboardType: TextInputType.number
              ),
              const SizedBox(height: 10,),
              FutureBuilder<List<String>>(
                  future: fetchDriver(),
                  builder: (context, snapshot) {
                    if(snapshot.hasError) {
                      return AutoComplete(
                        controller: assignedDriver,
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
                        hintText: 'Assign Driver',
                        onSelected: (String selection) {
                          print(selection);
                        },
                        options: driverList,
                      );
                    } else {
                      return AutoComplete(
                        controller: assignedDriver,
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
                  future: fetchAttender(),
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
                        hintText: 'Assign Attender',
                        onSelected: (String selection) {
                          print(selection);
                        },
                        options: attenderList,
                        validator: (value) {
                          if(value == null){
                            return "Attender is required";
                          }
                          else {
                            return null;
                          }
                        }
                      );
                    } else {
                      return AutoComplete(
                        controller: assignedAttender,
                        hintText: 'Assign Attender',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: attenderList,
                        validator: (value) {
                          if(value == null){
                            return "Attender is required";
                          }
                          else {
                            return null;
                          }
                        },
                      );
                    }
                  },
                ),
              const SizedBox(height: 10,),
              FutureBuilder<List<String>>(
                  future: fetchVehicle(),
                  builder: (context, snapshot) {
                    if(snapshot.hasError) {
                      return AutoComplete(
                        controller: assignedVehicle,
                        hintText: 'Assign Vehicle',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: vehicleList,
                        validator: (value) {
                          if (value == null) {
                            return "Vehicle is required";
                          }
                          else {
                            return null;
                          }
                        }
                      );
                    }
                    else if (snapshot.hasData) {
                      vehicleList = snapshot.data!;
                      return AutoComplete(
                        controller: assignedVehicle,
                        hintText: 'Assign Vehicle',
                        validator: (value) {
                          if (value == null) {
                            return "Vehicle is required";
                          }
                          else {
                            return null;
                          }
                        },
                        onSelected: (String selection) {
                          print(selection);
                        },
                        options: vehicleList,
                      );
                    } else {
                      return AutoComplete(
                        controller: assignedVehicle,
                        hintText: 'Assign Vehicle',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: vehicleList,
                        validator: (value) {
                          if (value == null) {
                            return "Vehicle is required";
                          }
                          return null;
                        },
                      );
                    }
                  },
                ),
              const SizedBox(height: 10,),
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
                      child: const Icon(Icons.add),
                      onPressed: () {
                        _showItemDialog();
                      },
                    ),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                FieldText(
                    controller: enteredBy,
                    labelText: "Entered By",
                    obscureText: false,
                    keyboardType: TextInputType.none),
                const SizedBox(
                  height: 10,
                ),
                DropDown(
                  labelText: "Order Via",
                  items: const [
                    "WhatApp",
                    "Phone",
                    "Email",
                    "App",
                  ],
                  selectedItem: orderVia,
                  onChanged: (String? newValue) {
                    setState(() {
                      orderVia = newValue;
                    });
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                FieldText(
                    controller: aproxValueOfGoods,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Value of goods required';
                      }
                      return null;
                    },
                    labelText: "Aprox. Value of Goods",
                    keyboardType: TextInputType.number),
                const SizedBox(
                  height: 10,
                ),
                FieldText(
                    controller: assignedDriver,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Driver is required';
                      }
                      return null;
                    },
                    labelText: "Assigned Driver",
                    keyboardType: TextInputType.name),
                const SizedBox(
                  height: 10,
                ),
                FieldText(
                    controller: assignedAttender,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return ' Attender is required';
                      }
                      return null;
                    },
                    labelText: "Assigned Attender",
                    keyboardType: TextInputType.name),
                const SizedBox(
                  height: 10,
                ),
                FieldText(
                    controller: assignedVehicle,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vehicle is required';
                      }
                      return null;
                    },
                    labelText: "Assigned Vehicle",
                    keyboardType: TextInputType.name),
                // const SizedBox(height: 10,),
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
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Padding(padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0)),
                      const Text("Collection Requests"),
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
                                child: Text("Add Request"),
                              )),
                        )
                      ],
                    ),
                  ),
                if (items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 17.0, vertical: 3.0),
                    child: SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                                shape: BoxShape.rectangle,
                              ),
                              child: ListTile(
                                title: Text(items[index]["collection_request"]
                                    .toString()),
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
                const SizedBox(
                  height: 40,
                ),
                MyButton(
                    onTap: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        submitData();
                      }
                    },
                    name: "Assign")
              ],
            ),
          ),
                  ]
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}
