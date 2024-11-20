import 'package:erpnext_logistics_mobile/Authentication/login.dart';
import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_list/lr_list.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:erpnext_logistics_mobile/push_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    _initializeNotifications();
    _apicall();
    // _get_session();
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

  Future<void> _get_session() async {
    print("sesssssssssssssss");
    try {
      final response = await apiService.get_session(ApiEndpoints.authEndpoints.getSession);
      print(response['Expires']);
      bool validateSession = validateSessionDate(response['Expires']);
      // List cookies = response;
      if(validateSession == true){
        print("sessssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss");
        _logoutUser();
      }
      else{
        print("sesssssssssssssssssssssssssssssssssiomnnmmmmmmmmmmmmmmmmmmmmmmmm");
      }

    } catch (e) {
      setState(() {
        value = e.toString();
      });
    }
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
                // Expanded(
                //   child: TextButton(
                //     style: TextButton.styleFrom(
                //       foregroundColor: Colors.blue,
                //       shape: const RoundedRectangleBorder(
                //         borderRadius: BorderRadius.only(
                //           bottomLeft: Radius.circular(5),
                //         ),
                //       ),
                //     ),
                //     child: const Text('Cancel'),
                //     onPressed: () {
                //       Navigator.of(context).pop();
                //     },
                //   ),
                // ),
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

   Future<void> logout () async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    manager.clear();
  }

  bool validateSessionDate(String expiryDate){
    final paresedDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUTC(expiryDate).toLocal();

      final dayBefore = paresedDate.subtract(const Duration(days: 1));

      final today = DateTime.now();
      final stringOfToday = DateTime(today.year, today.month, today.day);
    return dayBefore.year == stringOfToday.year && dayBefore.month == stringOfToday.month && dayBefore.day != stringOfToday.day;
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