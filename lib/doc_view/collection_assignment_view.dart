// import 'dart:ffi';
// import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:dotted_border/dotted_border.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_list/collection_assignment_list.dart';
import 'package:erpnext_logistics_mobile/doc_view/lr_view.dart';
import 'package:erpnext_logistics_mobile/doc_view/unloading_details_form.dart';
import 'package:erpnext_logistics_mobile/doc_view/vehicle_log_form.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/drop_down.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:erpnext_logistics_mobile/forms/vehicle_log.dart';
import 'package:erpnext_logistics_mobile/modules/auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/dialog_auto_complete.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionAssignmentView extends StatefulWidget {
  final String name;
  const CollectionAssignmentView({super.key, this.name=""});

  @override
  State<CollectionAssignmentView> createState() => _CollectionAssignmentViewState();
}


class _CollectionAssignmentViewState extends State<CollectionAssignmentView> {

  final List<String> data = [];

  final TextEditingController enteredBy = TextEditingController();
  final TextEditingController ov = TextEditingController();
  final TextEditingController aproxValueOfGoods = TextEditingController();
  final TextEditingController assignedDriver = TextEditingController();
  final TextEditingController assignedAttender = TextEditingController();
  final TextEditingController assignedVehicle = TextEditingController();
  final TextEditingController routePlaces = TextEditingController();
  final TextEditingController licensetype = TextEditingController();
  final TextEditingController vt = TextEditingController();
  final TextEditingController supplier = TextEditingController();
  final TextEditingController rentalAmount = TextEditingController();
  final TextEditingController docstatus = TextEditingController();
  final TextEditingController branch= TextEditingController();
  final TextEditingController advance = TextEditingController();
  
  final TextEditingController collectionRequest = TextEditingController();
  final TextEditingController status = TextEditingController();

  //Trip Details
  final TextEditingController noOfPickUps = TextEditingController();
  final TextEditingController vehicleCurrentLocation= TextEditingController();
  final TextEditingController locationForNextPickUp = TextEditingController();
  final TextEditingController distanceForNextPickUp= TextEditingController();
  final TextEditingController durationForNextPickUp = TextEditingController();
  final TextEditingController lastPickUpLocation = TextEditingController();
  final TextEditingController lastPickUpDate = TextEditingController();
  final TextEditingController currentLoadInVehicle = TextEditingController();
  final TextEditingController noOfPickUpsPending = TextEditingController();
  final TextEditingController totalKMtoReachBackDepo = TextEditingController();

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


  // String? orderVia;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> itemsDict = [];
  // String? status;
  String? vehicleType;
  String? orderVia;
  List<String> stafflist = [];
  List<String> driverList = [];
  List<String> attenderList = [];
  List<String> supplierList = [];
  List<String> branchList = [];
  List<String> vehicleList = [];
  List<String> routeList = [];
  List<String> requestList = [];
  bool isDisabled = true;
  bool isLoading = false;
  late Future<List<String>> fetchVehicleFuture;
late Future<List<String>> fetchAttenderFuture;
late  Future<List<String>> fetchRequestFuture;
late Future<List<String>> fetchDriverFuture;
late Future<List<String>> fetchRoutePlacesFuture;
late Future<List<String>> fetchSupplierFuture;
late Future<List<String>> fetchBranchFuture;

  @override
  void initState () {
    super.initState();
    // fetchStaff();
      setEnterBy();
      // fetchInitialData();
      if(widget.name != ""){
      fetchCollectionAssignment();
      }
      else{
        setState(() {
          docstatus.text = "-1";
          isDisabled = false;
        });
      }
     fetchDriverFuture = fetchDriver("");
    fetchAttenderFuture = fetchAttender();
    fetchVehicleFuture = fetchVehicle("Owned");
    fetchRequestFuture = fetchRequest(routePlaces.text);
    fetchRoutePlacesFuture = fetchRoutePlaces();
    fetchSupplierFuture = fetchSupplier();
    fetchBranchFuture = fetchBranch();
  }

