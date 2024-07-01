import "package:flutter/material.dart";
import "package:erpnext_logistics_mobile/modules/doc_list.dart";

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final List<Item> items = [
      // Item(name: "Home", icon: Icons.home),
      Item(name: "LR History", icon: Icons.history),
      Item(name: "Assignment List", icon: Icons.list),
      Item(name: "GDM", icon: Icons.local_shipping),
      Item(name: "Create LR", icon: Icons.receipt_long)
    ];
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(items[index].icon),
            title: Text(items[index].name),
            onTap: () {
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => DocList(title: items[index].name)));
            },
          );
        }
      ),
    );
  }
}

class Item {
  final String name;
  final IconData icon;

  Item({required this.name, required this.icon});
}