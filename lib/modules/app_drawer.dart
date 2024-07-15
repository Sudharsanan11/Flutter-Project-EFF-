import "package:erpnext_logistics_mobile/doc_list/collection_assignment_list.dart";
import "package:erpnext_logistics_mobile/doc_list/collection_request_list.dart";
import "package:erpnext_logistics_mobile/doc_list/gdm_list.dart";
import "package:erpnext_logistics_mobile/doc_list/lr_list.dart";
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
    //   // Item(name: "Home", icon: Icons.home),
    //   Item(name: "LR History", icon: Icons.history),
    //   Item(name: "Assignment List", icon: Icons.list),
    //   Item(name: "GDM", icon: Icons.local_shipping),
    //   Item(name: "Create LR", icon: Icons.receipt_long)
    // ];
    // return Drawer(
    //   backgroundColor: Colors.white,
    //   child: ListView.builder(
    //     itemCount: items.length,
    //     itemBuilder: (context, index) {
    //       return ListTile(
    //         leading: Icon(items[index].icon),
    //         title: Text(items[index].name),
    //         onTap: () {
    //           Navigator.push(context,
    //           MaterialPageRoute(builder: (context) => DocList(title: items[index].name)));
    //         },
    //       );
    //     },
    //   ),
    // );
    return Drawer(
      backgroundColor: Colors.white,
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
              leading: const Icon(Icons.format_list_bulleted),
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
                MaterialPageRoute(builder: (context) => const GdmList()));
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