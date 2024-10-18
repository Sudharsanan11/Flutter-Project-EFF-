
import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_list/gdm_list.dart';
import 'package:erpnext_logistics_mobile/doc_view/loading_details_form.dart';
import 'package:erpnext_logistics_mobile/doc_view/unloading_details_form.dart';
import 'package:erpnext_logistics_mobile/doc_view/vehicle_log_form.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/dialog_text.dart';
import 'package:erpnext_logistics_mobile/fields/drop_down.dart';
import 'package:erpnext_logistics_mobile/fields/multi_select.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:erpnext_logistics_mobile/modules/auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/dialog_auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';

class GDMView extends StatefulWidget {
  final String name;
  const GDMView({super.key, this.name=""});

  @override
  State<GDMView> createState() => _GDMViewState();
}

class _GDMViewState extends State<GDMView> {
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
  // final TextEditingController isPaid = TextEditingController();
  final TextEditingController VOG = TextEditingController();
  final TextEditingController boxCount = TextEditingController();
  final TextEditingController docstatus = TextEditingController();
  final TextEditingController licensetype = TextEditingController();
  final TextEditingController vt = TextEditingController();
  final TextEditingController supplier = TextEditingController();
  final TextEditingController rentalAmount = TextEditingController();
  final TextEditingController currentBranch = TextEditingController();
  final TextEditingController targetBranch = TextEditingController();
  final TextEditingController dt = TextEditingController();
  final TextEditingController routePlaces = TextEditingController();
  final TextEditingController status = TextEditingController();
  final TextEditingController totalAmount = TextEditingController();
  final TextEditingController toPayTotal= TextEditingController();
  final TextEditingController totalWeight = TextEditingController();
  final TextEditingController totalVOG= TextEditingController();
  final TextEditingController timePicker =TextEditingController();
  final TextEditingController totalBoxCount = TextEditingController();
  final TextEditingController branchLr = TextEditingController();

  //Trip Details
  final TextEditingController noOfDeliveries = TextEditingController();
  final TextEditingController vehicleCurrentLocation= TextEditingController();
  final TextEditingController locationForNextDelivery = TextEditingController();
  final TextEditingController distanceForNextDelivery= TextEditingController();
  final TextEditingController durationForNextDelivery = TextEditingController();
  final TextEditingController lastDeliveryLocation = TextEditingController();
  final TextEditingController lastDeliveryDate = TextEditingController();
  final TextEditingController currentLoadInVehicle = TextEditingController();
  final TextEditingController noOfDeliveriesPending = TextEditingController();
  final TextEditingController totalKMtoReachBackDepo = TextEditingController();

  List<Map<String, String>> items = [];
  List<String> driverList = [];
  List<String> attenderList = [];
  List<String> lrList = [];
  List<String> supplierList = [];
  List<String> branchList = [];
  List<String> targetBranchList = [];
  bool isPaid = false;
  bool isLoading = false;
  String? isBranchLr;
  bool isDelivered = false;
  bool isDeliveredToBranch = false;
  
  // List<String> loadingStaffList = [];

  // PM Fields
  bool PMChecked = false;
  bool engineOil = false;
  bool bs6Oil = false;
  bool tyrePressure = false;
  bool brakes = false;
  bool mirrors = false;
  bool jacky = false;
  bool wavc = false;
  bool lights = false;
  bool wiper = false;
  bool horn = false;
  bool stepney = false;
  bool wheelspanner = false;
  bool jackyLiver = false;
  bool allTools = false;
  bool tarpolin = false;
  bool rope = false;
  bool otherAccessories = false;
  bool pallet = false;
  bool scanner = false;
  bool isIssue = false;
  String issueDescription = "";

  String? selectedDriver;
  String? selectedStaff;
  String? vehicleType;
  String? deliveryType;
  List<String> routeList = [];
  List<String> selectedLoadingStaffs = [];
  List<String> vehicleList = [];
  List<Map<String, dynamic>> itemsDict = [];
  List<Map<String, String>> loadingStaffDict = [];
  List<String> selectedLr = [];
  List<String> loadingStaffItems = [];
  late Future<List<String>> fetchAttenderList;
  late Future<List<String>> fetchDriverList;
  late Future<List<String>> fetchLRList;

  late Future<List<String>> fetchVehicleFuture;
late Future<List<String>> fetchAttenderFuture;
late  Future<List<String>> fetchRequestFuture;
late Future<List<String>> fetchDriverFuture;
late Future<List<String>> fetchRoutePlacesFuture;
late Future<List<String>> fetchSupplierFuture;
late Future<List<String>> fetchBranchFuture;
late Future<List<String>> fetchTargetBranchFuture;
  bool isDisabled = false;
  Map<String, Map<String, dynamic>> lrDict = {};
  // late Future<List<String>> fetchLoadingStaffList;
  final List<String> selectLR = ['1', '2', '3'];

  @override
  void dispose() {
    selectedLoadingStaffs = [];
    items = [];
    dispatchOn.dispose();
    dispatchTime.dispose();
    dispatchNumber.dispose();
    advance.dispose();
    assignedDriver.dispose();
    assignedAttender.dispose();
    vehicleRegisterNo.dispose();
    lrSelected.dispose();
    lr.dispose();
    consignor.dispose();
    consignee.dispose();
    invoiceNo.dispose();
    destination.dispose();
    accountPay.dispose();
    toPay.dispose();
    itemsDict = [];
    VOG.dispose();
    boxCount.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchAttenderList = fetchAttender();
    fetchLRList = fetchLR();
    // fetchLoadingStaffList = fetchLoadingStaff();
     fetchDriverFuture = fetchDriver("");
    fetchAttenderFuture = fetchAttender();
    fetchVehicleFuture = fetchVehicle("Owned");
    fetchRoutePlacesFuture = fetchRoutePlaces();
    fetchSupplierFuture = fetchSupplier();
    fetchBranchFuture = fetchBranch();
    fetchTargetBranchFuture = fetchBranch();
    docstatus.text = "-1";
    if(widget.name != ""){
      fetchGDM();
    }
  }

