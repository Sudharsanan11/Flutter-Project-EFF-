
import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_list/collection_assignment_list.dart';
import 'package:erpnext_logistics_mobile/doc_list/collection_request_list.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/dialog_text.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:erpnext_logistics_mobile/modules/auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/dialog_auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';



class CollectionRequestView extends StatefulWidget {
  final String name;
  const CollectionRequestView({super.key, required this.name});
  

  @override
  State<CollectionRequestView> createState() => _CollectionRequestViewState();
}

class _CollectionRequestViewState extends State<CollectionRequestView> {

  final TextEditingController consignor = TextEditingController();
  final TextEditingController consignee = TextEditingController();
  final TextEditingController location = TextEditingController();
  TextEditingController vehicle_required_date = TextEditingController();
  TextEditingController timePicker = TextEditingController();
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
  bool isDisabled = true;
  int docstatus = 0;
  // final response = "";

  @override
  void initState () {
    super.initState();
    print("===============================");
    print(widget.name);
    fetchCollectionRequest();
    fetchConsignor();
    fetchLocation();
    // fetchItem();
    print("fetch Consignor------------------------------------ ${fetchConsignor()}");
    // print(fetchConsignor());
    // setState(() {
    //   // consignorList = fetchConsignor();
    // });
  }

  @override
  void dispose() {
    consignor.dispose();
    consignee.dispose();
    location.dispose();
    vehicle_required_date.dispose();
    timePicker.dispose();
    status.dispose();
    itemName.dispose();
    itemWeight.dispose();
    itemVolume.dispose();
    no_of_pcs.dispose();
    consignorList = [];
    locationList = [];
    itemList = [];
    items = [];
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchCollectionRequest() async {
    print("widget.name ${widget.name}");
    ApiService apiService = ApiService();
    final response = await apiService.getDocument('${ApiEndpoints.authEndpoints.CollectionRequest}/${widget.name}');
    // consignor.text = response["consignor"];
    print("response $response");
    setState(() {
    consignor.text = response["consignor"] ??  "";
    location.text = response["location"] ?? "";
    vehicle_required_date.text = response["vehicle_required_date"] ?? "";
    timePicker.text = response["required_time"] ?? "";
    status.text = response["status"] ?? "";
    no_of_pcs.text = response["no_of_pcs"] != 0 ? response["no_of_pcs"].toString() : "0";
    docstatus = response["docstatus"];
    // items = response["items"] as List<Map<String, String>>;
    items = (response["items"] as List).map((item) {
    return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
      }).toList();
    if(response['status'] == "Open") {
      isDisabled = false;
    }
    });
    return response;
  }

  // void submitData() {}
  Future<String> submitData () async{
    print("submit");
    final ApiService apiService = ApiService();
    final body = {
      "consignor": consignor.text,
      "consignee": consignee.text,
      "location": location.text,
      "vehicle_required_date": vehicle_required_date.text,
      "required_time": timePicker.text,
      "items": items,
    };
    try {
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.CollectionRequest} / ${widget.name}', body);
      if(response == "200") {
        Fluttertoast.showToast(msg: "Document Canceled successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted) {
          Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => CollectionRequestView(name: widget.name)));
        }
      }
      else {
        Fluttertoast.showToast(msg: "Failed to submit data", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      }
      return "";
    }
    catch (error) {
      print(error);
      return "Error: Failed to submit data";
    }
  }

  Future<List<String>> fetchConsignor() async {
    print("fetchConsignor =================================================================");
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Customer",
      "filters" : [["custom_party_type","=","Consignor"]]
    };
    try {
      print("try=======");
      final response =  await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList , body);
      print("consignor============================== $response");
      return response;
    }
    catch(e) {
      throw "Fetch Error";
    }
  }

  Future<List<String>> fetchLocation () async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Location",
      // "filters" : [["is_warehouse","=","1"]]
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

  Future<List<String>> fetchItem () async {
    print("date ${vehicle_required_date.text}");
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


   void deleteDoc() async {
    final ApiService apiService = ApiService();
    try {
      final response = await apiService.deleteDocument('${ApiEndpoints.authEndpoints.CollectionRequest}/${widget.name}');
      if(response == "202") {
        Fluttertoast.showToast(msg: "Document deleted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CollectionAssignmentList()));
        }
      }
      else if(response == "417") {
        Fluttertoast.showToast(msg: "The document may be linked with other document try deleting that document first", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 5);
      }
      print(response);
    }
    catch(e) {
      print(e);
    }
  }

  Future<void> _showItemDialog({dynamic item, int? index}) async {
    print("items $items");
    itemName.text = item?['item_code'] ?? "";
    itemWeight.text = item?['appox_weight'] ?? "0";
    itemVolume.text = item?['volume'] ?? "0";


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
                    if(snapshot.hasError) {
                      return DialogAutoComplete(
                        controller: itemName,
                        readOnly: isDisabled,
                        hintText: 'Item Name',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                          setState(() {
                            itemName.text = selection;
                          });
                        },
                        options: itemList,
                      );
                    }
                    else if (snapshot.hasData) {
                      itemList = snapshot.data!;
                      return DialogAutoComplete(
                        controller: itemName,
                        readOnly: isDisabled,
                        hintText: 'Item Name',
                        onSelected: (String selection) {
                          print(selection);
                        },
                        options: itemList,
                      );
                    } else {
                      // 
                      return DialogAutoComplete(
                        controller: itemName,
                        hintText: 'Item Name',
                        readOnly: isDisabled,
                        onSelected: (String selection) {
                          print(selection);
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
                    readOnly: true,
                    labelText: "Weight",
                  ),
                  const SizedBox(height: 10,),
                  DialogTextField(
                    controller: itemVolume,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    labelText: "Volume",
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            if(!isDisabled)
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
            if(!isDisabled)
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


  Future<void> _showDatePicket (BuildContext context) async{
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2150),
      );
    
    if(picked != null) {
      setState(() {
        vehicle_required_date.text = "${picked.toLocal()}".split(" ")[0];
      });
    }
  }

  Future<void> _showTimePicker (BuildContext context) async{
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      );
    if(picked != null) {
      setState(() {
        timePicker.text = picked.format(context).split(" ")[0];
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if(didPop) {return;}
        Navigator.pushReplacement(context, 
        MaterialPageRoute(builder: (context) => const CollectionRequestList()));
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Collection Request'),
          actions: [
            Padding(padding: const EdgeInsets.only(right: 20),
            child: PopupMenuButton(
              itemBuilder: (context) => [
                
                if(status.text == "Open")
                const PopupMenuItem(
                  value: 0,
                  child: Text('Delete'),
                ),
              ],
              onSelected: (value) {
                setState(() {
                  // docstatus = value;
                 
                    deleteDoc();
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
              children: <Widget>[
                const SizedBox(height: 10,),
                FutureBuilder<List<String>>(
                  future: fetchConsignor(),
                  builder: (context, snapshot) { 
                    if(snapshot.hasError) {
                      return AutoComplete(
                        hintText: 'Consignor Name',
                        controller: consignor,
                        readOnly: isDisabled,
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
                    }
                    else if (snapshot.hasData) {
                      consignorList = snapshot.data!;
                      return AutoComplete(
                        controller: consignor,
                        hintText: 'Consignor Name',
                        readOnly: isDisabled,
                        onSelected: (String selection) {
                          print('You selected: ${consignor.text}');
                        },
                        options: consignorList,
                      );
                    } else {
                      return AutoComplete(
                        controller: consignor,
                        hintText: 'Consignor Name',
                        readOnly: isDisabled,
                        onSelected: (String selection) {
                          print('You selected: ${consignor.text}');
                        },
                        options: consignorList,
                      );
                    }
                  },
                ),
                const SizedBox(height: 10.0,),
                FutureBuilder<List<String>>(
                  future: fetchLocation(),
                  builder: (context, snapshot) {
                    if(snapshot.hasError) {
                      return AutoComplete(
                        controller: location,
                        hintText: 'Location',
                        readOnly: true,
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: locationList,
                      );
                    }
                    else if (snapshot.hasData) {
                      locationList = snapshot.data!;
                      return AutoComplete(
                        controller: location,
                        hintText: 'Location',
                        readOnly: true,
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: locationList,
                      );
                    } else {
                      return AutoComplete(
                        controller: location,
                        hintText: 'Location',
                        readOnly: true,
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: locationList,
                      );
                    }
                  },
                ),
                // const SizedBox(height: 10.0,),
                const SizedBox(height: 10.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 3.0
                  ),
                  child: TextField(
                  controller: vehicle_required_date,
                  keyboardType: TextInputType.datetime,
                  readOnly: true,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    labelText: "Required Date",
                    labelStyle: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: isDisabled ? (){} :() {
                    _showDatePicket(context);
                  },
                ),
                ),
                const SizedBox(height: 10.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 3.0
                  ),
                  child: TextField(
                    controller: timePicker,
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      labelText: "Required Time",
                      labelStyle: TextStyle(color: Colors.grey[600]),
                    ),
                    onTap: isDisabled ? (){} : () {
                      _showTimePicker(context);
                    },
                  ),
                ),
                const SizedBox(height: 10.0,),
                FieldText(
                  controller: status,
                  labelText: "Status",
                  readOnly: true,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 10.0,),
                FieldText(
                  controller: no_of_pcs,
                  labelText: "No. of Pcs",
                  readOnly: true,
                  keyboardType: TextInputType.none
                ),
                const SizedBox(height: 10.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Items"),
                      ElevatedButton(
                        child: Icon(Icons.add),
                        onPressed: isDisabled ? (){} : () {
                          _showItemDialog();
                        },
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
                          dashPattern: const [8, 4],
                          color: Colors.black,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                            child: const Center(
                              child: Text("No Items Found"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (items.isEmpty)
                  const SizedBox(height: 15.0),
                if (items.isEmpty)
                  MyButton(
                    onTap: isDisabled ? (){} : submitData,
                    name: "Save"
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
                if (items.isNotEmpty)
                  const SizedBox(height: 15.0),
                if (items.isNotEmpty)
                  MyButton(
                    onTap: isDisabled ? (){Fluttertoast.showToast(msg: "Can't able to save", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);} : submitData,
                    name: "Save",                    
                  ),
              ]
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavigation(),
      ),
    );
  }
}