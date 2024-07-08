import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:http/http.dart';  
import 'package:erpnext_logistics_mobile/modules/form_view.dart';


class DocList extends StatefulWidget {
  final String title;
  const DocList({super.key, required this.title});

  @override
  State<DocList> createState() => _DocListState();
}

class _DocListState extends State<DocList> {

  String doctype = '';
  List<String> data = [];
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
    else if(widget.title == 'Assignment List') {
      setState(() {
        doctype = 'Collection Assignment';
      });
    }
    else if(widget.title == 'GDM') {
      setState(() {
        doctype = 'GDM';
      });
    }
    else if(widget.title == '')
    fetchData();
  }

  Future<void> fetchData() async {
    print("fetchdata");
    print(doctype);
    final ApiService apiService = ApiService();
    try {
      print("try");
      final response = await apiService.getresources('/api/resource/$doctype');
      print("response");
      print(response);
      setState(() {
        print("s");
        data = response;
        print(data);
      });
    }
    catch (e) {
      setState(() {
        error = e.toString();
        print("t");
        print(e);
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchBar(data));
            },
          ),
        ]
      ),
      body: Center(child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.file_open_rounded),
          title: Text(data[index]),
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DocList(title: data[index])),
            )
          },
        );
      })),
      drawer: const AppDrawer(),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}


class CustomSearchBar extends SearchDelegate {
  final List<dynamic> searchItem;

  CustomSearchBar(this.searchItem);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        query = '';
      }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for(var item in searchItem) {
      if(item.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          leading: const Icon(Icons.file_open_rounded),
          title: Text(result),
          onTap: () => {
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => FormView(itemName: result)))
          });
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for(var item in searchItem) {
      if(item.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          leading: const Icon(Icons.file_open_rounded),
          title: Text(result),
          onTap: () => {
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => FormView(itemName: result,)))
          },
        );
      });
  }
}