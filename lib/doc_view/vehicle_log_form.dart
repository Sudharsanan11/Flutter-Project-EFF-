import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_list/vehicle_log_list.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:erpnext_logistics_mobile/providers/collection_assignment_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VehicleLogForm extends StatefulWidget {
  final String name;
  final Map data;
  const VehicleLogForm({super.key, this.name="", required this.data});

  @override
  State<VehicleLogForm> createState() => _VehicleLogFormState();
}

class _VehicleLogFormState extends State<VehicleLogForm> {

  final TextEditingController docstatus = TextEditingController();
  final TextEditingController vehicle = TextEditingController();
  final TextEditingController driver = TextEditingController();
  final TextEditingController routeName = TextEditingController();
  final TextEditingController logType = TextEditingController();
  final TextEditingController date = TextEditingController();
  final TextEditingController collectionAssignment = TextEditingController();
  final TextEditingController gdm = TextEditingController();
  final TextEditingController status = TextEditingController();
  final TextEditingController lastOdometerValue = TextEditingController();
  final TextEditingController currentOdometerValue = TextEditingController();
  final TextEditingController entryDate = TextEditingController();
  final TextEditingController vehicleLoadingCap = TextEditingController();
  final TextEditingController kilometerRun = TextEditingController();
  // final TextEditingController 

  bool isLoading = false;
  bool isDisabled = false;

  @override
  void initState() {
    super.initState();
    docstatus.text = "-1";
    if(widget.name == "" && widget.data != {}){
      setData();
    }
    else{
      fetchVehicleLog();
    }
  }

  void setData() {
    vehicle.text = widget.data['license_plate'] ?? "";
      driver.text = widget.data['employee'] ?? "";
      routeName.text = widget.data['custom_route_name'] ?? "";
      logType.text = widget.data['custom_log_type'];
      collectionAssignment.text = widget.data['custom_collection_assignment'] ?? "";
      gdm.text = widget.data['custom_gdm'] ?? "";
      status.text = widget.data['custom_vehicle_status'] ?? "";
      lastOdometerValue.text = widget.data['last_odometer'].toString();
  }

  Future<void> fetchVehicleLog() async{
    final ApiService apiService = ApiService();
    setState(() {
    isLoading = true;
    });
    final response = await apiService.getDocument('${ApiEndpoints.authEndpoints.vehicleLog}/${widget.name}');

    vehicle.text = response['license_plate'] ?? "";
    driver.text = response['employee'] ?? "";
    routeName.text = response['custom_route_name'] ?? "";
    logType.text = response['custom_log_type'];
    collectionAssignment.text = response['custom_collection_assignment'] ?? "";
    gdm.text = response['custom_gdm'] ?? "";
    status.text = response['custom_vehicle_status'] ?? "";
    lastOdometerValue.text = response['last_odometer'].toString();
    currentOdometerValue.text = response['odometer'].toString();
    date.text = response['date'].toString();
    entryDate.text = response['custom_entry_date_and_time'].toString();
    kilometerRun.text = response['custom_kilometre_run'].toString();
    vehicleLoadingCap.text = response['custom_vehicle_loading_capacity'].toString();
    docstatus.text = response['docstatus'].toString();
    setState(() {
      if(docstatus.text != "0"){
        isDisabled = true;
      }
    isLoading = false;      
    });
  }
  @override
  void dispose() {
    docstatus.dispose();
    super.dispose();
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
      date.text = "${picked.toLocal()}".split(" ")[0];
    });
  }
}

