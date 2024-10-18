import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_list/lr_list.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:erpnext_logistics_mobile/push_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EFF extends ConsumerStatefulWidget {
  const EFF({super.key});

  @override
  ConsumerState<EFF> createState() => _EFFState();
}

class _EFFState extends ConsumerState<EFF> {
  String value = "***";
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    _initializeNotifications();
    _apicall();
  }

  Future<void> _initializeNotifications() async {
    await PushNotifications.init(); // Requests permission
    await PushNotifications.localNotiInit(); // Initialize local notifications
  }

  Future<void> _apicall() async {
    try {
      final response =
          await apiService.getresources(ApiEndpoints.authEndpoints.employee);
      setState(() {
        value = response.toString();
      });
    } catch (e) {
      setState(() {
        value = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EFF Logistics"),
        elevation: 5.0,
      ),
      drawer: const AppDrawer(),
      body: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.album),
                    title: Text('Pending Jobs'),
                    subtitle: Text(
                      '10',
                      style: TextStyle(fontSize: 30.0),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LRList()),
                          );
                        },
                        child: const Text('View Details'),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.work),
                    title: Text('Completed Jobs'),
                    subtitle: Text(
                      '25',
                      style: TextStyle(fontSize: 30.0),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LRList()),
                          );
                        },
                        child: const Text('View Details'),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}