  @override
  void dispose() {
    enteredBy.dispose();
    ov.dispose();
    aproxValueOfGoods.dispose();
    assignedDriver.dispose();
    assignedVehicle.dispose();
    assignedAttender.dispose();
    collectionRequest.dispose();
    status.dispose();
    items = [];
    itemsDict = [];
    stafflist = [];
    driverList = [];
    attenderList = [];
    supplierList = [];
    branchList = [];
    vehicleList = [];
    requestList = [];
    super.dispose();
  }

  Future<void> fetchInitialData() async {
    try {
      await fetchAttenderFuture;
      await fetchVehicleFuture;
      await fetchRoutePlacesFuture;
      await fetchBranchFuture;
      await fetchSupplierFuture;

      setState(() {
        isLoading = false;
      });
    }
    catch (error) {
      setState(() {
        isLoading = false;
      });
      print(error);
    }
  }

  Future<String> saveData() async{
    final ApiService apiService = ApiService();
    final body = {
      "entered_by": enteredBy.text,
      "ordered_via": orderVia,
      "vehicle_type": vehicleType,
      "rental_amount": rentalAmount.text,
      "aprox_value_of_the_goods": aproxValueOfGoods.text,
      "assigned_driver": assignedDriver.text.split(",")[0],
      "assigned_attender": assignedAttender.text.split(",")[0],
      "assigned_vehicle": assignedVehicle.text.split(",")[0],
      "route_name": routePlaces.text,
      "supplier": supplier.text,
      "advance": advance.text,
      "branch": branch.text,
      "collection_req": itemsDict,
      "docstatus": 0,
    };
    try {
      if(docstatus.text == "-1"){
        final response = await apiService.createDocument(ApiEndpoints.authEndpoints.CollectionAssignment, body);
        if(response[0] == 200) {
        Fluttertoast.showToast(msg: "Document Saved Successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => CollectionAssignmentView(name: response[1])));
        }
        }
      }
      if(docstatus.text == "0"){
        final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.CollectionAssignment}/${widget.name}', body);
        if(response == "200") {
        Fluttertoast.showToast(msg: "Document Updated Successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => CollectionAssignmentView(name: widget.name)));
        }
        }
      }
      return "";
    }
    catch (error) {
      print(error);
        Fluttertoast.showToast(msg: "$error", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      return "Error: Failed to submit data";
    }
  }

