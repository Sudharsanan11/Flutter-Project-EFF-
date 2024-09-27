import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_view/collection_assignment_view.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/drop_down.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:erpnext_logistics_mobile/modules/auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/dialog_auto_complete.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dotted_border/dotted_border.dart';

class CollectionAssignmentForm extends StatefulWidget {
  const CollectionAssignmentForm({super.key});

  @override
  State<CollectionAssignmentForm> createState() =>
      _CollectionAssignmentFormState();
}

class _CollectionAssignmentFormState extends State<CollectionAssignmentForm> {
  final List<String> data = [];

  final TextEditingController enteredBy = TextEditingController();
  final TextEditingController aproxValueOfGoods = TextEditingController();
  final TextEditingController assignedDriver = TextEditingController();
  final TextEditingController assignedAttender = TextEditingController();
  final TextEditingController assignedVehicle = TextEditingController();
  final TextEditingController routePlaces = TextEditingController();
  final TextEditingController licensetype = TextEditingController();
  final TextEditingController collectionRequest = TextEditingController();

  String? orderVia;
  List<Map<String, String>> items = [];
  String? status;

  List<String> stafflist = [];
  List<String> driverList = [];
  List<String> attenderList = [];
  List<String> licenseList = [];
  List<String> vehicleList = [];
  List<String> routeList = [];
  List<String> requestList = [];
  bool isEnabled = true;
late Future<List<String>> fetchVehicleFuture;
late Future<List<String>> fetchAttenderFuture;
late  Future<List<String>> fetchRequestFuture;
late Future<List<String>> fetchDriverFuture;
late Future<List<String>> fetchRoutePlacesFuture;

  @override
  void initState() {
    super.initState();
    setEnterBy();
    fetchDriverFuture = fetchDriver("");
    fetchAttenderFuture = fetchAttender();
    fetchVehicleFuture = fetchVehicle();
    fetchRequestFuture = fetchRequest("");
    fetchRoutePlacesFuture = fetchRoutePlaces();
  }

  @override
  void dispose() {
    items = [];
    stafflist = [];
    driverList = [];
    attenderList = [];
    vehicleList = [];
    routeList = [];
    requestList = [];
    enteredBy.dispose();
    aproxValueOfGoods.dispose();
    assignedAttender.dispose();
    assignedVehicle.dispose();
    assignedDriver.dispose();
    routePlaces.dispose();
    collectionRequest.dispose();
    super.dispose();
  }

  Future<void> submitData() async {
    final ApiService apiService = ApiService();
    final body = {
      "entered_by": enteredBy.text,
      "ordered_via": orderVia,
      "aprox_value_of_the_goods": aproxValueOfGoods.text,
      "assigned_driver": assignedDriver.text,
      "assigned_attender": assignedAttender.text.split(",")[0],
      "assigned_vehicle": assignedVehicle.text.split(",")[0],
      "route_name": routePlaces.text,
      "collection_req": items,
      "docstatus": 0,
    };
    try {
      final response = await apiService.createDocument(ApiEndpoints.authEndpoints.CollectionAssignment, body);
      if (response[0] == 200) {
        Fluttertoast.showToast(msg: "Document Saved Successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => CollectionAssignmentView(name: response[1])));
      }
    } catch (error) {
      print(error);
      throw "Error: Failed to submit data";
    }
  }

  void setEnterBy() async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    setState(() {
      enteredBy.text = manager.getString('email') ?? "";
    });
  }

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