  //  Future<void> fetchInitialData() async {
  //   try {
  //     await fetchAttenderFuture;
  //     await fetchVehicleFuture;
  //     await fetchRoutePlacesFuture;
  //     await fetchBranchFuture;
  //     await fetchSupplierFuture;

  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  //   catch (error) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     print(error);
  //   }
  // }

  Future<Map<String, dynamic>> fetchGDM() async {
    setState(() {
      isLoading = true;
    });
    print("fetch gdm");
    final ApiService apiService = ApiService();
    Object body = {
      "doctype": "GDM",
      "name" : widget.name,
    };
    try {
      final response = await apiService
          .getDoc(ApiEndpoints.authEndpoints.get, body);
      setState(() {
        dispatchOn.text = response["dispatch_on"] ?? "";
        timePicker.text = response["dispatch_time"] ?? "";
        dispatchNumber.text = response["name"] ?? "";
        advance.text = response["advance"]?.toString() ?? "0";
        assignedDriver.text = response["driver"] ?? "";
        assignedAttender.text = response["delivery_staff"] ?? "";
        docstatus.text = response["docstatus"].toString();
        vt.text = response["vehicle_type"] ?? "";
        dt.text = response["delivery_type"] ?? "";
        supplier.text = response["supplier"] ?? "";
        rentalAmount.text = response["rental_amount"]?.toString() ?? "0";
        routePlaces.text = response["route_name"] ?? "";
        currentBranch.text = response["current_branch"] ?? "";
        targetBranch.text = response["target_branch"] ?? "";
        vehicleCurrentLocation.text = response["vehicle_current_location"] ?? "";
        totalAmount.text = response["total_amount"]?.toString() ?? "0";
        toPayTotal.text = response["topay_total"]?.toString() ?? "0";
        totalWeight.text = response["total_weight"]?.toString() ?? "0";
        totalVOG.text = response["total_vog"]?.toString() ?? "0";

        status.text = response["status"] ?? "";
        loadingStaffItems = (response["loading_staffs"] as List).map<String>((item) {
          return item['loading_staff'].toString();
        }).toList();
        loadingStaffDict = (response["loading_staffs"] as List).map<Map<String, String>>((item){
          return {"loading_staff": item['loading_staff'].toString()};
        }).toList();
        selectedLoadingStaffs = loadingStaffItems;
        loadingStaffs.text = loadingStaffItems.join(', ').toString();
        vehicleRegisterNo.text = response["vehicle_register_no"] ?? "";
        items = (response['items'] as List).map((item) {
          return (item as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, value.toString()));
        }).toList();
        itemsDict = (response['items'] as List).map((item) {
          return (item as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, value.toString()));
        }).toList();
        if(docstatus.text != "0") {
          isDisabled = true;
        }

        if(docstatus.text == "1" || docstatus.text == "2"){
          noOfDeliveries.text = response['no_of_deliveries'].toString();
          vehicleCurrentLocation.text = response['vehicle_current_location'] ?? "";
          locationForNextDelivery.text = response['location_for_next_delivery'] ?? "";
          distanceForNextDelivery.text = response['distance_for_next_delivery']?.toString() ?? "0";
          durationForNextDelivery.text = response['duration_for_next_delivery']?.toString() ?? "0";
          lastDeliveryLocation.text = response['last_delivery_location'] ?? "";
          lastDeliveryDate.text = response['last_delivery_date'] ?? "";
          currentLoadInVehicle.text = response['current_load_in_the_vehicle']?.toString() ?? "0";
          noOfDeliveriesPending.text = response['no_of_deliveries_pending']?.toString() ?? "0";
          totalKMtoReachBackDepo.text = response['km_to_reach_back_depo']?.toString() ?? "0";
        }

        List check_list = response['check_list'];
        print(check_list);
        if(check_list.isNotEmpty){
          engineOil = check_list[0]['engine_oil'] == 1 ? true : false;
          bs6Oil = check_list[0]['bs6_oil'] == 1 ? true : false;
          tyrePressure = check_list[0]['tyre_pressure'] == 1 ? true : false;
          brakes = check_list[0]['brakes'] == 1 ? true : false;
          mirrors = check_list[0]['mirrors'] == 1? true : false;
          jacky = check_list[0]['jacky'] == 1? true : false;
          wavc = check_list[0]['wavc'] == 1? true : false;
          lights = check_list[0]['lights'] == 1? true : false;
          wiper = check_list[0]['wiper'] == 1? true : false;
          horn = check_list[0]['horn'] == 1? true : false;
          stepney = check_list[0]['stepney'] == 1? true : false;
          wheelspanner = check_list[0]['wheel_spanner'] == 1? true : false;
          jackyLiver = check_list[0]['jacky_liver'] == 1? true : false;
          allTools = check_list[0]['all_tools'] == 1? true : false;
          tarpolin = check_list[0]['tarpolin'] == 1? true : false;
          rope = check_list[0]['rope'] == 1? true : false;
          otherAccessories = check_list[0]['other_accessories'] == 1? true : false;
          pallet = check_list[0]['pallet'] == 1? true : false;
          scanner = check_list[0]['scanner'] == 1? true : false;
          isIssue = check_list[0]['is_issue'] == 1? true : false;
          issueDescription = check_list[0]['issue_description']?? "";
        }
        isLoading = false;
      });
      return response;
    } catch (e) {
      print("Error fetching GDM: $e");
      setState(() {
        isLoading = false;
      });
      throw "Fetch Error: $e";
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

  Future<List<String>> fetchLR() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Collection Request",
      "filters": {"route_name": routePlaces.text, "branch": currentBranch.text},
      "txt": "",
      "searchfield": "",
      "start": "",
      "page_len": 0,
    };
    try {
      final response = await apiService.fetchFieldData(
          ApiEndpoints.authEndpoints.fetchLR, body);
      print(response);
      setState(() {
        lrList = response.map((item) {
          return "${item['name']}, ${item['destination']}";
        }).toList();
        for(var item in response) {
          var name = item['name'];
          lrDict[name] = item;
      }
      });
      return lrList;
    } catch (e) {
      throw "Fetch Error";
    }
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
      final response = await apiService.fetchFieldData(ApiEndpoints.authEndpoints.getDriver, body);
      setState(() {
        driverList = response.map((item) {
          return "${item[0]}, ${item[2]}";
        }).toList();
      });
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

   Future<List<String>> fetchSupplier() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Supplier",
      "filters": [["disabled", "=", 0]]
    };
    try {
      final response = await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList, body);
      return response;
    } catch (e) {
      throw "Fetch Error";
    }
  }

   Future<List<String>> fetchBranch() async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Branch",
    };
    try {
      final response = await apiService.getLinkedNames(ApiEndpoints.authEndpoints.getList, body);
      return response;
    } catch (e) {
      throw "Fetch Error";
    }
  }


   Future<List<String>> fetchVehicle(vehicletype) async {
    final ApiService apiService = ApiService();
    final body = {
      "doctype": "Vehicle",
      "txt": "",
      "searchfield": "",
      "start": "",
      "page_len": "",
      "filters": {
        "vehicle_type": vehicletype
      }
      // "filters": [["is_active", "=", 1]]
    };
    try {
      final response = await apiService.fetchFieldData(ApiEndpoints.authEndpoints.getVehicle, body);
      print(response);
      print("reposne");
      setState(() {
        vehicleList = response.map((item) {
          return "${item[0]},${item[1]}";
        }).toList();
      });
      return vehicleList;
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
      setState(() {
        // attenderList = response;
        attenderList = response.map((item) {
          return "${item['name'] + "," + item['employee_name']}";
        }).toList();
      });
      return attenderList;
    } catch (e) {
      print("fetch error");
      throw "Fetch Error";
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


  Future<void> _showItemDialog({dynamic item, int? index}) async {
    lr.text = item?['lr_no'] ?? "";
    consignor.text = item?['consignor'] ?? "";
    consignee.text = item?['consignee'] ?? "";
    invoiceNo.text = item?['invoice_number'] ?? "";
    destination.text = item?['destination'] ?? "";
    accountPay.text = item?['account_pay'] ?? "";
    toPay.text = item?['to_pay'] ?? "";
    // isPaid = item?['is_paid'] ;
    VOG.text = item?['value_of_goods'] ?? "";
    boxCount.text = item?['box_count'] ?? "";
    setState(() {
      isBranchLr = item?['is_branch_lr'] ?? "";
      if(item['is_delivered'] == "1"){
        isDelivered = true;
      }
      if(item['is_delivered'] == "0"){
        isDelivered = false;
      }
      if(item['is_delivered_to_branch'] == "1"){
        isDeliveredToBranch = true;
      }
      if(item['is_delivered_to_branch'] == "0"){
        isDeliveredToBranch = false;
      }
    });

    void setChildData(lr){
    setState(() {  
    consignor.text = lrDict[lr]!['consignor'] ?? "";
    consignee.text = lrDict[lr]!['consignee'] ?? "";
    invoiceNo.text = lrDict[lr]!['invoice_number'] ?? "";
    destination.text = lrDict[lr]!['destination'] ?? "";
    VOG.text = lrDict[lr]!['value_of_goods']?.toString() ?? "0";
    boxCount.text = lrDict[lr]!['box_count']?.toString() ?? "0";
    if(lrDict[lr]!['payment_type'] == "Account Pay"){
      accountPay.text = lrDict[lr]!['total_freight']?.toString() ?? "0";
    }
    else if(lrDict[lr]!['payment_type'] == "ToPay"){
      toPay.text = lrDict[lr]!['topay']?.toString() ?? "0";
    }
    else if(lrDict[lr]!['payment_type'] == "Paid"){
      isPaid = true;
    }
    });
  }

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
                      FutureBuilder<List<String>>(
                        future: fetchLRList,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return DialogAutoComplete(
                              controller: lr,
                              hintText: 'LR No.',
                              readOnly: isDisabled,
                              onSelected: (String selection) {
                                print('You selected: $selection');
                              },
                              options: lrList,
                            );
                          } else if (snapshot.hasData) {
                            lrList = snapshot.data!;
                            return AutoComplete(
                              controller: lr,
                              hintText: 'LR No.',
                              readOnly: isDisabled,
                              onSelected: (String selection) {
                                print(selection);
                                setChildData(selection.split(",")[0]);
                              },
                              options: lrList,
                            );
                          } else {
                            return FieldText(
                              controller: lr,
                              readOnly: true,
                              labelText: "LR No.",
                              keyboardType: TextInputType.none,
                            );
                          }
                        },
                      ),
                      // if(docstatus.text == "1")
                      Column(
                        children: [
                          const SizedBox(height: 10,),
                          DialogTextField(controller: consignor, keyboardType: TextInputType.name, readOnly: true, labelText: "Consignor",),
                          const SizedBox(height: 10,),
                          DialogTextField(controller: consignee, keyboardType: TextInputType.name, readOnly: true, labelText: "Consignee",),
                          const SizedBox(height: 10,),
                          if(dt.text == 'Mixed Delivery')
                          DropDown(labelText: "Is Branch LR", items: const ['Yes', "No"], selectedItem: isBranchLr, onChanged: (value) => setState(() {isBranchLr = value.toString(); branchLr.text = value.toString();}),),
                          if(dt.text != 'Mixed Delivery')
                          FieldText(controller: branchLr, labelText: "Is Branch LR", keyboardType: TextInputType.none, readOnly: true,),
                          const SizedBox(height: 10,),
                          DialogTextField(controller: invoiceNo, keyboardType: TextInputType.name, readOnly: true, labelText: "Invoice No",),
                          const SizedBox(height: 10,),
                          DialogTextField(controller: destination, keyboardType: TextInputType.name, readOnly: true, labelText: "Destination",),
                          const SizedBox(height: 10,),
                          DialogTextField(controller: accountPay, keyboardType: TextInputType.number, readOnly: isDisabled, labelText: "Account Pay",),
                          const SizedBox(height: 10,),
                          DialogTextField(controller: toPay, keyboardType: TextInputType.number, readOnly: isDisabled, labelText: "ToPay",),
                          const SizedBox(height: 10,),
                          Row(children: [
                          Checkbox(value: isPaid, onChanged: null,),
                          const Text("Is Paid"),
                          ],),
                          const SizedBox(height: 10,),
                          DialogTextField(controller: VOG, keyboardType: TextInputType.number, readOnly: true, labelText: "Value of Goods",),
                          const SizedBox(height: 10,),
                          DialogTextField(controller: boxCount, keyboardType: TextInputType.name, readOnly: true, labelText: "Box Count",),
                          if(branchLr.text == "No")
                          Row(children: [
                          Checkbox(value: isDelivered, onChanged: null,),
                          const Text("Is Delivered"),
                          ],),
                          if(branchLr.text == "Yes")
                          Row(children: [
                          Checkbox(value: isDeliveredToBranch, onChanged: null,),
                          const Text("Is Delivered to Branch"),
                          ],),
                        ],
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
                          itemsDict.remove(item);
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
                          "invoice_number": invoiceNo.text,
                          "destination": destination.text,
                          "account_pay": accountPay.text,
                          "to_pay": toPay.text,
                          // "is_paid" : isPaid.text,
                          "value_of_goods": VOG.text,
                          "box_count": boxCount.text,
                          "is_branch_lr": branchLr.text,
                        });
                        itemsDict.add({"lr_no": lr.text.split(",")[0], "account_pay": accountPay.text, "to_pay": toPay.text, "is_paid": isPaid, "is_branch_lr": branchLr.text});
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
                        items[index]["invoice_number"] = invoiceNo.text;
                        items[index]["destination"] = destination.text;
                        items[index]["account_pay"] = accountPay.text;
                        items[index]["to_pay"] = toPay.text;
                        items[index]["value_of_goods"] = VOG.text;
                        items[index]["box_count"] = boxCount.text;
                        itemsDict[index]['lr_no'] = lr.text.split(",")[0];
                        itemsDict[index]["account_pay"] = accountPay.text;
                        itemsDict[index]["to_pay"] = toPay.text;
                        itemsDict[index]["is_paid"] = isPaid;
                        itemsDict[index]["is_branch_lr"] = branchLr.text;
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

  Future<void> saveData() async {
    print("update");
    final ApiService apiService = ApiService();
    final body = {
      "dispatch_on": dispatchOn.text,
      "dispatch_time": timePicker.text,
      "dispatch_number": dispatchNumber.text,
      "advance": advance.text,
      "driver": assignedDriver.text.split(",")[0],
      "delivery_staff": assignedAttender.text.split(",")[0],
      "loading_staffs": loadingStaffDict,
      "vehicle_register_no": vehicleRegisterNo.text.split(",")[0],
      "vehicle_type" : vt.text,
      "supplier": supplier.text,
      "rental_amount": rentalAmount.text,
      "route_name": routePlaces.text,
      "current_branch": currentBranch.text,
      "target_branch": targetBranch.text,
      "items": itemsDict,
      "docstatus": 0,
    };
    try {
      if(docstatus.text == "-1"){
        final response = await apiService.createDocument(ApiEndpoints.authEndpoints.GDM, body);

        if(response[0] == 200){
          Fluttertoast.showToast(
              msg: "Document created successfully",
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => GDMView(name: response[1])));
        }
      }
      if(docstatus.text == "0"){
        
      final response = await apiService.updateDocument(
          '${ApiEndpoints.authEndpoints.GDM}/${widget.name}', body);
      if (response == '200') {
        Fluttertoast.showToast(
            msg: "Document updated successfully",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => GDMView(name: widget.name,)));
      }
      } else {
        Fluttertoast.showToast(
            msg: "Can't able to save",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
      }
    } catch (error) {
      // throw "Error: Failed to submit";
      print("Exception: $error");
       Fluttertoast.showToast(
            msg: "$error",
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2);
    }
  }

   void submitDoc() async{
    final ApiService apiService = ApiService();
    final body = {
      "docstatus" : 1
    };
    try {
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.GDM}/${widget.name}', body);
      print(response);
      if(response == "200") {
        Fluttertoast.showToast(msg: "Document Submitted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted) {
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => GDMView(name: widget.name)));
        }
        // initState();
      }
      print(response);
    }
    catch(error) {
        Fluttertoast.showToast(msg: "Failed to submit document $error", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
    }
  }

  void deleteDoc() async {
    final ApiService apiService = ApiService();
    try {
      final response = await apiService.deleteDocument('${ApiEndpoints.authEndpoints.GDM}/${widget.name}');
      if(response == "202") {
        Fluttertoast.showToast(msg: "Document deleted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const GdmList()));
        }
      }
      else {
        Fluttertoast.showToast(msg: "Failed to delete document", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      }
      print(response);
    }
    catch(error) {
        Fluttertoast.showToast(msg: "Failed to delete document $error", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      print(e);
    }
  }

  void cancelDoc() async{
    final ApiService apiService = ApiService();
    final body = {
      "docstatus" : 2
    };
    try {
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.GDM}/${widget.name}', body);
      if(response == "200") {
        Fluttertoast.showToast(msg: "Document Canceled successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const GdmList()));
        }
      }
      else {
        Fluttertoast.showToast(msg: "Failed to cancel document", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      }
      print(response);
    }
    catch(error) {
        Fluttertoast.showToast(msg: "Failed to cancel document $error", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      print(e);
    }
  }

  Future<void> showPMChecklistDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text("PM Checklist"),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: engineOil,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                engineOil = newBool!;
                              });
                            } :null,
                          ),
                          const Text("Engine Oil"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: bs6Oil,
                            onChanged: PMChecked == false
                                ? (bool? newBool) {
                                    setState(() {
                                      bs6Oil = newBool!;
                                    });
                                  }
                                : null, // Disable when PMChecked is true
                          ),
                          const SizedBox(width: 10),
                          const Text("BS6 Oil"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: tyrePressure,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  tyrePressure = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Tyre Pressure"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: brakes,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  brakes = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Brakes"),
                        ],
                      ),
                    ),
                     const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: mirrors,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  mirrors = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Mirrors"),
                        ],
                      ),
                    ),
                     const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: jacky,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  jacky = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Jacky"),
                        ],
                      ),
                    ),
                     const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: wavc,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  wavc = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Walk Around the Vehicle & Check"),
                        ],
                      ),
                    ),
                     const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: lights,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  lights = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Lights"),
                        ],
                      ),
                    ),
                     const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: wiper,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  wiper = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Wiper"),
                        ],
                      ),
                    ),
                     const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: horn,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  horn = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Horn"),
                        ],
                      ),
                    ),
                     const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: stepney,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  stepney = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Stepney"),
                        ],
                      ),
                    ),
                     const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: wheelspanner,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  wheelspanner = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Wheel Spanner"),
                        ],
                      ),
                    ),
                     const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: jackyLiver,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  jackyLiver = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Jacky Liver"),
                        ],
                      ),
                    ),
                     const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: allTools,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  allTools = newBool!;
                              });
                            } : null,
                          ),
                          const Text("All Tools"),
                        ],
                      ),
                    ),
                     const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: tarpolin,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  tarpolin = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Tarpolin"),
                        ],
                      ),
                    ),
                     const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: rope,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  rope = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Rope"),
                        ],
                      ),
                    ),
                     const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: otherAccessories,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  otherAccessories = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Other Accessories"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: pallet,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  pallet = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Pallet"),
                        ],
                      ),
                    ),
                     const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          Checkbox(
                            value: scanner,
                            onChanged: PMChecked == false ? (bool? newBool) {
                              setState(() {
                                  scanner = newBool!;
                              });
                            } : null,
                          ),
                          const Text("Scanner"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              if(PMChecked == false)
              TextButton(
                child: const Text("Save"),
                onPressed: () async {
                  print(engineOil);
                  print(bs6Oil);
                  ApiService apiService = ApiService();
                  Object body = {
                    "args" : {
                      "doctype": "GDM",
                      "docname": widget.name,
                      "engine_oil": engineOil,
                      "bs6_oil": bs6Oil,
                      "tyre_pressure": tyrePressure,
                      "brakes": brakes,
                      "mirrors": mirrors,
                      "jacky": jacky,
                      "wavc": wavc,
                      "lights": lights,
                      "wiper": wiper,
                      "horn":horn,
                      "stepney": stepney,
                      "wheel_spanner": wheelspanner,
                      "jacky_liver": jackyLiver,
                      "all_tools": allTools,
                      "tarpolin": tarpolin,
                      "rope": rope,
                      "other_accessories": otherAccessories,
                      "pallet": pallet,
                      "scanner": scanner,
                    }
                  };
                  try {
                    final response = await apiService.updateDocument(ApiEndpoints.authEndpoints.setPMChecklist, body);
                    print(response);
                    Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => GDMView(name: widget.name)));
                    Fluttertoast.showToast(msg: "PM Checklist Successfully Updated", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
                  }
                  catch (e) {
                    Fluttertoast.showToast(msg: "$e", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
                    print('Error: $e');
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    },
  );
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

  Future<void> createTripLog() async{

    ApiService apiService = ApiService();

    Object body = {
      "source_name": widget.name,
    };

  try{
    final response = await apiService.getDoc(ApiEndpoints.authEndpoints.gdmTripLog, body);

    Navigator.push(context, 
    MaterialPageRoute(builder: (context) => VehicleLogForm(data: response,)));
  }
  catch (e) {
    Fluttertoast.showToast(msg: "$e", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
    print('Error: $e');
  }
   }

  Future<void> createDelivery(item) async {
    print(item);
    ApiService apiService = ApiService();

    Object body = {
      "source_name": widget.name,
      "args": {
        "lr_no": item['lr_no']
      }
    };

    try{
      final response = await apiService.getDoc(ApiEndpoints.authEndpoints.gdmDelivery, body);

      print(response);

      Navigator.push(context, 
      MaterialPageRoute(builder: (context) => UnloadingDetailsForm(data: response,)));
    }
    catch(e){
      print(e);
    }
  }

  Future<void> createBranchDelivery() async{
    ApiService apiService = ApiService();

    Object body = {
      "source_name": widget.name,
    };

    try{
      final response = await apiService.getDoc(ApiEndpoints.authEndpoints.branchDelivery, body);

      Navigator.push(context, 
      MaterialPageRoute(builder: (context) => UnloadingDetailsForm(data: response,)));
    }
    catch(e){
      print(e);
    }
  }

   Future<void> createReturnLog() async{
    ApiService apiService = ApiService();

    Object body = {
      "source_name": widget.name
    };

   try{
    final response = await apiService.getDoc(ApiEndpoints.authEndpoints.returnLog, body);
    // if(data.isNotEmpty){
    Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleLogForm(data: response,)));
    // }
   }
   catch(e){
    print(e);
   }
  }

   Future<void> createLoadingDetails() async{
    ApiService apiService = ApiService();

    Object body = {
      "source_name": widget.name,
    };

    try{
      final response = await apiService.getDoc(ApiEndpoints.authEndpoints.gdmloadingDetails, body);

      Navigator.push(context, 
      MaterialPageRoute(builder: (context) => LoadingDetailsForm(data: response,)));
    }
    catch(e){
      print(e);
    }
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if(didPop) {return;}
        Navigator.push(context, 
        MaterialPageRoute(builder: (context) => const GdmList()));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GDM'),
          backgroundColor: Colors.grey[200],
          actions: [
              Padding(padding: const EdgeInsets.only(right: 20),
              child: PopupMenuButton(
                itemBuilder: (context) => [
                  if(docstatus.text == "0")
                  const PopupMenuItem(
                    value: 1,
                    child: Text('Submit', style: TextStyle(),),
                  ),
                  if(docstatus.text == "0")
                  const PopupMenuItem(
                    value: 0,
                    child: Text('Delete'),
                  ),
                  if(docstatus.text == "1")
                  const PopupMenuItem(
                    value: 2,
                    child: Text('Cancel'),
                  ),
                  if(docstatus.text == "1")
                  const PopupMenuItem(
                    value: 3,
                    child: Text('PM Check List'),
                  ),
                  if(status.text == 'PM Checked')
                const PopupMenuItem(
                  value: 4,
                  child: Text("Loading Details")),
                if(status.text == 'Loaded')
                const PopupMenuItem(
                  value: 5,
                  child: Text("Trip Log")),
                  if(status.text == 'Delivered')
                const PopupMenuItem(
                  value: 6,
                  child: Text("Vehicle Return")),
                  if((status.text == 'Delivered Started' || status.text == "Partially Delivered") && dt.text != 'Final Delivery')
                const PopupMenuItem(
                  value: 7,
                  child: Text("Branch Delivery")),
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
                    else if(value == 3){
                      showPMChecklistDialog(context);
                    }
                    else if(value == 4){
                      createLoadingDetails();
                    }
                    else if(value == 5){
                      createTripLog();
                    }
                    else if(value == 6){
                      createReturnLog();
                    }
                    else if(value == 7){
                      createBranchDelivery();
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
        backgroundColor: Colors.white,
        body: isLoading
        ? const Center(child: CircularProgressIndicator(),)
        : SafeArea(
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
                      child: AbsorbPointer(child: FieldText(controller: dispatchOn, labelText: "Dispatch On", readOnly: isDisabled, obscureText: false, keyboardType: TextInputType.name,),
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
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          color:  Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color:  Colors.black),
                          borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    labelText: "Required Time",
                    labelStyle: TextStyle(
                        color: Colors.grey[600]),
                  ),
                  onTap: () {
                    _showTimePicker(context);
                  },
                ),
              ),
                    if(docstatus.text != "-1")
                    const SizedBox(height: 10.0),
                    if(docstatus.text != "-1")
                    FieldText(controller: dispatchNumber, labelText: "Dispatch Number", obscureText: false, keyboardType: TextInputType.number, readOnly: true,),
                    const SizedBox(height: 10.0),
                    FieldText(controller: advance, labelText: "Advance Amount", obscureText: false, readOnly: isDisabled, keyboardType: TextInputType.number,),
                    const SizedBox(height: 10.0,),
                  if(docstatus.text == "-1")
                  DropDown(labelText: "Vehicle Type", items: const ["Owned", "Rental"], selectedItem: vehicleType, onChanged: (String? newValue) {setState(() { vehicleType = newValue.toString(); vt.text = newValue.toString(); fetchVehicleFuture = fetchVehicle(newValue);});}),
                  if(docstatus.text != "-1")
                  FieldText(controller: vt, labelText: "Vehicle Type", keyboardType: TextInputType.none, readOnly: true,),
                  const SizedBox(height: 10,),
                  if(docstatus.text == "-1")
                  FutureBuilder<List<String>>(
                      future: fetchVehicleFuture,
                      builder: (context, snapshot) {
                        if(snapshot.hasError) {
                          return AutoComplete(controller: vehicleRegisterNo, readOnly: isDisabled, hintText: 'Assign Vehicle', options: vehicleList,
                            onSelected: (String selection) {
                              print('You selected: $selection');
                            },
                          );
                        }
                        else if (snapshot.hasData) {
                          vehicleList = snapshot.data!;
                          return AutoComplete(controller: vehicleRegisterNo, readOnly: isDisabled, hintText: 'Assign Vehicle', options: vehicleList,
                            onSelected: (String selection) {
                              print(selection);
                              licensetype.text = selection.split(",")[1];
                              fetchDriverFuture = fetchDriver(licensetype.text);
                            },
                          );
                        } else {
                          // return AutoComplete(controller: assignedVehicle, readOnly: isDisabled, hintText: 'Assign Vehicle', options: vehicleList,
                          //   onSelected: (String selection) {
                          //     print('You selected: $selection');
                          //   },
                          // );
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                    if(docstatus.text != "-1")
                    FieldText(controller: vehicleRegisterNo, readOnly: true, labelText: 'Vehicle Registration Number', keyboardType: TextInputType.none),
                    const SizedBox(height: 10.0),
                    if(docstatus.text == "-1")
                    FutureBuilder<List<String>>(
                      future: fetchDriverFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return AutoComplete(controller: assignedDriver, hintText: 'Assign Driver', readOnly: true, options: driverList,
                            onSelected: (String selection) {
                              print('You selected: $selection');
                            },
                          );
                        } else if (snapshot.hasData) {
                          driverList = snapshot.data!;
                          return AutoComplete(controller: assignedDriver, hintText: 'Assign Driver', readOnly: isDisabled,  options: driverList,
                            onSelected: (String selection) {
                              print(selection);
                            },
                          );
                        } else {
                          return AutoComplete(controller: assignedDriver, hintText: 'Assign Driver',readOnly: isDisabled, options: driverList,
                            onSelected: (String selection) {
                              print('You selected: $selection');
                            },
                          );
                        }
                      },
                    ),
                    if(docstatus.text != "-1")
                    FieldText(controller: assignedDriver, labelText: "Driver", keyboardType: TextInputType.none, readOnly: true,),
                    const SizedBox(
                      height: 10,
                    ),
                    if(docstatus.text == "-1")
                    FutureBuilder<List<String>>(
                      future: fetchAttenderList,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return AutoComplete(controller: assignedAttender, hintText: 'Assign Attender', readOnly: isDisabled, options: attenderList,
                            onSelected: (String selection) {
                              print('You selected: $selection');
                            },
                          );
                        } else if (snapshot.hasData) {
                          attenderList = snapshot.data!;
                          return AutoComplete(controller: assignedAttender, readOnly: isDisabled, hintText: 'Assign Attender',  options: attenderList,
                            onSelected: (String selection) {
                              print(selection);
                            },
                          );
                        } else {
                          return AutoComplete(controller: assignedAttender, hintText: 'Assign Attender', readOnly: isDisabled,  options: attenderList,
                            onSelected: (String selection) {
                              print('You selected: $selection');
                            },
                          );
                        }
                      },
                    ),
                    if(docstatus.text != "-1")
                    FieldText(controller: assignedAttender, labelText: "Attender", keyboardType: TextInputType.none, readOnly: true,),
                    const SizedBox(height: 10),
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
                          readOnly: isDisabled,
                          obscureText: false,
                          keyboardType: TextInputType.name,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                if(docstatus.text == "-1" && vt.text == 'Rental')
                FutureBuilder<List<String>>(
                    future: fetchSupplierFuture,
                    builder: (context, snapshot) {
                      if(snapshot.hasError) {
                        return AutoComplete(controller: supplier, readOnly: isDisabled, hintText: 'Supplier', options: supplierList,
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                        );
                      }
                      else if (snapshot.hasData) {
                        supplierList = snapshot.data!;
                        return AutoComplete(controller: supplier, readOnly: isDisabled,hintText: 'Supplier', options: supplierList,
                          onSelected: (String selection) {
                            print(selection);
                          },
                        );
                      } else {
                        return AutoComplete(controller: supplier, readOnly: isDisabled, hintText: 'Supplier', options: supplierList,
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                        );
                      }
                    },
                  ),
                if(docstatus.text != "-1" && vt.text == 'Rental')
                FieldText(controller: supplier, labelText: "Supplier", keyboardType: TextInputType.none, readOnly: true,),
                if(vt.text == 'Rental')
                const SizedBox(height: 10,),
                if(vt.text == 'Rental')
                FieldText(controller: rentalAmount, labelText: "Rental Amount", keyboardType: TextInputType.number, readOnly: isDisabled,),
                const SizedBox(height: 10,),
                if(docstatus.text == "-1")
                FutureBuilder<List<String>>(
                  future: fetchRoutePlacesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return AutoComplete(controller: routePlaces, hintText: 'Route Name', options: routeList,
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                      );
                    } else if (snapshot.hasData) {
                      routeList = snapshot.data!;
                      return AutoComplete(controller: routePlaces, hintText: 'Route Name', options: routeList,
                        onSelected: (String selection) {
                          fetchLRList = fetchLR();
                          print(selection);

                          // fetchRequestFuture = fetchRequest(selection.split(",")[0]);
                        },
                      );
                    } else {
                      return AutoComplete(controller: routePlaces, hintText: 'Route Name', options: routeList,
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                      );
                    }
                  },
                ),
                if(docstatus.text != "-1")
                FieldText(controller: routePlaces, labelText: "Route Name", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10,),
                if(docstatus.text == "-1")
                FutureBuilder<List<String>>(
                    future: fetchBranchFuture,
                    builder: (BuildContext context, snapshot) {
                      if(snapshot.hasError) {
                        return AutoComplete(controller: currentBranch, readOnly: isDisabled, hintText: 'Current Branch', options: branchList,
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                        );
                      }
                      else if (snapshot.hasData) {
                        branchList = snapshot.data!;
                        return AutoComplete(controller: currentBranch, readOnly: isDisabled,hintText: 'Current Branch', options: branchList,
                          onSelected: (String selection) {
                          fetchLRList = fetchLR();
                            print(selection);
                          },
                        );
                      } else {
                        return AutoComplete(controller: currentBranch, readOnly: isDisabled, hintText: 'Current Branch', options: branchList,
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                        );
                      }
                    },
                  ),
                  if(docstatus.text != "-1")
                  FieldText(controller: currentBranch, labelText: "Current Branch", keyboardType: TextInputType.none, readOnly: true,),
                  const SizedBox(height: 10,),
                  if(docstatus.text != "-1")
                  FieldText(controller: dt, labelText: "Delivery Type", keyboardType: TextInputType.none, readOnly: true,),
                if(docstatus.text == "-1")
                  DropDown(labelText: "Delivery Type", items: const ["Final Delivery", "Branch Delivery", "Mixed Delivery"], selectedItem: deliveryType, onChanged: (String? newValue) {setState(() { deliveryType = newValue.toString(); dt.text = newValue.toString(); 
                  if(dt.text == "Final Delivery"){
                    branchLr.text = "No";
                  }
                  else if(dt.text == "Branch Delivery"){
                    branchLr.text = "Yes";
                  }
                });}),
                const SizedBox(height: 10,),
                if(docstatus.text == "-1" && (dt.text.isNotEmpty && dt.text != "Final Delivery"))
                FutureBuilder<List<String>>(
                    future: fetchTargetBranchFuture,
                    builder: (BuildContext context, snapshot) {
                      if(snapshot.hasError) {
                        return AutoComplete(controller: targetBranch, readOnly: isDisabled, hintText: 'Target Branch', options: targetBranchList,
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                        );
                      }
                      else if (snapshot.hasData) {
                        targetBranchList = snapshot.data!;
                        return AutoComplete(controller: targetBranch, readOnly: isDisabled,hintText: 'Target Branch', options: targetBranchList,
                          onSelected: (String selection) {
                            print(selection);
                            currentBranch.text = selection;
                          },
                        );
                      } else {
                        return AutoComplete(controller: targetBranch, readOnly: isDisabled, hintText: 'Target Branch', options: targetBranchList,
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                        );
                      }
                    },
                  ),
                  if(docstatus.text != "-1" && (dt.text.isNotEmpty && dt.text != "Final Delivery"))
                  FieldText(controller: targetBranch, labelText: "Target Branch", keyboardType: TextInputType.none, readOnly: true,),
                  const SizedBox(height: 10,),
                  if(docstatus.text != "-1")
                  FieldText(controller: status, labelText: "Status", keyboardType: TextInputType.none, readOnly: true,),
                    const SizedBox(height: 10.0,),
                    if(docstatus.text == "1" || docstatus.text == "2")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10,),
                      const Text("Trip Details"),
                      const SizedBox(height: 10,),
                      FieldText(controller: noOfDeliveries, labelText: "No. of Pick-Ups", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: vehicleCurrentLocation, labelText: "Vehicle Current Location", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: locationForNextDelivery, labelText: "Location for Next Pick-Up", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: distanceForNextDelivery, labelText: "Distance for Next Pick-Up", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: durationForNextDelivery, labelText: "Duration for next Pick-Up", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: lastDeliveryLocation, labelText: "Last Pick-Up Location", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: lastDeliveryDate, labelText: "Last Pick-Up Date & Time", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: currentLoadInVehicle, labelText: "Current Load in the Vehicle", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: noOfDeliveriesPending, labelText: "No. of Pick-Ups Pending", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: totalKMtoReachBackDepo, labelText: "Total KM to Reach Back Depo", keyboardType: TextInputType.none, readOnly: true,),
                    ],),),
                     const SizedBox(height: 10.0,),
                    if(docstatus.text == "1" || docstatus.text == "2")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10,),
                      const SizedBox(height: 10,),
                      FieldText(controller: totalAmount, labelText: "Total Amount(Account Pay)", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: toPayTotal, labelText: "Total Amount(ToPay)", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: totalWeight, labelText: "Total Weight", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: totalVOG, labelText: "Total VOG", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: totalBoxCount, labelText: "Total Box Count", keyboardType: TextInputType.none, readOnly: true,),
                    ],),),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 3.0),
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
                    padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 3.0),
                    child: Container(
                      height: 200,
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
                                  leading: Text("${index + 1}."),
                                  title: Text(items[index]["lr_no"].toString()),
                                  trailing: (status.text == "Delivery Started" || status.text == "Paterially Delivered") && (items[index]['is_branch_lr'] == "No" || items[index]['is_branch_lr'] == "") && items[index]['is_delivered'] == "0" ? IconButton(icon: const Icon(Icons.task_alt_rounded), onPressed: () => createDelivery(items[index]),): const Text(""),
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
                    const SizedBox(
                      height: 15.0,
                    ),
                    MyButton(onTap: isDisabled ? (){} : saveData, name: "Save")
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavigation(),
      ),
    );
  }
}
