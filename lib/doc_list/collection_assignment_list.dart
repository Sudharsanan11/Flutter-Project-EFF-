// import 'package:erpnext_logistics_mobile/api_endpoints.dart';
// import 'package:erpnext_logistics_mobile/api_service.dart';
// import 'package:erpnext_logistics_mobile/doc_view/collection_assignment_view.dart';
// import 'package:erpnext_logistics_mobile/home.dart';
// import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
// import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
// import 'package:erpnext_logistics_mobile/modules/search_bar.dart';
// import 'package:erpnext_logistics_mobile/providers/collection_assignment_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';

// class CollectionAssignmentList extends ConsumerStatefulWidget {
//   const CollectionAssignmentList({super.key});

//   @override
//   ConsumerState<CollectionAssignmentList> createState() =>
//       _CollectionAssignmentListState();
// }

// class _CollectionAssignmentListState extends ConsumerState<CollectionAssignmentList> {
//   final ScrollController _scrollController = ScrollController();

//   bool viewPermission = false;
//   bool createPermission = false;

//   @override
//   void initState() {
//     super.initState();
//     checkReadPermission();
//     checkCreatePermission();

//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
//         ref.read(CollectionAssignmentProvider.notifier).fetchData();
//       }
//     });
//   }

//   Future<void> checkReadPermission() async {
//     ApiService apiService = ApiService();
//     try {
//       Object body = {
//         "doctype": "Collection Assignment",
//         "perm_type": "read",
//       };
//       final response =  await apiService.checkPermission(ApiEndpoints.authEndpoints.hasPermission, body);
//       setState(() {
//         viewPermission = response;
//       });
//       // if(response == true){

//       // }
//     }
//     catch (e) {
//       throw e;
//     }
//   }

//    Future<void> checkCreatePermission() async {
//     ApiService apiService = ApiService();
//     try {
//       Object body = {
//         "doctype": "Collection Assignment",
//         "perm_type": "create",
//       };
//       final response = await apiService.checkPermission(ApiEndpoints.authEndpoints.hasPermission, body);
//       print(response);
//       setState(() {
//         createPermission = response;
//       });
//     }
//     catch (e) {
//       throw e;
//     }
//   }

//   // Future<List<Map<String, String>>> fetchData() async {
//   //   final ApiService apiService = ApiService();
//   //   String fields = '?fields=["name","status"]';

//   //   try {
//   //     return await apiService.getresources(
//   //         ApiEndpoints.authEndpoints.CollectionAssignment + fields);
//   //   } catch (e) {
//   //     throw ('Error $e');
//   //   }
//   // }

// //   @override
// //   Widget build(BuildContext context) {
// //     final collectionAssignmentData = ref.watch(CollectionAssignmentProvider);
// //     return PopScope(
// //       canPop: false,
// //       onPopInvoked: (didPop) {
// //         if(didPop) {return;}
// //         Navigator.push(context, 
// //         MaterialPageRoute(builder: (context) => const EFF()));
// //       },
// //       child: Scaffold(
// //         appBar: AppBar(
// //           title: const Text("Collection Assignment List"),
// //           centerTitle: true,
// //           actions: [
// //              IconButton(
// //               icon: const Icon(Icons.search),
// //               onPressed: () {
// //                 collectionAssignmentData.when(
// //                   data: (data) {
// //                     showSearch(
// //                       context: context,
// //                       delegate: CustomSearchBar(data, "CollectionAssignmentView"),
// //                     );
// //                   },
// //                   loading: () {
// //                     ScaffoldMessenger.of(context).showSnackBar(
// //                       const SnackBar(content: Text("Data is still loading...")),
// //                     );
// //                   },
// //                   error: (err, _) {
// //                     ScaffoldMessenger.of(context).showSnackBar(
// //                       SnackBar(content: Text("Error loading data: $err")),
// //                     );
// //                   },
// //                 );
// //               },
// //             ),
// //           ],
// //         ),
// //         drawer: const AppDrawer(),
// //         body: RefreshIndicator(
// //           onRefresh: () async {
// //            await ref.read(CollectionAssignmentProvider.notifier).refreshData();
// //            checkCreatePermission();
// //            checkReadPermission();
// //             // initState();
// //           },
// //           child: SingleChildScrollView(
// //         physics: const AlwaysScrollableScrollPhysics(),
// //         child: ConstrainedBox(
// //           constraints: BoxConstraints(
// //             minHeight: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight,
// //           ),
// //           child: 
// //            collectionAssignmentData.when(
// //             data: (data) {
// //               if (data.isEmpty) {
// //                 return const Center(child: Text("No Data Found"));
// //               }
// //               return ListView.builder(
// //                 controller: _scrollController,
// //                 shrinkWrap: true,
// //                 physics: const NeverScrollableScrollPhysics(),
// //                 itemCount: data.length,
// //                 itemBuilder: (context, index) {
// //                   if (index == data.length) {
// //                     return const Padding(
// //                       padding: EdgeInsets.symmetric(vertical: 16),
// //                       child: Center(child: CircularProgressIndicator()),
// //                     );
// //                   }

