import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_view/outward_cfa_items_form.dart';
import 'package:erpnext_logistics_mobile/home.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:erpnext_logistics_mobile/providers/outward_cfa_items_provider.dart';
import 'package:erpnext_logistics_mobile/search_link.dart';
import 'package:flutter/material.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';


class OutwardCFAItemsList extends ConsumerStatefulWidget {
  const OutwardCFAItemsList({super.key});

  @override
  ConsumerState<OutwardCFAItemsList> createState() => _OutwardCFAItemsListState();
}

class _OutwardCFAItemsListState extends ConsumerState<OutwardCFAItemsList> {
  final ScrollController _scrollController = ScrollController();

  bool viewPermission = false;
  bool createPermission = false;

  @override
  void initState() {
    super.initState();
    checkReadPermission();
    checkCreatePermission();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        ref.read(outwardCFAItemProvider.notifier).fetchData();
      }
    });
  }

Future<void> checkReadPermission() async {
    ApiService apiService = ApiService();
    try {
      Object body = {
        "doctype": "Outward CFA Items",
        "perm_type": "read",
      };
      final response =  await apiService.checkPermission(ApiEndpoints.authEndpoints.hasPermission, body);
      setState(() {
        viewPermission = response;
      });
      // if(response == true){

      // }
    }
    catch (e) {
      rethrow;
    }
  }

   Future<void> checkCreatePermission() async {
    ApiService apiService = ApiService();
    try {
      Object body = {
        "doctype": "Outward CFA Items",
        "perm_type": "create",
      };
      final response = await apiService.checkPermission(ApiEndpoints.authEndpoints.hasPermission, body);
      print(response);
      setState(() {
        createPermission = response;
      });
    }
    catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final outwardData = ref.watch(outwardCFAItemProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const EFF()));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Outward CFA Items List"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                outwardData.when(
                  data: (data) {
                    showSearch(
                      context: context,
                      delegate: SearchLink(
                        endpoint: ApiEndpoints.authEndpoints.getList,
                        baseBody: {
                          "doctype": "Outward CFA Items",
                          "fields": ['name', 'consignor', 'creation', 'status'],
                        },
                        searchFields: ['name', 'consignor'],
                        ref: ref,
                        onSelected: (selectedItem){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OutwardCFAItemsForm(name: selectedItem["key1"],),
                            ),
                          );
                        }),
                    );
                  },
                  loading: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Data is still loading...")),
                    );
                  },
                  error: (err, _) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error loading data: $err")),
                    );
                  },
                );
              },
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.read(outwardCFAItemProvider.notifier).refreshData();
          },
          child: outwardData.when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(child: Text("No Data Found"));
              }
              return ListView.builder(
                controller: _scrollController,
                // physics: const AlwaysScrollableScrollPhysics(),
                itemCount: data.length + 1,
                itemBuilder: (context, index) {
                  if (index == data.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  var item = data[index];
                  var consignor = item['key2']!.length >= 20 ? "${item['key2']!.substring(0, 20)}......" : item['key2'];
                  return Column(
                    children:[
                      ListTile(
                        leading: const Icon(Icons.file_open_rounded),
                        title: Text(item['key1'] ?? 'N/A'),
                        subtitle: Text("$consignor"),
                        trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item['key3'] != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(item['key3']!)) : 'N/A',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  item['key4'] ?? "N/A",
                                  style: TextStyle(
                                    color: item['key4'] == 'Collected' ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    OutwardCFAItemsForm(name: item['key1']!)),
                          );
                        },
                      ),
                      if(index != data.length)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(height: 1.0,),
                      ),
                    ], 
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) {
              return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Error loading data"),
              const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 30),
                  onPressed: () async {
                    await ref.read(outwardCFAItemProvider.notifier).refreshData();
                    await checkCreatePermission();
                    await checkReadPermission();
                  },
                ),
            ],
          ),
            );}
          ),
        ),
        floatingActionButton: createPermission ? FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OutwardCFAItemsForm()));
          },
        ) : const Text(""),
        bottomNavigationBar: const BottomNavigation(),
      ),
    );
  }
}
