import 'package:erpnext_logistics_mobile/doc_view/collection_assignment_view.dart';
import 'package:erpnext_logistics_mobile/doc_view/collection_request_view.dart';
import 'package:erpnext_logistics_mobile/doc_view/gdm_view.dart';
import 'package:erpnext_logistics_mobile/doc_view/lr_view.dart';
import 'package:flutter/material.dart';
import 'form_view.dart';


class CustomSearchBar extends SearchDelegate {
  final List<Map<dynamic, dynamic>> searchItem;
  final String className;

  CustomSearchBar(this.searchItem, this.className);

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
      if(item['key1'].toLowerCase().contains(query.toLowerCase()) || item['key2'].toLowerCase().contains(query.toLowerCase())) {
        var keys = item.keys.toList();
        matchQuery.add(item[keys[0]] + '\n' + item[keys[1]]);
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
            if(className == "CollectionRequestView"){
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => CollectionRequestView(name: result.split('\n')[0])))
            }
            else if(className == "CollectionAssignmentView"){
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => CollectionAssignmentView(name: result.split('\n')[0])))
            }
            else if(className == "LRList"){
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => LRView(name: result.split('\n')[0])))
            }
            else if(className == "GDMView"){
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => GDMView(name: result.split('\n')[0])))
            }
          });
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for(var item in searchItem) {
      if(item['key1'].toLowerCase().contains(query.toLowerCase()) || item['key2'].toLowerCase().contains(query.toLowerCase())) {
        var keys = item.keys.toList();
        matchQuery.add(item[keys[0]] + '\n' + item[keys[1]]);
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
           if(className == "CollectionRequestView"){
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => CollectionRequestView(name: result.split('\n')[0])))
            }
            else if(className == "CollectionAssignmentView"){
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => CollectionAssignmentView(name: result.split('\n')[0])))
            }
            else if(className == "LRList"){
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => LRView(name: result.split('\n')[0])))
            }
            else if(className == "GDMView"){
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => GDMView(name: result.split('\n')[0])))
            }
          },
        );
      });
  }
}