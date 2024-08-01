import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/dialog_text.dart';
// import 'package:erpnext_logistics_mobile/fields/drop_down.dart';
import 'package:erpnext_logistics_mobile/fields/multi_select.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:erpnext_logistics_mobile/modules/auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';

class GdmForm extends StatefulWidget {
  const GdmForm({super.key});

  @override
  State<GdmForm> createState() => _GdmFormState();
}

class _GdmFormState extends State<GdmForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController dispatchOn = TextEditingController();
  final TextEditingController dispatchTime = TextEditingController();
  final TextEditingController dispatchNumber = TextEditingController();
  final TextEditingController advance = TextEditingController();
  final TextEditingController assignedDriver = TextEditingController();
  final TextEditingController assignedAttender = TextEditingController();
  final TextEditingController loadingStaffs = TextEditingController();
  final TextEditingController vehicleRegisterNo = TextEditingController();
  final TextEditingController lrSelected = TextEditingController();
  final TextEditingController lr = TextEditingController();
  final TextEditingController consignor = TextEditingController();
  final TextEditingController consignee = TextEditingController();
  final TextEditingController invoiceNo = TextEditingController();
  final TextEditingController destination = TextEditingController();
  final TextEditingController accountPay = TextEditingController();
  final TextEditingController toPay = TextEditingController();
  final TextEditingController isPaid = TextEditingController();
  final TextEditingController VOG = TextEditingController();
  final TextEditingController boxCount = TextEditingController();

  List<Map<String, String>> items = [];
  List<String> driverList = [];
  List<String> attenderList = [];
  List<String> lrList = [];

String? selectedDriver;
String? selectedStaff;
List<String> selectedLoadingStaffs = [];
List<String> selectedLr = [];
List<String> loadingStaffItems = [];
final List<String> selectLR = ['1', '2', '3'];



  @override