// //                   var item = data[index];
// //                   var consignor = item['key2']!.length >= 20 ? "${item['key2']!.substring(0, 20)}......" : item['key2'];
// //                   return Column(
// //                     children:[
// //                       ListTile(
// //                         leading: const Icon(Icons.file_open_rounded),
// //                         title: Text(item['key1'] ?? 'N/A'),
// //                         subtitle: Text("$consignor"),
// //                         trailing: Column(
// //                               mainAxisAlignment: MainAxisAlignment.spaceAround, // Distributes date and status vertically
// //                               crossAxisAlignment: CrossAxisAlignment.end, // Aligns content to the right
// //                               children: [
// //                                 Text(
// //                                   item['key3'] != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(item['key3']!)) : 'N/A', // Display the date at the top right
// //                                   style: const TextStyle(
// //                                     fontSize: 12,
// //                                     color: Colors.grey,
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   item['key4'] ?? "N/A", // Display the status at the bottom right
// //                                   style: TextStyle(
// //                                     color: item['key4'] == 'Collected' ? Colors.green : Colors.red, // Change color based on status
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                                 builder: (context) =>
// //                                     CollectionAssignmentView(name: item['key1']!)),
// //                           );
// //                         },
// //                       ),
// //                       if(index != data.length)
// //                       const Padding(
// //                         padding: EdgeInsets.symmetric(horizontal: 20.0),
// //                         child: Divider(height: 1.0,),
// //                       ),
// //                     ], 
// //                   );
// //                 },
// //               );
// //             },
// //             loading: () => const Center(child: CircularProgressIndicator()),
// //             // error: (err, _) => const Center(child: Text("Error loading data")),
// //             error: (error, stackTrace) {
// //               print(error);
// //               if(viewPermission == false){
// //                 return const Center(child: Text("You don't have permission to access this resources"));
// //               }
// //               return const Center(child: Text("No data Found"));
// //             },
// //           ),
// //         ) ,
// //         )
// //         ),
// //         floatingActionButton: createPermission ? FloatingActionButton(
// //           backgroundColor: Colors.blueGrey,
// //           child: const Icon(
// //             Icons.add,
// //             color: Colors.white,
// //           ),
// //           onPressed: () {
// //             Navigator.push(
// //                 context,
// //                 MaterialPageRoute(
// //                     builder: (context) => const CollectionAssignmentView()));
// //           },
// //         ) : Text(""),
// //         bottomNavigationBar: const BottomNavigation(),
// //       ),
// //     );
// //   }
// // }
// @override
// Widget build(BuildContext context) {
//   final collectionAssignmentData = ref.watch(CollectionAssignmentProvider);