Future<void> saveData() async {
  final ApiService apiService = ApiService();
  Object body = {
    "license_plate": vehicle.text,
    "employee": driver.text,
    "custom_log_type": logType.text,
    "custom_collection_assignment": collectionAssignment.text,
    "custom_gdm": gdm.text,
    "custom_route_name": routeName.text,
    "custom_vehicle_status": status.text,
    "date": date.text,
    "last_odometer": lastOdometerValue.text,
    "odometer": currentOdometerValue.text,
    "fuel_qty": 0
  };

  try{
    if(docstatus.text == "-1"){
    final response = await apiService.createDocument(ApiEndpoints.authEndpoints.vehicleLog, body);
    if(response[0] == 200){
      Fluttertoast.showToast(msg: "Document created successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => VehicleLogForm(name: response[1], data: const {},)));
        
    }
  }
  if(docstatus.text == "0"){
    final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.vehicleLog}/${widget.name}', body);

    if(response == "200"){
      Fluttertoast.showToast(msg: "Document updated successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      if(mounted){
         Navigator.push(context,
        MaterialPageRoute(builder: (context) => VehicleLogForm(name: widget.name, data: const {},)));
      }
    }
  }
    }
  catch(error) {
    print(error);
    Fluttertoast.showToast(msg: "Failed to create document $error", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
  }
}

void submitDoc() async{
    final ApiService apiService = ApiService();
    final body = {
      "docstatus" : 1
    };
    try {
      final response = await apiService.updateDocument('${ApiEndpoints.authEndpoints.vehicleLog}/${widget.name}', body);
      print(response);
      if(response == "200") {
        Fluttertoast.showToast(msg: "Document Submitted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => VehicleLogForm(name: widget.name, data: const {},)));
        }
      }
      print(response);
    }
    catch(e) {
        Fluttertoast.showToast(msg: "Failed to submit document $e", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      print(e);
    }
  }

  void deleteDoc() async {
    final ApiService apiService = ApiService();
    try {
      final response = await apiService.deleteDocument('${ApiEndpoints.authEndpoints.vehicleLog}/${widget.name}');
      if(response == "202") {
        Fluttertoast.showToast(msg: "Document deleted successfully", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if(mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const VehicleLogList()));
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
          MaterialPageRoute(builder: (context) => VehicleLogForm(name: widget.name, data: const {},)));
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


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {return;}
        Navigator.push(context, 
        MaterialPageRoute(builder: (context) => const VehicleLogList()));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Vehicle Log"),
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
        ? const Center(child:  CircularProgressIndicator())
        : SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10,),
                FieldText(controller: vehicle, labelText: "vehicle", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10,),
                FieldText(controller: driver, labelText: "Driver(Employee)", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10,),
                FieldText(controller: routeName, labelText: "Route Name", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10,),
                FieldText(controller: logType, labelText: "Log Type", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10,),
                if(collectionAssignment.text != "")
                FieldText(controller: collectionAssignment, labelText: "Collection Assignment", keyboardType: TextInputType.none, readOnly: true,),
                if(gdm.text != "")
                FieldText(controller: gdm, labelText: "GDM", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10,),
                FieldText(controller: status, labelText: "Vehicle Status", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 3.0
                  ),
                  child: TextField(controller: date, keyboardType: TextInputType.datetime, readOnly: true,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(12.0),),
                    focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(12.0),),
                    fillColor: Colors.white,
                    filled: true,
                    labelText: "Date",
                    labelStyle: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: isDisabled ? (){} :() {
                    _showDatePicket(context);
                  },
                ),
                ),
                const SizedBox(height: 10,),
                FieldText(controller: lastOdometerValue, labelText: "Last Odometer Value", keyboardType: TextInputType.none, readOnly: true,),
                const SizedBox(height: 10,),
                FieldText(controller: currentOdometerValue, labelText: "Current Odometer Value", keyboardType: TextInputType.number, readOnly: isDisabled,),
                const SizedBox(height: 10,),
                if(docstatus.text != "-1" && status.text == "Vehicle Return")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    children: [
                    const SizedBox(height: 10,),
                    FieldText(controller: entryDate, labelText: "Entry Date and Time", keyboardType: TextInputType.none, readOnly: true,),
                    const SizedBox(height: 10,),
                    FieldText(controller: kilometerRun, labelText: "KM Run", keyboardType: TextInputType.none, readOnly: true,),
                    const SizedBox(height: 10,),
                    FieldText(controller: vehicleLoadingCap, labelText: "vehicle Loading Capacity", keyboardType: TextInputType.none, readOnly: true,)
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
                  MyButton(onTap: docstatus.text == "-1" || docstatus.text == "0" ? saveData : (){Fluttertoast.showToast(msg: "Can't able to save", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);}, name: "Save")
              ],
            ),
          ))
      ),
    );
  }
}