void dispose() {
  selectedLoadingStaffs = [];
  super.dispose();
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

  Future<List<String>> fetchLoadingStaff() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "Employee",
      "filters" : [["designation","=","Loading Staff"], ["status", "=", "Active"]]
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

  Future<List<String>> fetchLR() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype" : "LR",
      "filters" : [["status", "=", "Pending"], ["docstatus", "=", 1]]
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
    lr.text = item?['lr_no'] ?? "";
    consignor.text = item?['consignor'] ?? "";
    consignee.text = item?['consignee'] ?? "";
    invoiceNo.text = item?['invoice_no'] ?? "";
    destination.text = item?['destination'] ?? "";
    accountPay.text = item?['account_pay'] ?? "";
    toPay.text = item?['to_pay'] ?? "";
    isPaid.text = item?['is_paid'] ?? "";
    VOG.text = item?['value_of_goods'] ?? "";
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
                      const SizedBox(
                        height: 10,
                      ),
                      DialogTextField(
                        controller: lr,
                        keyboardType: TextInputType.name,
                        labelText: "Item Name",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      DialogTextField(
                        controller: consignor,
                        keyboardType: TextInputType.name,
                        labelText: "Consignor",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      DialogTextField(
                        controller: consignee,
                        keyboardType: TextInputType.name,
                        labelText: "Consignee",
                      ),
                      DialogTextField(
                        controller: invoiceNo,
                        keyboardType: TextInputType.name,
                        labelText: "Invoice No",
                      ),
                      DialogTextField(
                        controller: destination,
                        keyboardType: TextInputType.name,
                        labelText: "Destination",
                      ),
                      DialogTextField(
                        controller: accountPay,
                        keyboardType: TextInputType.number,
                        labelText: "Account Pay",
                      ),
                      DialogTextField(
                        controller: toPay,
                        keyboardType: TextInputType.number,
                        labelText: "ToPay",
                      ),
                      // DialogTextField(
                      //   controller: isPaid,
                      //   keyboardType: TextInputType.name,
                      //   labelText: "Consignee",
                      // ),
                      DialogTextField(
                        controller: VOG,
                        keyboardType: TextInputType.number,
                        labelText: "Value of Goods",
                      ),
                      DialogTextField(
                        controller: boxCount,
                        keyboardType: TextInputType.name,
                        labelText: "Box Count",
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
                          "lr_no": lr.text,
                          "consignor": consignor.text,
                          "consignee": consignee.text,
                          "invoice_no": invoiceNo.text,
                          "destination": destination.text,
                          "account_pay": accountPay.text,
                          "to_pay": toPay.text,
                          // "is_paid" : isPaid.text,
                          "value_of_goods": VOG.text,
                          "box_count": boxCount.text,
                        });
                      });
                      lr.clear();
                      consignor.clear();
                      consignee.clear();
                      invoiceNo.clear();
                      destination.clear();
                      VOG.clear();
                      accountPay.clear();
                      toPay.clear();
                      boxCount.clear();
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        items[index!]["lr_no"] = lr.text;
                        items[index]["consignor"] = consignor.text;
                        items[index]["consignee"] = consignee.text;
                        items[index]["invoice_no"] = invoiceNo.text;
                        items[index]["destination"] = destination.text;
                        items[index]["account_pay"] = accountPay.text;
                        items[index]["to_pay"] = toPay.text;
                        items[index]["value_of_goods"] = VOG.text;
                        items[index]["box_count"] = boxCount.text;
                      });
                      lr.clear();
                      consignor.clear();
                      consignee.clear();
                      invoiceNo.clear();
                      destination.clear();
                      VOG.clear();
                      accountPay.clear();
                      toPay.clear();
                      boxCount.clear();
                      Navigator.of(context).pop();
                    }
                  },
                )
              ]);
        });
  }

  void _showLoadingStaffs(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    List<String> filteredItems = loadingStaffItems;

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
                  const SizedBox(height: 10,),
                  FutureBuilder<List<String>>(
                  future: fetchLR(),
                  builder: (context, snapshot) {
                    if(snapshot.hasError) {
                      return AutoComplete(
                        controller: lr,
                        hintText: 'LR No.',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: lrList,
                      );
                    }
                    else if (snapshot.hasData) {
                      lrList = snapshot.data!;
                      return AutoComplete(
                        controller: lr,
                        hintText: 'LR No.',
                        onSelected: (String selection) {
                          print(selection);
                        },
                        options: lrList,
                      );
                    } else {
                      return AutoComplete(
                        controller: lr,
                        hintText: 'LR No.',
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                        options: lrList,
                      );
                    }
                  },
                ),
                  const SizedBox(height: 10,),
                  DialogTextField(
                    controller: consignor,
                    keyboardType: TextInputType.name,
                    labelText: "Consignor",
                  ),
                  const SizedBox(height: 10,),
                  DialogTextField(
                    controller: consignee,
                    keyboardType: TextInputType.name,
                    labelText: "Consignee",
                  ),
                  DialogTextField(
                    controller: invoiceNo,
                    keyboardType: TextInputType.name,
                    labelText: "Invoice No",
                  ),
                  DialogTextField(
                    controller: destination,
                    keyboardType: TextInputType.name,
                    labelText: "Destination",
                  ),
                  DialogTextField(
                    controller: accountPay,
                    keyboardType: TextInputType.number,
                    labelText: "Account Pay",
                  ),
                  DialogTextField(
                    controller: toPay,
                    keyboardType: TextInputType.number,
                    labelText: "ToPay",
                  ),
                  // DialogTextField(
                  //   controller: isPaid,
                  //   keyboardType: TextInputType.name,
                  //   labelText: "Consignee",
                  // ),
                  DialogTextField(
                    controller: VOG,
                    keyboardType: TextInputType.number,
                    labelText: "Value of Goods",
                  ),
                  DialogTextField(
                    controller: boxCount,
                    keyboardType: TextInputType.name,
                    labelText: "Box Count",
                  ),
                ],
              ),
            ),
          ),
      }
          actions: <Widget>[
            TextButton(
              child: Text(item == null ? 'Cancel' : 'Delete'),
              onPressed: () {
                if(item == null){
                  Navigator.of(context).pop();
                }
                else {
                  setState(() {
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
                    {"lr_no" : lr.text,
                     "consignor" : consignor.text,
                     "consignee" : consignee.text,
                     "invoice_no" : invoiceNo.text,
                     "destination" : destination.text,
                     "account_pay" : accountPay.text,
                     "to_pay" : toPay.text,
                     // "is_paid" : isPaid.text,
                     "value_of_goods" : VOG.text,
                     "box_count" : boxCount.text,
                     }
                  );
                  });
                  lr.clear();
                  consignor.clear();
                  consignee.clear();
                  invoiceNo.clear();
                  destination.clear();
                  VOG.clear();
                  accountPay.clear();
                  toPay.clear();
                  boxCount.clear();
                  Navigator.of(context).pop();
                }
                else {
                  setState(() {
                    items[index!]["lr_no"] = lr.text;
                    items[index]["consignor"] = consignor.text;
                    items[index]["consignee"] = consignee.text;
                    items[index]["invoice_no"] = invoiceNo.text;
                    items[index]["destination"] = destination.text;
                    items[index]["account_pay"] = accountPay.text;
                    items[index]["to_pay"] = toPay.text;
                    items[index]["value_of_goods"] = VOG.text;
                    items[index]["box_count"] = boxCount.text;
                  });
                  lr.clear();
                  consignor.clear();
                  consignee.clear();
                  invoiceNo.clear();
                  destination.clear();
                  VOG.clear();
                  accountPay.clear();
                  toPay.clear();
                  boxCount.clear();                  
                  Navigator.of(context).pop();
                }
              },
            )
          ]
        );
      },
);
  }
  Future<String> submitData() async{
    final body = {
      "dispatch_on": dispatchOn,
      "dispatch_time": dispatchTime,
      "dispatch_number": dispatchNumber,
      "advance": advance,
      "driver": assignedDriver,
      "delivery_staff": assignedAttender,
      "loading_staff": loadingStaffs,
      "vehicle_register_no": vehicleRegisterNo,
      "items": items,
    };
    return "";
  }



  void _showLoadingStaffs(BuildContext context) {
  TextEditingController searchController = TextEditingController();
  List<String> filteredItems = loadingStaffItems;

  fetchLoadingStaff().then((response) => {
    setState(() {
      loadingStaffItems = [];
      loadingStaffItems = response;
      // filteredItems = loadingStaffItems;
    })
  }).catchError((error) => {
    throw "Error: $error"
  });

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
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          filteredItems = loadingStaffItems;
                        });
                      },
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
                  onSelectedItemsListChanged: (List<String> newSelectedItems) {
                    setState(() {
                      selectedLoadingStaffs = newSelectedItems;
                      loadingStaffs.text = selectedLoadingStaffs.join(', ');
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


  void _showLR(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    List<String> filteredItems = selectLR;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select LR'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            filteredItems = selectLR;
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredItems = selectLR
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
                    selectedItems: selectedLr,
                    onSelectedItemsListChanged:
                        (List<String> newSelectedItems) {
                      setState(() {
                        selectedLr = newSelectedItems;
                        lrSelected.text = selectedLr.join(', ');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GDM'),
      ),
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate =
                          await DatePicker.showSimpleDatePicker(
                        context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        dateFormat: "dd-MMMM-yyyy",
                        locale: DateTimePickerLocale.en_us,
                        looping: true,
                      );
                      if (pickedDate != null) {
                        setState(() {
                          dispatchOn.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: FieldText(
                        controller: dispatchOn,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Dispatch date is required";
                          }
                          return null;
                        },
                        labelText: "Dispatch On",
                        obscureText: false,
                        keyboardType: TextInputType.name,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        showPicker(
                          context: context,
                          value: Time(
                            hour: TimeOfDay.now().hour,
                            minute: TimeOfDay.now().minute,
                          ),
                          onChange: (Time newTime) {
                            final newTimeOfDay = TimeOfDay(
                                hour: newTime.hour, minute: newTime.minute);
                            setState(() {
                              dispatchTime.text = newTimeOfDay.format(context);
                            });
                          },
                          is24HrFormat: false,
                          accentColor: Theme.of(context).colorScheme.secondary,
                          unselectedColor: Colors.grey,
                          okText: 'OK',
                          cancelText: 'Cancel',
                        ),
                      );
                    },
                    child: AbsorbPointer(
                      child: FieldText(
                        controller: dispatchTime,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Dispatch time is required";
                          }
                          return null;
                        },
                        labelText: "Dispatch Time",
                        obscureText: false,
                        keyboardType: TextInputType.name,
                      ),
                    ),
                  ),
                  // const SizedBox(height: 15.0),
                  // FieldText(
                  //     controller: dispatchNumber,
                  //     validator: (value) {
                  //       if (value == null || value.isEmpty) {
                  //         return 'Dispatch number is required';
                  //       }
                  //       return null;
                  //     },
                  //     labelText: "Dispatch Number",
                  //     obscureText: false,
                  //     keyboardType: TextInputType.number),
                  const SizedBox(height: 15.0),
                  FieldText(
                      controller: advance,
                      labelText: "Advance Amount",
                      obscureText: false,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 15.0),
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
                  const SizedBox(height: 15.0),
                  GestureDetector(
                    onTap: () => _showLoadingStaffs(context),
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
                  const SizedBox(height: 15.0),
                  FieldText(
                      controller: vehicleRegisterNo,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Vehicle Reg.no is required";
                        }
                        return null;
                      },
                      labelText: 'Vehicle Registration Number',
                      keyboardType: TextInputType.name),
                  const SizedBox(
                    height: 15.0,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
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
                              _showItemDialog();
                            },
                          ),
                        ],
                      )),
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
                      child: SizedBox(
                        height: 200, // Set a fixed height for the ListView
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
                                  title: Text(items[index]["lr_no"].toString()),
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
                    height: 15.0,
                  ),
                  MyButton(
                      onTap: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          submitData();
                        }
                      },
                      name: "Submit"),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}
