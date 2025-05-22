import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_view/customer_form.dart';
import 'package:erpnext_logistics_mobile/providers/collection_assignment_provider.dart';
import 'package:erpnext_logistics_mobile/providers/customer_provider.dart';
import 'package:erpnext_logistics_mobile/search_link.dart';
import 'package:flutter/material.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class CustomerList extends ConsumerStatefulWidget {
  const CustomerList({super.key});

  @override
  ConsumerState<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends ConsumerState<CustomerList> {
  final ScrollController _scrollController = ScrollController();
  bool viewPermission = false;

  Future<void> _get_permissions() async {
    final Box permissions = Hive.box("permissions");
      final perm = Map<String, dynamic>.from(permissions.get("perm"));
      setState(() {
        viewPermission = perm["Customer"]["read"] ?? false;
      });
  }

  Future<void> checkReadPermission() async {
    ApiService apiService = ApiService();
    try {
      Object body = {
        "doctype": "Customer",
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
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        ref.read(CustomerProvider.notifier).fetchData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerData = ref.watch(CustomerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchLink(
                  endpoint: ApiEndpoints.authEndpoints.getList,
                  baseBody: {
                    "doctype": "Customer",
                    "fields": ['name', 'custom_branch', 'custom_party_type', 'customer_group'],
                  },
                  searchFields: ['name', 'custom_branch'],
                  ref: ref,
                  onSelected: (selectedItem){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerForm(name: selectedItem["key1"]),
                      ),
                    );
                  }
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(CustomerProvider.notifier).refreshData();
        },
        child: customerData.when(
          data: (data) {
            if (data.isEmpty) {
              return const Center(child: Text("No Data Found"));
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: data.length + 1,
              itemBuilder: (context, index) {
                if (index == data.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final item = data[index];
                var consignor = item['key1']!.length >= 20 ? "${item['key1']!.substring(0, 20)}......" : item['key1'];
                return ListTile(
                  leading: const Icon(Icons.file_open_rounded),
                  title: Text('$consignor'),
                  subtitle: Text(item['key2'] ?? 'N/A'),
                  trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item['key3'] ?? 'N/A',
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
                        builder: (context) => CustomerForm(name: item['key1']!),
                      ),
                    );
                  },
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
                    await ref.read(CollectionAssignmentProvider.notifier).refreshData();
                    await _get_permissions();
                  },
                ),
            ],
          ),
            );
          },
        ),
      ),
    );
  }
}
