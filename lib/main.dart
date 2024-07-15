import 'dart:async';
import 'package:erpnext_logistics_mobile/forms/lr_form.dart';
import 'package:flutter/material.dart';
// import 'package:eff_logistics/modules/assigned_order.dart';
import "package:erpnext_logistics_mobile/modules/app_drawer.dart";
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'api_endpoints.dart';

Future<void> main() async{
  // await dotenv.load(fileName: '.env');
runApp(  const MaterialApp(
  home: LrForm(),
));
} 
  

class EFF extends StatefulWidget {
  const EFF({super.key});
  @override
  State<EFF> createState() => _EFFState();
}

class _EFFState extends State<EFF> {
  String value = "";
  
  Future<void> _apicall() async{
    final ApiService apiService = ApiService();
    print("apicall");
    print(apiService);
    try {
      final response = await apiService.getresources(ApiEndpoints.authEndpoints.employee);
      print(response);
      setState(() {
        value = response.toString();
      });
    }
  catch(e) {
    print("execption");
    print(e);
    setState(() {
      value = e.toString();
    });
  }
}
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        elevation: 5.0,
        // foregroundColor: Colors.grey,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(children: [
        ElevatedButton(onPressed: _apicall, child: const Text("eff")),
        Text(value)
        ],)
        
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () => apicall,),
      bottomNavigationBar: const BottomNavigation(),
    );
  }

}