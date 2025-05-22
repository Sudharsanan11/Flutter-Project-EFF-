import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_view/lr_view.dart';
import 'package:erpnext_logistics_mobile/home.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:erpnext_logistics_mobile/providers/lr_provider.dart';
import 'package:erpnext_logistics_mobile/search_link.dart';
import 'package:flutter/material.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class LRList extends ConsumerStatefulWidget {
  const LRList({super.key});

  @override
  ConsumerState<LRList> createState() => _LRListState();
}

class _LRListState extends ConsumerState<LRList> {
  final ScrollController _scrollController = ScrollController();

  bool viewPermission = false;
  bool createPermission = false;

  @override
  void initState() {
    super.initState();
    _get_permissions();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        ref.read(lrProvider.notifier).fetchData();
      }
    });
  }

  Future<void> checkPermissions() async {
    await checkReadPermission();
    await checkCreatePermission();
  }

  Future<void> _get_permissions() async {
    final Box permissions = Hive.box("permissions");
      final perm = Map<String, dynamic>.from(permissions.get("perm"));
      setState(() {
        viewPermission = perm["LR"]["read"] ?? false;
        createPermission = perm["LR"]["create"] ?? false;
      });
  }

  Future<void> checkReadPermission() async {
    try {
      final response = await ApiService().checkPermission(
        ApiEndpoints.authEndpoints.hasPermission,
        {"doctype": "LR", "perm_type": "read"},
      );
      setState(() => viewPermission = response);
    } catch (e) {
      debugPrint("Error checking read permission: $e");
    }
  }

  Future<void> checkCreatePermission() async {
    try {
      final response = await ApiService().checkPermission(
        ApiEndpoints.authEndpoints.hasPermission,
        {"doctype": "LR", "perm_type": "create"},
      );
      setState(() => createPermission = response);
    } catch (e) {
      debugPrint("Error checking create permission: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final LRData = ref.watch(lrProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => const EFF()));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("LR List"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                LRData.when(
                  data: (data) {
                    showSearch(
                      context: context,
                      delegate: SearchLink(
                        endpoint: ApiEndpoints.authEndpoints.getList,
                        baseBody: {
                          "doctype": "LR",
                          "fields": ['name', 'consignor', 'creation', 'status'],
                        },
                        searchFields: ['name', 'consignor'],
                        ref: ref,
                        onSelected: (selectedItem) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LRView(name: selectedItem["key1"], data: const {}),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data is still loading...")),
                  ),
                  error: (err, _) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error loading data: $err")),
                  ),
                );
              },
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.read(lrProvider.notifier).refreshData();
          },
          child: SizedBox(
            height: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight,
            child: LRData.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(child: Text("No Data Found"));
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: data.length + (data.length >= 15 ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= data.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    var item = data[index];
                    var consignor = item['key2'] ?? 'Unknown';
                    if (consignor.length > 20) {
                      consignor = "${consignor.substring(0, 20)}...";
                    }

                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.file_open_rounded),
                          title: Text(item['key1'] ?? 'N/A'),
                          subtitle: Text(consignor),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item['key3'] != null
                                    ? DateFormat('yyyy-MM-dd').format(DateTime.parse(item['key3']!))
                                    : 'N/A',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                                builder: (context) => LRView(name: item['key1']!, data: const {}),
                              ),
                            );
                          },
                        ),
                        if (index < data.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Divider(height: 1.0),
                          ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Error loading data"),
                    const SizedBox(height: 20),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 30),
                      onPressed: () async {
                        await ref.read(lrProvider.notifier).refreshData();
                        await checkPermissions();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: createPermission
            ? FloatingActionButton(
                backgroundColor: Colors.black,
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LRView(data: {})),
                  );
                },
              )
            : null,
        bottomNavigationBar: const BottomNavigation(),
      ),
    );
  }
}
