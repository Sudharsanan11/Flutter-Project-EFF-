import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/dialog_text.dart';
import 'package:erpnext_logistics_mobile/modules/auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:flutter/material.dart';

class CollectionRequestForm extends StatefulWidget {
  const CollectionRequestForm({super.key});

  @override
  State<CollectionRequestForm> createState() => _CollectionRequestFormState();
}

class _CollectionRequestFormState extends State<CollectionRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController consignor = TextEditingController();
  final TextEditingController consignee = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController date = TextEditingController();
  final TextEditingController timePicker = TextEditingController();
  final TextEditingController status = TextEditingController();
  final TextEditingController no_of_pcs = TextEditingController();
  final TextEditingController itemName = TextEditingController();
  final TextEditingController itemWeight = TextEditingController();
  final TextEditingController itemVolume = TextEditingController();

  List<String> consignorList = [];
  List<String> locationList = [];

  final List<String> options = <String>[
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grape',
    'Honeydew',
  ];

  List<Map<String, String>> items = [];

  @override
  void initState() {
    super.initState();
    fetchConsignor();
    fetchLocation();
    print("fetch Consignor");
    print(fetchConsignor());
    setState(() {});
  }

  Future<String> submitData() async {
    print("submit");
    final ApiService apiService = ApiService();
    final data = {
      "consignor": consignor.text,
      "consignee": consignee.text,
      "location": location.text,
      "vehicle_required_date": date.text,
      "required_time": timePicker.text,
      "items": items,
    };
    try {
      return await apiService.createDocument(
          ApiEndpoints.authEndpoints.createCollectionRequest, data);
    } catch (error) {
      print(error);
      return "Error: Failed to submit data";
    }
  }

  Future<List<String>> fetchConsignor() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Customer",
      "filters": [
        ["custom_party_type", "=", "Consignor"]
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

  Future<List<String>> fetchLocation() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Location",
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

  Future<void> _showItemDialog({dynamic item, int? index}) async {
    itemName.text = item?['item_code'] ?? "";
    itemWeight.text = item?['item_weight'] ?? "";
    itemVolume.text = item?['item_volume'] ?? "";

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
                      DialogTextField(
                        controller: itemName,
                        keyboardType: TextInputType.name,
                        labelText: "Item Name",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      DialogTextField(
                        controller: itemWeight,
                        keyboardType: TextInputType.number,
                        labelText: "Weight",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      DialogTextField(
                        controller: itemVolume,
                        keyboardType: TextInputType.number,
                        labelText: "Volume",
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
                          "item_weight": itemWeight.text,
                          "item_volume": itemVolume.text,
                        });
                      });
                      itemName.clear();
                      itemWeight.clear();
                      itemVolume.clear();
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        items[index!]["item_code"] = itemName.text;
                        items[index]["item_weight"] = itemWeight.text;
                        items[index]["item_volume"] = itemVolume.text;
                      });
                      itemName.clear();
                      itemWeight.clear();
                      itemVolume.clear();
                      Navigator.of(context).pop();
                    }
                  },
                )
              ]);
        });
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
        date.text = "${picked.toLocal()}".split(" ")[0];
      });
    }
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        timePicker.text = picked.format(context).split(" ")[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Request'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              FutureBuilder<List<String>>(
                future: fetchConsignor(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return AutoComplete(
                      hintText: 'Consignor Name',
                      onSelected: (String selection) {
                        print('You selected: $selection');
                      },
                      options: consignorList,
                    );
                  } else if (snapshot.hasData) {
                    consignorList = snapshot.data!;
                    return AutoComplete(
                      hintText: 'Consignor Name',
                      onSelected: (String selection) {
                        print('You selected: $selection');
                      },
                      options: consignorList,
                    );
                  } else {
                    return const Text("");
                  }
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              FutureBuilder<List<String>>(
                future: fetchLocation(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return AutoComplete(
                      hintText: 'Location',
                      onSelected: (String selection) {
                        print('You selected: $selection');
                      },
                      options: locationList,
                    );
                  } else if (snapshot.hasData) {
                    locationList = snapshot.data!;
                    return AutoComplete(
                      hintText: 'Location',
                      onSelected: (String selection) {
                        print('You selected: $selection');
                      },
                      options: locationList,
                    );
                  } else {
                    return Text("");
                  }
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25.0, vertical: 3.0),
                child: TextFormField(
                  controller: date,
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Date is required";
                    }
                    return null; // Added return statement
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    labelText: "Vehicle Date",
                    labelStyle: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () {
                    _showDatePicket(context);
                  },
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25.0, vertical: 3.0),
                child: TextFormField(
                  controller: timePicker,
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Time is required";
                    }
                    return null; // Added return statement
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    labelText: "Required Time",
                    labelStyle: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () {
                    _showTimePicker(context);
                  },
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25.0, vertical: 3.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25.0, vertical: 3.0),
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (items.isEmpty) const SizedBox(height: 15.0),
              if (items.isEmpty) MyButton(onTap: () {
                if (_formKey.currentState?.validate() ?? false) {
                  submitData();
                }
              }, name: "Submit"),
              if (items.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 17.0, vertical: 3.0),
                  child: SizedBox(
                    height: 200,
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
              if (items.isNotEmpty) const SizedBox(height: 15.0),
              if (items.isNotEmpty) MyButton(onTap: () {
                if (_formKey.currentState?.validate() ?? false) {
                  submitData();
                }
              }, name: "Submit"),
            ]),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}
