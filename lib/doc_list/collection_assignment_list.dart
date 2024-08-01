import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_view/collection_assignment_view.dart';
import 'package:erpnext_logistics_mobile/forms/collection_assignment_form.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/modules/form_view.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:erpnext_logistics_mobile/modules/search_bar.dart';
import 'package:flutter/material.dart';


class CollectionAssignmentList extends StatefulWidget {
  const CollectionAssignmentList({super.key});

  @override
  State<CollectionAssignmentList> createState() => _CollectionAssignmentListState();
}

class _CollectionAssignmentListState extends State<CollectionAssignmentList> {

  late Future<List<Map<String, String>>> data;

  @override
  void initState() {
    super.initState();
    data = fetchData();
    print(data);
  }

  Future<List<Map<String, String>>> fetchData () async {
    final ApiService apiService = ApiService();
    String fields = '?fields=["name","status"]';

    try {
      return await apiService.getresources(ApiEndpoints.authEndpoints.collectionAssignmentList + fields);
    }
    catch (e) {
      throw('Error $e');
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collection Assignment List"),
        centerTitle: true,
        actions: [
          FutureBuilder<List<Map<String, String>>>(
            future: data,
            builder: (context, snapshot) {
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(context: context, delegate: CustomSearchBar(snapshot.data!));
                  },
                );
              }
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Map<String, String>>>(
        future: data,
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if(snapshot.hasError) {
            return const Center(child: Text("No Data Found"),);
          }
          else if(!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Data Found"),);
          }
          else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var item = snapshot.data![index];
                return ListTile(
                  leading: const Icon(Icons.file_open_rounded),
                  title: Text(item['key1']!),
                  subtitle: Text(item['key2']!),
                  onTap: () {
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CollectionAssignmentView(name: item['key1']!)));
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CollectionAssignmentForm()));
        },
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}