  Future<void> fetchCollectionAssignment() async{
    setState(() {
      isLoading = true;
    });
    final ApiService apiService = ApiService();
    try {
      final response = await apiService.getDocument('${ApiEndpoints.authEndpoints.CollectionAssignment}/${widget.name}');
      print(response['collection_req']);
        docstatus.text = response['docstatus'].toString();
        enteredBy.text = response['entered_by'];
        ov.text = response['ordered_via'].toString();
        aproxValueOfGoods.text = response['aprox_value_of_the_goods'] != 0 ? response['aprox_value_of_the_goods'].toString() : "0";
        assignedDriver.text = response['assigned_driver'] ?? "";
        assignedAttender.text = response['assigned_attender'] ?? "";
        assignedVehicle.text = response['assigned_vehicle'] ?? "";
        routePlaces.text = response['route_name'] ?? "";
        advance.text = response['advance'].toString();
        status.text = response['status'] ?? "";
        vt.text = response['vehicle_type'] ?? "";
        supplier.text = response['supplier'] ?? "";
        rentalAmount.text = response['rental_amount'].toString();
        branch.text = response['branch'] ?? "";
        if(docstatus.text == "1" || docstatus.text == "2"){
          noOfPickUps.text = response['no_of_pick_ups'].toString();
          vehicleCurrentLocation.text = response['vehicle_current_location'] ?? "";
          locationForNextPickUp.text = response['location_for_next_pick_up'] ?? "";
          distanceForNextPickUp.text = response['distance_for_next_pick_up'].toString();
          durationForNextPickUp.text = response['duration_for_next_pick_up'].toString();
          lastPickUpLocation.text = response['last_pick_up_location'] ?? "";
          lastPickUpDate.text = response['last_pick_up_date'] ?? "";
          currentLoadInVehicle.text = response['current_load_in_the_vehicle'] != "" ? response['current_load_in_the_vehicle'].toString() : "0";
          noOfPickUpsPending.text = response['no_of_pick_ups_pending'].toString();
          totalKMtoReachBackDepo.text = response['km_to_reach_back_depo'].toString();
        }
      setState(() {
        items = (response['collection_req'] as List).map((item) {
          return (item as Map<String, dynamic>).map((key, value) => MapEntry(key, value.toString()));
            }).toList();
        if(docstatus.text == "0"){
          setState(() {
          isDisabled = false;
          });
        }
        // print(response['check_list'][0]);
        if(response['status'] == "Pending" || response['status'] == "PM Checked"){
          setState(() {
            PMChecked = false;
          });
        }
        else{
          setState(() {
            PMChecked = true;
          });
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
        print(response);
      });
      // return response;
    }
    catch(e) {
      setState(() {
      isLoading = false;
      });
      throw "$e";
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
    print(":vehicle====================");
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

void setEnterBy() async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    setState(() {
      enteredBy.text = manager.getString('email') ?? "";
    });
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
      final response = await apiService.fetchFieldData(ApiEndpoints.authEndpoints.getRequest, body);
      print(response);
      setState(() {
        requestList = response.map((item) {
          return "${item['name']}, ${item['location']}";
        }).toList();
      });
      return requestList;
    } catch (e) {
      Fluttertoast();
      throw "Fetch Error";
    }
  }

  Future<void> createUnloadingDetails() async{

    ApiService apiService = ApiService();

    Object body = {
      "source_name": widget.name
    };

   try{
    final response = await apiService.getDoc(ApiEndpoints.authEndpoints.getUnloadingDetails, body);

    Navigator.push(context, MaterialPageRoute(builder: (context) => UnloadingDetailsForm(data: response,)));
   }
   catch(e){
    print(e);
   }
  }

  Future<void> createTripLog() async{
    ApiService apiService = ApiService();

    Object body = {
      "source_name": widget.name
    };

   try{
    final response = await apiService.getDoc(ApiEndpoints.authEndpoints.tripLog, body);
    // if(data.isNotEmpty){
    Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleLogForm(data: response,)));
    // }
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
                  builder: (BuildContext context, snapshot) {
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
                      return DialogAutoComplete(controller: collectionRequest, readOnly: isDisabled, hintText: 'Collection Request', options: requestList,
                        onSelected: (String selection) {
                          print('You selected: $selection');
                        },
                      );
                    }
                  },
                ),
          actions: <Widget>[
            if(docstatus.text == "-1")
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
                  itemsDict.remove(item);
                  });
                  Navigator.of(context).pop();
                }
              }
            ),
            if(docstatus.text == "-1")
            TextButton(
              child: Text(item == null ? 'Add' : 'Save'),
              onPressed: () {
                if(item == null) {
                  setState(() {
                  items.add(
                    {"collection_request" : collectionRequest.text}
                  );
                  itemsDict.add(
                    {"collection_request": collectionRequest.text.split(",")[0]}
                  );
                  });
                  collectionRequest.clear();
                  Navigator.of(context).pop();
                }
                else {
                  setState(() {
                    items[index!]["collection_request"] = collectionRequest.text;
                    itemsDict[index]["collection_request"] = collectionRequest.text.split(",")[0];
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

  void createLR(item){
    item['lr_type'] = "By Collection Request";
   Navigator.push(context,
   MaterialPageRoute(builder: (context) => LRView(data: item,)));
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
                  ApiService apiService = ApiService();
                  Object body = {
                    "args" : {
                      "doctype": "Collection Assignment",
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
                    MaterialPageRoute(builder: (context) => CollectionAssignmentView(name: widget.name)));
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


  @override
  Widget build(BuildContext context) {
    // final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if(didPop) {return;}
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => const CollectionAssignmentList()));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Collection Assignment Form"),
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
                  child: Text('PM Checklist'),
                ),
                if(status.text == 'Pending Unload')
                const PopupMenuItem(
                  value: 4,
                  child: Text("Unloading Details")),
                const PopupMenuItem(
                  value: 5,
                  child: Text("Fetch Request")),
                if(status.text == 'PM Checked')
                const PopupMenuItem(
                  value: 6,
                  child: Text("Vehicle Log")),
                  if(status.text == "Collected")
                const PopupMenuItem(
                  value: 7,
                  child: Text("Return Log")),
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
                  else if(value == 3) {
                    showPMChecklistDialog(context);
                  }
                  else if(value == 4) {
                    createUnloadingDetails();
                  }
                  else if(value == 5){
                    // collectionRequestDialog();
                  }
                  else if(value == 6){
                    createTripLog();
                  }
                  else if(value == 7){
                    createReturnLog();
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
            child: Column(
              children: [
                const SizedBox(height: 10,),
                FieldText(controller: enteredBy, labelText: "Entered By", readOnly: true, keyboardType: TextInputType.name),
                const SizedBox(height: 10,),
                if(docstatus.text != "-1")
                FieldText(controller: ov, labelText: "Oredered Via", keyboardType: TextInputType.none, readOnly: true,),
                if(docstatus.text == "-1")
                DropDown(labelText: "OrderVia", items: const ["Phone", "Mail", "WhatsApp", "Mobile App"], selectedItem: orderVia, onChanged: (String? newValue) {setState(() { orderVia = newValue.toString();});}),
                const SizedBox(height: 10,),
                FieldText(controller: aproxValueOfGoods, readOnly: isDisabled, labelText: "Aprox. Value of Goods", keyboardType: TextInputType.number),
                const SizedBox(height: 10,),
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
                        return AutoComplete(controller: assignedVehicle, readOnly: isDisabled, hintText: 'Assign Vehicle', options: vehicleList,
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                        );
                      }
                      else if (snapshot.hasData) {
                        vehicleList = snapshot.data!;
                        return AutoComplete(controller: assignedVehicle, readOnly: isDisabled, hintText: 'Assign Vehicle', options: vehicleList,
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
                  FieldText(controller: assignedVehicle, labelText: "Assigned Vehicle", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10,),
                if(docstatus.text == "-1")
                FutureBuilder<List<String>>(
                    future: fetchDriverFuture,
                    builder: (context, snapshot) {
                      if(snapshot.hasError) {
                        return AutoComplete(controller: assignedDriver, readOnly: true, hintText: 'Assign Driver', options: driverList,
                        onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                        );
                      }
                      else if (snapshot.hasData) {
                        driverList = snapshot.data!;
                        return AutoComplete(controller: assignedDriver, readOnly: isDisabled, hintText: 'Assign Driver', options: driverList,
                          onSelected: (String selection) {
                            print(selection);
                          },
                        );
                      } else {
                        return AutoComplete(controller: assignedDriver, readOnly: isDisabled, hintText: 'Assign Driver', options: driverList,
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                        );
                      }
                    },
                  ),
                if(docstatus.text != "-1")
                FieldText(controller: assignedDriver, labelText: "Driver", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10,),
                if(docstatus.text == "-1")
                FutureBuilder<List<String>>(
                    future: fetchAttenderFuture,
                    builder: (context, snapshot) {
                      if(snapshot.hasError) {
                        return AutoComplete(controller: assignedAttender, hintText: 'Assign Attender', options: attenderList,
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                        );
                      }
                      else if (snapshot.hasData) {
                        attenderList = snapshot.data!;
                        return AutoComplete(controller: assignedAttender, readOnly: isDisabled, hintText: 'Assign Attender', options: attenderList,
                          onSelected: (String selection) {
                            print(selection);
                          },
                        );
                      } else {
                        return AutoComplete(controller: assignedAttender, hintText: 'Assign Attender',readOnly: isDisabled, options: attenderList,
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                        );
                      }
                    },
                  ),
                if(docstatus.text != "-1")
                FieldText(controller: assignedAttender, labelText: "Assigned Attender", keyboardType: TextInputType.none, readOnly: true,),
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
                          print(selection);

                          fetchRequestFuture = fetchRequest(selection.split(",")[0]);
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
                if(docstatus.text != "-1")
                const SizedBox(height: 10,),
                if(docstatus.text != "-1")
                FieldText(controller: status, readOnly: true, labelText: "Status",keyboardType: TextInputType.none,),
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
                const SizedBox(height: 10,),
                if(vt.text == 'Rental')
                FieldText(controller: rentalAmount, labelText: "Rental Amount", keyboardType: TextInputType.number, readOnly: isDisabled,),
                const SizedBox(height: 10,),
                if(docstatus.text == "-1")
                FutureBuilder<List<String>>(
                    future: fetchBranchFuture,
                    builder: (BuildContext context, snapshot) {
                      if(snapshot.hasError) {
                        return AutoComplete(controller: branch, readOnly: isDisabled, hintText: 'Branch', options: branchList,
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                        );
                      }
                      else if (snapshot.hasData) {
                        branchList = snapshot.data!;
                        return AutoComplete(controller: branch, readOnly: isDisabled,hintText: 'Branch', options: branchList,
                          onSelected: (String selection) {
                            print(selection);
                            branch.text = selection;
                          },
                        );
                      } else {
                        return AutoComplete(controller: branch, readOnly: isDisabled, hintText: 'Branch', options: branchList,
                          onSelected: (String selection) {
                            print('You selected: $selection');
                          },
                        );
                      }
                    },
                  ),
                  if(docstatus.text != "-1")
                  FieldText(controller: branch, labelText: "Branch", keyboardType: TextInputType.none, readOnly: true,),
                if(docstatus.text == "1" || docstatus.text == "2")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10,),
                      const Text("Trip Details"),
                      const SizedBox(height: 10,),
                      FieldText(controller: noOfPickUps, labelText: "No. of Pick-Ups", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: vehicleCurrentLocation, labelText: "Vehicle Current Location", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: locationForNextPickUp, labelText: "Location for Next Pick-Up", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: distanceForNextPickUp, labelText: "Distance for Next Pick-Up", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: durationForNextPickUp, labelText: "Duration for next Pick-Up", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: lastPickUpLocation, labelText: "Last Pick-Up Location", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: lastPickUpDate, labelText: "Last Pick-Up Date & Time", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: currentLoadInVehicle, labelText: "Current Load in the Vehicle", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: noOfPickUpsPending, labelText: "No. of Pick-Ups Pending", keyboardType: TextInputType.none, readOnly: true,),
                      const SizedBox(height: 10,),
                      FieldText(controller: totalKMtoReachBackDepo, labelText: "Total KM to Reach Back Depo", keyboardType: TextInputType.none, readOnly: true,),
                    ],),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 3.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Padding(padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0)),
                      const Text("Items"),
                      ElevatedButton(
                        onPressed: isDisabled == false ? () {
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
                  if (items.isNotEmpty && docstatus.text != "1")
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
                                  leading: Text("${index + 1}"),
                                  title: Text("${items[index]['collection_request']}"),
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
                  if(docstatus.text == "1" && items.isNotEmpty)
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
                                  leading: Text("${index + 1}"),
                                  title: Text("${items[index]['collection_request']}"),
                                  subtitle: Text("${items[index]['consignor'] ?? ""}"),
                                  trailing: IconButton(
                                              icon: const Icon(Icons.post_add_rounded),
                                              onPressed: () {
                                                // Add your desired action here
                                                createLR(items[index]);
                                              },
                                            ),
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
                    MyButton(onTap: docstatus.text == "-1" || docstatus.text == "0" ? saveData : (){Fluttertoast.showToast(msg: "Can't able to save", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);}, name: "Save")
              ],
              ),
          ),
        ),
        bottomNavigationBar: const BottomNavigation(),
      ),
    );
  }
}