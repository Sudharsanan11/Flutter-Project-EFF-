import "dart:async";
import "package:erpnext_logistics_mobile/doc_list/collection_assignment_list.dart";
import "package:erpnext_logistics_mobile/doc_list/collection_request_list.dart";
import "package:erpnext_logistics_mobile/doc_list/customer_list.dart";
import "package:erpnext_logistics_mobile/doc_list/gdm_list.dart";
import "package:erpnext_logistics_mobile/doc_list/loading_details_list.dart";
import "package:erpnext_logistics_mobile/doc_list/lr_list.dart";
import "package:erpnext_logistics_mobile/doc_list/unloading_details_list.dart";
import "package:erpnext_logistics_mobile/doc_list/vehicle_log_list.dart";
import "package:flutter/material.dart";
import "package:hive/hive.dart";
import "package:shared_preferences/shared_preferences.dart";
// import "package:erpnext_logistics_mobile/modules/doc_list.dart";

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool isEmployee = false;
  bool isCustomer = false;
  bool customerPermission = false;
  bool CR = false;
  bool CA = false;
  bool LR = false;
  bool GDM = false;
  bool LD = false;
  bool UD = false;
  bool VL = false;

  @override
  void initState(){
    super.initState();
    getUserTyoe();
    get_hive_permissions();
  }

  Future<void> get_hive_permissions() async {
      final Box permissions = Hive.box("permissions");
      final perm = Map<String, dynamic>.from(permissions.get("perm"));
    setState(() {
      customerPermission = perm["Customer"]["read"] ?? false;
      CR = perm["Collection Request"]["read"] ?? false;
      CA = perm["Collection Assignment"]["read"] ?? false;
      LR = perm["LR"]["read"] ?? false;
      GDM = perm["GDM"]["read"] ?? false;
      LD = perm["Loading Details"]["read"] ?? false;
      UD = perm["Unloading Details"]["read"] ?? false;
      VL = perm["Vehicle Log"]["read"] ?? false;
    });
  }

  Future<void> getUserTyoe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String employee = prefs.getString("employee")!;
    String customer = prefs.getString("customer")!;
    if (employee.isNotEmpty){
      setState(() {
        isEmployee = true;
      });
    }
    if (customer.isNotEmpty){
      setState(() {
        isCustomer = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    // final List<Item> items = [
    return Drawer(
      // backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text(""),
              accountEmail: Text("EFF Logistics", style: TextStyle(fontSize: 25), textAlign: TextAlign.end,),
              decoration: BoxDecoration(color: Colors.grey,),
            ),
            if(customerPermission)
            ListTile(
              title: const Text("Customer"),
              leading: const Icon(Icons.supervised_user_circle_rounded),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CustomerList()));
              },
            ),
            if(CR)
            ListTile(
              title: const Text("Collection Request"),
              leading: const Icon(Icons.file_copy),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CollectionRequestList()));
              },
            ),
            if(CA)
            ListTile(
              title: const Text("Collection Assignment"),
              leading: const Icon(Icons.list),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CollectionAssignmentList()));
              },
            ),
            if(LR)
            ListTile(
              title: const Text("LR"),
              leading: const Icon(Icons.filter_b_and_w),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LRList(),));
              },
            ),
            if(GDM)
            ListTile(
              title: const Text("GDM"),
              leading: const Icon(Icons.local_shipping),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const GDMList()));
              },
            ),
            if(VL)
            ListTile(
              title: const Text("Vehicle Log"),
              leading: const Icon(Icons.departure_board_rounded),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const VehicleLogList()));
              },
            ),
            if(UD)
            ListTile(
              title: const Text("Unloading Details"),
              leading: const Icon(Icons.receipt_long_rounded),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const UnloadingDetailsList()));
              },
            ),
            if(LD)
            ListTile(
              title: const Text("Loading Details"),
              leading: const Icon(Icons.receipt_long_rounded),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoadingDetailsList()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Item {
  final String name;
  final IconData icon;

  Item({required this.name, required this.icon});
}