import 'package:flutter/material.dart';
// import 'package:eff_logistics/modules/assigned_order.dart';
import "package:erpnext_logistics_mobile/modules/form_view.dart";

void main() => runApp(const MaterialApp(
  home: EFF(),
));

class EFF extends StatefulWidget {
  const EFF({super.key});
  @override
  State<EFF> createState() => _EFFState();
}

class _EFFState extends State<EFF> {
  @override
  Widget build(BuildContext context) {
    final List<Item> items = [
      Item(name: "Home", icon: Icons.home),
      Item(name: "LR History", icon: Icons.history),
      Item(name: "Assignment List", icon: Icons.list)
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("EFF Logistics"),
      ),
      /*drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text("User Name"),
              accountEmail: Text("user@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  "U",
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time_filled_sharp),
              title: const Text('LR History'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.create),
              title: const Text('Create LR'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Assigned Order'),
              onTap: () {
                Navigator.pop(context);
                // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AssignedOrder()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Dispatch List'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Expense Sheet'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Other Expense'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),*/
      drawer: Drawer(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(items[index].icon),
              title: Text(items[index].name),
              onTap: () {
                Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => FormView(itemName: items[index].name)));
              },
            );
          }
        ),
      ),
      body: const Center(
        child: Text("Welcome to EFF Logistics"),
      ),
    );
  }
}

class Item {
  final String name;
  final IconData icon;

  Item({required this.name, required this.icon});
}

