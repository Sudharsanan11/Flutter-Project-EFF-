import 'package:erpnext_logistics_mobile/Authentication/login.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_list/lr_list.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:erpnext_logistics_mobile/push_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _checkAndInitializeNotifications();
    _get_permissions();
    // _apicall();
    // _get_session();
  }

  Future<void> _checkAndInitializeNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      await PushNotifications.init(); // Requests permission
      await PushNotifications.localNotiInit(); // Initialize local notifications
      // Set the flag to false after first run
      await prefs.setBool('isFirstRun', false);
    } else {
      // Just initialize local notifications without requesting permission
      await PushNotifications.localNotiInit();
    }
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

  Future<void> _get_permissions() async {
    List<String> doctype_list = [
    "Customer",
    "Collection Request",
    "Collection Assignment",
    "LR",
    "GDM",
    "Loading Details",
    "Unloading Details",
    "Vehicle Log",
  ];

  final Box _permissions = Hive.box("permissions");
  final ApiService apiService = ApiService();
  // for (var doctype in doctype_list) {
    try {
      Object body = {
        "doctypes": doctype_list,
      };
      final response =  await apiService.checkPermission(ApiEndpoints.authEndpoints.doctype_permissions, body);
      // _permissions.put(doctype, {"read": response[doctype]["read"], "write": response[doctype]["write"]});
      _permissions.put("perm", response);
      print(_permissions.get("perm"));
    }
    catch (e, stacktrace) {
      // debugPrint("Error checking permission for $doctype: $e");
      debugPrintStack(stackTrace: stacktrace);
    }
  // }
  }

  Future<void> _logoutUser() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            'LOGOUT!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your Session got Expired, Please Login Again'),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                    ),
                    child: const Text('Go to Login Page'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      logout();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    manager.clear();
  }

  bool validateSessionDate(String expiryDate) {
    final paresedDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'")
        .parseUTC(expiryDate)
        .toLocal();

    final dayBefore = paresedDate.subtract(const Duration(days: 1));
    final today = DateTime.now();
    final stringOfToday = DateTime(today.year, today.month, today.day);
    
    return dayBefore.year == stringOfToday.year &&
        dayBefore.month == stringOfToday.month &&
        dayBefore.day != stringOfToday.day;
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