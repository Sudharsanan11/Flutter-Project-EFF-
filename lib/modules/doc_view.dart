import 'package:flutter/material.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:http/http.dart';


class DocList extends StatefulWidget {
  final String title;
  const DocList({super.key, required this.title});

  @override
  State<DocList> createState() => _DocListState();
}

class _DocListState extends State<DocList> {

  String doctype = '';
  List<dynamic> data = [];
  String error = '';
  @override
  void initState(){
    super.initState();
    print("initstate");
    print(widget.title);
    if(widget.title == "LR History") {
      setState(() { 
        doctype = 'LR';
      });
    }
    fetchData();
  }

  Future<void> fetchData() async {
    print("fetchdata");
    print(doctype);
    final ApiService apiService = ApiService();
    try {
      print("try");
      final response = await apiService.getresources('/api/resource/$doctype');
      print(response);
      setState(() {
        data = response['data'];
      });
      print(data);
    }
    catch (e) {
      setState(() {
        error = e.toString();
        print(data);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // backgroundColor: Colors.grey,
        elevation: 5.0,
      ),
      body: Center(child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.file_open_rounded),
          title: Text(data[index]['name']),
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DocList(title: data[index]['name'])),
            )
          },
        );
      })),
      drawer: const AppDrawer(),
      bottomNavigationBar: BottomNavigation(),
    );;
  }
}