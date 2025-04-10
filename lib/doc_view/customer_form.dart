
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_list/customer_list.dart';
import 'package:erpnext_logistics_mobile/fields/button.dart';
import 'package:erpnext_logistics_mobile/fields/text.dart';
import 'package:erpnext_logistics_mobile/fields/text_area.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CustomerForm extends StatefulWidget {
  final String name;
  const CustomerForm({super.key, required this.name});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  TextEditingController customerName = TextEditingController();
  TextEditingController branch = TextEditingController();
  TextEditingController partyType = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController modeOfPayment = TextEditingController();
  TextEditingController verifiedLocation = TextEditingController();
  TextEditingController latitude = TextEditingController();
  TextEditingController longitude = TextEditingController();
  TextEditingController boundingRadius = TextEditingController();
  bool isLoading = false;

  @override
  void initState(){
    super.initState();
    fetchCustomer();
  }

  Future<void> fetchCustomer() async{

    try{
    setState(() {
      isLoading = true;
    });
    ApiService apiService = ApiService();
    final response = await apiService.getDocument('${ApiEndpoints.authEndpoints.customer}/${widget.name}');


      customerName.text = response['customer_name'] ?? "";
      branch.text = response['custom_branch'] ?? "";
      partyType.text = response['custom_party_type'] ?? "";
      location.text = response['custom_location'] ?? "";
      modeOfPayment.text = response['custom_payment_mode_'] ?? "";
      verifiedLocation.text = response['custom_verified_location'] ?? "";
      latitude.text = response['custom_latitude'] ?? "";
      longitude.text = response['custom_longitude'] ?? "";
      boundingRadius.text = response['custom_bounding_box'] ?? "";

      setState(() {
        isLoading = false;
      });
    }
    catch(e) {
      Fluttertoast.showToast(msg: "$e", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Position> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();
    return Geolocator.getCurrentPosition();
  }

  Future<void> _openMap(String  lat, String long) async {
    String googleURL = 'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    await canLaunchUrlString(googleURL)
    ? launchUrlString(googleURL)
    : throw "Could not launch $googleURL";
  }

  Future<void> updateCustomerLocation() async {
    setState(() {
      isLoading = true;
    });

    try{
      var value = await _getCurrentLocation();
       String lat = '${value.latitude}';
      String long = '${value.longitude}';
        ApiService apiService = ApiService();

        Object body = {
          "args": {
            "lat": lat,
            "long": long,
            "docname": widget.name,
          }
        };
      final response = await apiService.updateLocation(ApiEndpoints.authEndpoints.updateCustomerLocation, body);
        Fluttertoast.showToast(msg: "${response['message']}", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
      if(response['message'] == "Location Updated Successfully"){
      Fluttertoast.showToast(msg: "${response['message']}", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
        if (mounted){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => CustomerForm(name: widget.name),));
        }
        }
        setState(() {
          isLoading = false;
        });
      }catch(e) {
        print("Error: $e");
        setState(() {
      Fluttertoast.showToast(msg: "$e", gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 2);
          isLoading = false;
        });
      }
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if(didPop) {return;}
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => const CustomerList()));
      },
      child: Scaffold(
        appBar: AppBar(
            title: const Text("Customer Form"),
        ),
        body: isLoading ?
         const Center(child: CircularProgressIndicator(),)
         : SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10,),
                FieldText(controller: customerName, labelText: "Customer Name", readOnly: true, keyboardType: TextInputType.none),
                const SizedBox(height: 10,),
                FieldText(controller: partyType, labelText: "Party Type", readOnly: true, keyboardType: TextInputType.none),
                const SizedBox(height: 10,),
                FieldText(controller: branch, labelText: "Branch", readOnly: true, keyboardType: TextInputType.none),
                const SizedBox(height: 10,),
                FieldText(controller: location, labelText: "Location", readOnly: true, keyboardType: TextInputType.none),
                const SizedBox(height: 10,),
                FieldText(controller: modeOfPayment, labelText: "Mode of Payment", readOnly: true, keyboardType: TextInputType.none),
                const SizedBox(height: 10,),
                FieldText(controller: verifiedLocation, labelText: "Verified Location", readOnly: true, keyboardType: TextInputType.none),
                const SizedBox(height: 10,),
                FieldText(controller: latitude, labelText: "Latitude", readOnly: true, keyboardType: TextInputType.none),
                const SizedBox(height: 10,),
                FieldText(controller: longitude, labelText: "Longitude", readOnly: true, keyboardType: TextInputType.none),
                const SizedBox(height: 10,),
                TextArea(controller: boundingRadius, labelText: "Bounding Radius", readOnly: true, keyboardType: TextInputType.none),
                const SizedBox(height: 10,),
                MyButton(name: "Update GeoLocation", onTap: () => updateCustomerLocation(),),
                if(latitude.text != "" && longitude.text != "")
                const SizedBox(height: 10,),
                if(latitude.text != "" && longitude.text != "")
                MyButton(name: "Open Google Map", onTap: () => _openMap(latitude.text, longitude.text),)
              ],
            ),
          )
        ),
      ),
    );
  }
}