//   return Scaffold(
//     appBar: AppBar(
//       title: const Text("Collection Assignment List"),
//       centerTitle: true,
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.search),
//           onPressed: () {
//             collectionAssignmentData.when(
//               data: (data) {
//                 showSearch(
//                   context: context,
//                   delegate: CustomSearchBar(data, "CollectionAssignmentView"),
//                 );
//               },
//               loading: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Data is still loading...")),
//                 );
//               },
//               error: (err, _) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("Error loading data: $err")),
//                 );
//               },
//             );
//           },
//         ),
//       ],
//     ),
//     drawer: const AppDrawer(),
//     body: RefreshIndicator(
//       onRefresh: () async {
//         await ref.read(CollectionAssignmentProvider.notifier).refreshData();
//         await checkCreatePermission();
//         await checkReadPermission();
//       },
//       child: collectionAssignmentData.when(
//         data: (data) {
//           if (data.isEmpty) {
//             return const Center(child: Text("No Data Found"));
//           }
//           return ListView.builder(
//             controller: _scrollController,
//             physics: const AlwaysScrollableScrollPhysics(),
//             itemCount: data.length,
//             itemBuilder: (context, index) {
//               var item = data[index];
//               var consignor = item['key2']!.length >= 20
//                   ? "${item['key2']!.substring(0, 20)}..."
//                   : item['key2'];
//               return Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.file_open_rounded),
//                     title: Text(item['key1'] ?? 'N/A'),
//                     subtitle: Text("$consignor"),
//                     trailing: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           item['key3'] != null
//                               ? DateFormat('yyyy-MM-dd')
//                                   .format(DateTime.parse(item['key3']!))
//                               : 'N/A',
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         Text(
//                           item['key4'] ?? "N/A",
//                           style: TextStyle(
//                             color: item['key4'] == 'Collected'
//                                 ? Colors.green
//                                 : Colors.red,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               CollectionAssignmentView(name: item['key1']!),
//                         ),
//                       );
//                     },
//                   ),
//                   if (index != data.length)
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20.0),
//                       child: Divider(height: 1.0),
//                     ),
//                 ],
//               );
//             },
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stackTrace) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text("You don't have Permission to access this Resources"),
//                 const SizedBox(height: 20),
//                 IconButton(
//                   icon: const Icon(Icons.refresh, size: 30),
//                   onPressed: () async {
//                     await ref.read(CollectionAssignmentProvider.notifier).refreshData();
//                     await checkCreatePermission();
//                     await checkReadPermission();
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     ),
//     floatingActionButton: createPermission
//         ? FloatingActionButton(
//             backgroundColor: Colors.blueGrey,
//             child: const Icon(
//               Icons.add,
//               color: Colors.white,
//             ),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const CollectionAssignmentView(),
//                 ),
//               );
//             },
//           )
//         : null,
//     bottomNavigationBar: const BottomNavigation(),
//   );
// }
// }


import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:erpnext_logistics_mobile/doc_view/collection_assignment_view.dart';
import 'package:erpnext_logistics_mobile/home.dart';
import 'package:erpnext_logistics_mobile/modules/navigation_bar.dart';
import 'package:erpnext_logistics_mobile/providers/collection_assignment_provider.dart';
import 'package:flutter/material.dart';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
import 'package:erpnext_logistics_mobile/modules/search_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';


class CollectionAssignmentList extends ConsumerStatefulWidget {
  const CollectionAssignmentList({super.key});

  @override
  ConsumerState<CollectionAssignmentList> createState() => _CollectionAssignmentListState();
}

class _CollectionAssignmentListState extends ConsumerState<CollectionAssignmentList> {
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
        ref.read(CollectionAssignmentProvider.notifier).fetchData();
      }
    });
  }

Future<void> checkReadPermission() async {
    ApiService apiService = ApiService();
    try {
      Object body = {
        "doctype": "Collection Assignment",
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
      throw e;
    }
  }

   Future<void> checkCreatePermission() async {
    ApiService apiService = ApiService();
    try {
      Object body = {
        "doctype": "Collection Assignment",
        "perm_type": "create",
      };
      final response = await apiService.checkPermission(ApiEndpoints.authEndpoints.hasPermission, body);
      print(response);
      setState(() {
        createPermission = response;
      });
    }
    catch (e) {
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionAssignmentData = ref.watch(CollectionAssignmentProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const EFF()));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Collection Assignment List"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                collectionAssignmentData.when(
                  data: (data) {
                    showSearch(
                      context: context,
                      delegate: CustomSearchBar(data, "CollectionAssignmentView"),
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
            // Refresh the data (fetch the first page again)
            await ref.read(CollectionAssignmentProvider.notifier).refreshData();
          },
          child: collectionAssignmentData.when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(child: Text("No Data Found"));
              }
              return ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: data.length,
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
                                  item['key4'] ?? "N/A", // Display the status at the bottom right
                                  style: TextStyle(
                                    color: item['key4'] == 'Collected' ? Colors.green : Colors.red, // Change color based on status
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
                                    CollectionAssignmentView(name: item['key1']!)),
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
              print("$err  errrrrrrrrrrrrrrrrrrrrrorrrrrrrrroooooooooooorrrrr");
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
                    builder: (context) => const CollectionAssignmentView()));
          },
        ) : const Text(""),
        bottomNavigationBar: const BottomNavigation(),
      ),
    );
  }
}
