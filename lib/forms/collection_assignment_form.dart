import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/drop_down.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:flutter/material.dart';

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

  final _formKey = GlobalKey<FormState>();

  void submitData() {}

  Future<void> _showItemDialog({dynamic item, int? index}) async {
    collectionRequest.text = item?['collection_request'] ?? "";

    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(item == null ? 'Add Item' : 'Edit Item'),
            content: Form(
              key: _formKey,
              child: TextField(
                  controller: collectionRequest,
                  decoration: const InputDecoration(
                    labelText: "Collection Request",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    // fillColor: Colors.white,
                    filled: true,
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                  obscureText: false,
                  keyboardType: TextInputType.name),
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
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}
