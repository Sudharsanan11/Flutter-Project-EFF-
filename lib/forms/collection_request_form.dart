import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_view/collection_request_view.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/modules/auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/dialog_auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  
  String cons = "";
  List<String> consignorList = [];
  List<String> locationList = [];
  List<String> itemList = [];
  List<Map<String, String>> items = [];
  bool isEnabled = true;


  @override
  void initState() {
    super.initState();
    fetchConsignor();
    fetchLocation();
    print("fetch Consignor");
    print(fetchConsignor());
    setState(() {
      // consignorList = fetchConsignor();
    });
  }

  @override
  void dispose() {
    consignor.dispose();
    consignee.dispose();
    location.dispose();
    date.dispose();
    timePicker.dispose();
    status.dispose();
    itemName.dispose();
    itemWeight.dispose();
    itemVolume.dispose();
    consignorList = [];
    locationList = [];
    itemList = [];
    items = [];
    super.dispose();

  }

  Future<void> submitData() async {
    isEnabled = false;
    print("submit");
    final ApiService apiService = ApiService();
    final data = {
      "consignor": consignor.text,
      "location": location.text,  
      "vehicle_required_date": date.text,
      "required_time": timePicker.text,
      "items": items,
    };
    try {
      final response =  await apiService.createDocument(ApiEndpoints.authEndpoints.CollectionRequest, data);
      if(response[0] == 200) {
        Fluttertoast.showToast(msg: "Document Saved Successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted) {
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => CollectionRequestView(name: response[1])));
        }
      }
    }
    catch (error) {
      print(error);
      isEnabled = true;
      Fluttertoast.showToast(msg: "$error", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      throw "Error: Failed to submit data";
    }
  }

  Future<List<String>> fetchConsignor() async {
    print("fetchConsignor =================================================================");
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Customer",
      "filters": [
        ["custom_party_type", "=", "Consignor"]
      ]
    };
    try {
      print(ApiEndpoints.baseUrl + ApiEndpoints.authEndpoints.getList);
      print(body);
      final response =  await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList , body);
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

  Future<List<String>> fetchItem () async {
    print("date ${date.text}");
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

  Future<void> _showItemDialog({dynamic item, int? index}) async {
    print("items $items");
    itemName.text = item?['item_code'] ?? "";
    itemWeight.text = item?['item_weight'] ?? "";
    itemVolume.text = item?['item_vloume'] ?? "";


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
                  //   controller: itemName,
                  //   keyboardType: TextInputType.name,
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
                    return DialogAutoComplete(
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
                  }
                },
              ),
                  // const SizedBox(height: 10,),
                  // DialogTextField(
                  //   controller: itemWeight,
                  //   keyboardType: TextInputType.name,
                  //   labelText: "Weight",
                  // ),
                  // const SizedBox(height: 10,),
                  // DialogTextField(
                  //   controller: itemVolume,
                  //   keyboardType: TextInputType.name,
                  //   labelText: "Volume",
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
                     "item_weight" : itemWeight.text,
                     "item_volume" : itemVolume.text,
                     }
                  );
                  });
                  itemName.clear();
                  itemWeight.clear();
                  itemVolume.clear();
                  Navigator.of(context).pop();
                }
                else {
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
          ]
        );
      }
    );
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Consignor name is required";
                        }
                        return null;
                      },
                      hintText: 'Consignor Name',
                      controller: consignor,
                      onSelected: (String selection) {
                        print('You selected: $selection');
                        setState(() {
                          print("sele");
                          consignor.text = selection;
                          fetchItem();
                        });
                      },
                      options: consignorList,
                    );
                  } else if (snapshot.hasData) {
                    consignorList = snapshot.data!;
                    return AutoComplete(
                      controller: consignor,
                      hintText: 'Consignor Name',
                      onSelected: (String selection) {
                        print('You selected: ${consignor.text}');
                      },
                      options: consignorList,
                    );
                  } else {
                    return const Text("");
                  }
                },
              ),
              // const SizedBox(
              //   height: 10.0,
              // ),
              // FutureBuilder<List<String>>(
              //   future: fetchLocation(),
              //   builder: (context, snapshot) {
              //     if (snapshot.hasError) {
              //       return AutoComplete(
              //         controller: location,
              //         hintText: 'Location',
              //         onSelected: (String selection) {
              //           print('You selected: $selection');
              //         },
              //         options: locationList,
              //       );
              //     } else if (snapshot.hasData) {
              //       locationList = snapshot.data!;
              //       return AutoComplete(
              //         controller: location,
              //         hintText: 'Location',
              //         onSelected: (String selection) {
              //           print('You selected: $selection');
              //         },
              //         options: locationList,
              //       );
              //     } else {
              //       return const Text("");
              //     }
              //   },
              // ),
              const SizedBox(height: 10.0,),
              
              // AutoComplete(hintText: 'Type something',onSelected: (String selection) {
              //   print('You selected: $selection'); },options: options,),
              // FieldText(
              //   controller: consignor,
              //   labelText: "Vehicle Required Date",
              //   obscureText: false,
              //   keyboardType: TextInputType.text
              // ),
              const SizedBox(height: 10.0,),
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
                    return null;
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isDarkMode ? Colors.white : Colors.black),
                          borderRadius: BorderRadius.circular(10)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    fillColor: isDarkMode ? Colors.black54 : Colors.white,
                    filled: true,
                    labelText: "Vehicle Required Date",
                    labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey[600]),
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
                    return null;
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isDarkMode ? Colors.white : Colors.black),
                          borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: isDarkMode ? Colors.black54 : Colors.white,
                    filled: true,
                    labelText: "Required Time",
                    labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey[600]),
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
                      onPressed: isEnabled ? () {
                        _showItemDialog();
                      } : null,
                      child: const Icon(Icons.add),
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
                        color: isDarkMode ? Colors.white : Colors.black,
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
              if (items.isEmpty)
                MyButton(
                    onTap: isEnabled ? () {
                      if (_formKey.currentState?.validate() ?? false) {
                        submitData();
                      }
                    } : (){
                      print("enable check");
                      Fluttertoast.showToast(
                        msg: "Can't enable to Save",
                        // backgroundColor: Color(00000000)
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 2,
                      );
                    },
                    name: "Save"),
                // ElevatedButton(
                //   // style: ",
                //   onPressed: isEnabled ? () {
                //     if (_formKey.currentState?.validate() ?? false) {
                //           submitData();
                //         }
                //   } : null, 
                //   child: const Text("Save")
                // ),
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
                  ),
              if (items.isNotEmpty) const SizedBox(height: 15.0),
              if (items.isNotEmpty)
               MyButton(
                onTap: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    submitData();
                  }
                },
                name: "Save"),
            ]),
          ),
        ),
      ),
      // persistentFooterButtons: <Widget>[
      //   if (items.isNotEmpty)
      //   MyButton(
      //     onTap: () {
      //       if (_formKey.currentState?.validate() ?? false) {
      //         submitData();
      //       }
      //     },
      //     name: "Save"),
      //     Padding(
      //       padding: EdgeInsets.only(right: 20),
      //       child: TextButton(onPressed: () {}, child: Text("Save"),))
      // ],
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}
