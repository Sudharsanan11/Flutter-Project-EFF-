import "package:erpnext_logistics_mobile/doc_list/collection_assignment_list.dart";
import "package:erpnext_logistics_mobile/doc_list/collection_request_list.dart";
import "package:erpnext_logistics_mobile/doc_list/gdm_list.dart";
import "package:erpnext_logistics_mobile/doc_list/loading_details_list.dart";
import "package:erpnext_logistics_mobile/doc_list/lr_list.dart";
import "package:erpnext_logistics_mobile/doc_list/unloading_details_list.dart";
import "package:erpnext_logistics_mobile/doc_list/vehicle_log_list.dart";
import "package:flutter/material.dart";
// import "package:erpnext_logistics_mobile/modules/doc_list.dart";

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
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
            ListTile(
              title: const Text("Collection Request"),
              leading: const Icon(Icons.file_copy),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CollectionRequestList()));
              },
            ),
            ListTile(
              title: const Text("Collection Assignment"),
              leading: const Icon(Icons.list),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CollectionAssignmentList()));
              },
            ),
            ListTile(
              title: const Text("LR"),
              leading: const Icon(Icons.filter_b_and_w),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LRList(),));
              },
            ),
            ListTile(
              title: const Text("GDM"),
              leading: const Icon(Icons.local_shipping),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const GDMList()));
              },
            ),
            ListTile(
              title: const Text("Vehicle Log"),
              leading: const Icon(Icons.departure_board_rounded),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const VehicleLogList()));
              },
            ),
            ListTile(
              title: const Text("Unloading Details"),
              leading: const Icon(Icons.receipt_long_rounded),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const UnloadingDetailsList()));
              },
            ),
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