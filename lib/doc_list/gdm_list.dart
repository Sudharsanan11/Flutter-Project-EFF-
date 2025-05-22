import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/doc_view/gdm_view.dart';
import 'package:erpnext_logistics_mobile/home.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:erpnext_logistics_mobile/providers/gdm_provider.dart';
import 'package:erpnext_logistics_mobile/search_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class GDMList extends ConsumerStatefulWidget {
  const GDMList({super.key});

  @override
  ConsumerState<GDMList> createState() => _GDMListState();
}

class _GDMListState extends ConsumerState<GDMList> {
  final ScrollController _scrollController = ScrollController();
  bool _isFetching = false;
  bool viewPermission = false;
  bool createPermission = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _get_permissions() async {
    final Box permissions = Hive.box("permissions");
      final perm = Map<String, dynamic>.from(permissions.get("perm"));
      setState(() {
        viewPermission = perm["GDM"]["read"] ?? false;
        createPermission = perm["GDM"]["create"] ?? false;
      });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && !_isFetching) {
      _isFetching = true;
      ref.read(gdmProvider.notifier).fetchData().then((_) {
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final GDMData = ref.watch(gdmProvider);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => const EFF()));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("GDM List"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                GDMData.when(
                  data: (data) {
                    showSearch(
                      context: context,
                      delegate: SearchLink(
                        endpoint: ApiEndpoints.authEndpoints.getList,
                        baseBody: {
                          "doctype": "GDM",
                          "fields": ["name", "vehicle_register_no", "dispatch_on", "status"],
                          "order_by": 'modified desc',
                          "limit_page_length": 15
                        },
                        searchFields: ['name', 'vehicle_register_no'],
                        ref: ref,
                        onSelected: (selectedItem) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GDMView(name: selectedItem["key1"])),
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
            await ref.read(gdmProvider.notifier).refreshData();
          },
          child: GDMData.when(
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

                  var item = data[index];
                  var consignor = item['key2']!.length >= 20 ? "${item['key2']!.substring(0, 20)}......" : item['key2'];
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.file_open_rounded),
                        title: Text(item['key1'] ?? 'N/A'),
                        subtitle: Text("$consignor"),
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
                            MaterialPageRoute(builder: (context) => GDMView(name: item['key1']!)),
                          );
                        },
                      ),
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
            error: (error, _) {
              return const Center(child: Text("No data Found"));
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueGrey,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const GDMView()));
          },
        ),
        bottomNavigationBar: const BottomNavigation(),
      ),
    );
  }
}