  Future<List<String>> fetchAttender() async {
    print("Fetchattender");
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Employee",
      "filters": [["designation", "=", "Attender"], ["status", "=", "Active"]],
      "fields": ['name', 'employee_name']
    };
    try {
      final response = await apiService.getList(ApiEndpoints.authEndpoints.getList, body);
      print("$response ===================================response");
      setState(() {
        // attenderList = response;
        attenderList = response.map((item) {
          return "${item['name'] + "," + item['employee_name']}";
        }).toList();
      });
      print("$attenderList ========================================");
      return attenderList;
    } catch (e) {
      print("fetch error");
      throw "Fetch Error";
    }
  }

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
          return "${item[0]},${item[1]}" ;
        }).toList();
      });
      return vehicleList;
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
          return "${item[0]},${item[2]}" ;
        }).toList();
      });
      return requestList;
    } catch (e) {
      throw "Fetch Error";
    }
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> _showItemDialog({Map<String, String>? item, int? index}) async {
    collectionRequest.text = item?['collection_request'] ?? "";

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item == null ? 'Add Item' : 'Edit Item'),
          content: FutureBuilder<List<String>>(
            future: fetchRequestFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return DialogAutoComplete(
                  controller: collectionRequest,
                  hintText: 'Collection Request',
                  onSelected: (String selection) {
                    print('You selected: $selection');
                  },
                  options: requestList,
                );
              } else if (snapshot.hasData) {
                requestList = snapshot.data!;
                return DialogAutoComplete(
                  controller: collectionRequest,
                  hintText: 'Collection Request',
                  onSelected: (String selection) {
                    print(selection);
                  },
                  options: requestList,
                );
              } else {
                return DialogAutoComplete(
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
                if (item == null) {
                  Navigator.of(context).pop();
                } else {
                  setState(() {
                    items.removeAt(index!);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: Text(item == null ? 'Add' : 'Save'),
              onPressed: () {
                // if (_formKey.currentState!.validate()) {
                  if (item == null) {
                    setState(() {
                      items.add({"collection_request": collectionRequest.text.split(",")[0]});
                    });
                  } else {
                    setState(() {
                      items[index!]["collection_request"] = collectionRequest.text.split(",")[0];
                    });
                  }
                  collectionRequest.clear();
                  Navigator.of(context).pop();
                // }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Collection Assignment Form"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),
                FieldText(
                  controller: enteredBy,
                  labelText: "Entered By",
                  readOnly: true,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 10),
                DropDown(
                  labelText: "Order Via",
                  items: const [
                    "WhatApp",
                    "Phone",
                    "Email",
                    "Mobile App",
                  ],
                  selectedItem: orderVia,
                  onChanged: (String? newValue) {
                    setState(() {
                      orderVia = newValue;
                    });
                  },
                ),
                const SizedBox(height: 10),
                FieldText(
                  controller: aproxValueOfGoods,
                  labelText: "Aprox. Value of Goods",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Value of goods required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<String>>(
                  future: fetchVehicleFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return AutoComplete(
                        controller: assignedVehicle,
                        hintText: 'Assign Vehicle',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: vehicleList,
                      );
                    } else if (snapshot.hasData) {
                      vehicleList = snapshot.data!;
                      return AutoComplete(
                        controller: assignedVehicle,
                        hintText: 'Assign Vehicle',
                        onSelected: (String selection) {
                          print(selection);
                          licensetype.text = selection.split(",")[1];
                          fetchDriverFuture = fetchDriver(licensetype.text);
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
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<String>>(
                  future: fetchDriverFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return AutoComplete(
                        controller: assignedDriver,
                        hintText: 'Assign Driver',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: driverList,
                      );
                    } else if (snapshot.hasData) {
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
                const SizedBox(height: 10),
                FutureBuilder<List<String>>(
                  future: fetchAttenderFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return AutoComplete(
                        controller: assignedAttender,
                        hintText: 'Assign Attender',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: attenderList,
                      );
                    } else if (snapshot.hasData) {
                      attenderList = snapshot.data!;
                      return AutoComplete(
                        controller: assignedAttender,
                        hintText: 'Assign Attender',
                        onSelected: (String selection) {
                          print(selection);
                          // setState(() {
                            
                          // assignedAttender.text = selection.split(" ")[0];
                          // });
                        },
                        options: attenderList,
                      );
                    } else {
                      return AutoComplete(
                        controller: assignedAttender,
                        hintText: 'Assign Attender',
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

                          fetchRequestFuture = fetchRequest(selection.split(",")[0]);
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
                const SizedBox(height: 10),
                 Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25.0, vertical: 3.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Items"),
                    ElevatedButton(
                      child: const Icon(Icons.add),
                      onPressed:() {
                        _showItemDialog();
                      },
                    ),
                  ],
                ),
              ),
                const SizedBox(height: 10),
                if(items.isNotEmpty)
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
                // DottedBorder(
                //   color: Colors.black,
                //   strokeWidth: 1,
                //   dashPattern: const [5, 5],
                //   child: ListTile(
                //     title: const Text('Add Collection Request'),
                //     trailing: const Icon(Icons.add),
                //     onTap: () {
                //       _showItemDialog();
                //     },
                //   ),
                // ),
                const SizedBox(height: 10),
                if(items.isEmpty)
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
                        // color: isDarkMode ? Colors.white : Colors.black,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 20.0),
                          child: const Center(
                            child: Text("No Items Found"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                MyButton(
                  onTap: submitData,
                  name: 'Save',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
