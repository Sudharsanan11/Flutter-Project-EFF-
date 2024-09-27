// import 'package:erpnext_logistics_mobile/doc_view/collection_assignment_view.dart';
// import 'package:erpnext_logistics_mobile/doc_view/collection_request_view.dart';
// import 'package:erpnext_logistics_mobile/doc_view/gdm_view.dart';
// import 'package:erpnext_logistics_mobile/doc_view/lr_view.dart';
// import 'package:flutter/material.dart';


// class CustomSearchBar extends SearchDelegate {
//   final List<Map<dynamic, dynamic>> searchItem;
//   final String className;

//   CustomSearchBar(this.searchItem, this.className);

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//       icon: const Icon(Icons.clear),
//       onPressed: () {
//         query = '';
//       }),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     List<String> matchQuery = [];
//     for(var item in searchItem) {
//       if(item['key1'].toLowerCase().contains(query.toLowerCase()) || item['key2'].toLowerCase().contains(query.toLowerCase())) {
//         var keys = item.keys.toList();
//         matchQuery.add(item[keys[0]] + '\n' + item[keys[1]]);
//       }
//     }
//     return ListView.builder(
//       itemCount: matchQuery.length,
//       itemBuilder: (context, index) {
//         var result = matchQuery[index];
//         return ListTile(
//           leading: const Icon(Icons.file_open_rounded),
//           title: Text(result),
//           onTap: () => {
//             if(className == "CollectionRequestView"){
//             Navigator.push(context,
//             MaterialPageRoute(builder: (context) => CollectionRequestView(name: result.split('\n')[0])))
//             }
//             else if(className == "CollectionAssignmentView"){
//               Navigator.push(context,
//               MaterialPageRoute(builder: (context) => CollectionAssignmentView(name: result.split('\n')[0])))
//             }
//             else if(className == "LRList"){
//               Navigator.push(context,
//               MaterialPageRoute(builder: (context) => LRView(name: result.split('\n')[0])))
//             }
//             else if(className == "GDMView"){
//               Navigator.push(context,
//               MaterialPageRoute(builder: (context) => GDMView(name: result.split('\n')[0])))
//             }
//           });
//     });
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     List<String> matchQuery = [];
//     for(var item in searchItem) {
//       if(item['key1'].toLowerCase().contains(query.toLowerCase()) || item['key2'].toLowerCase().contains(query.toLowerCase())) {
//         var keys = item.keys.toList();
//         matchQuery.add(item[keys[0]] + '\n' + item[keys[1]]);
//       }
//     }
//     return ListView.builder(
//       itemCount: matchQuery.length,
//       itemBuilder: (context, index) {
//         var result = matchQuery[index];
//         return ListTile(
//           leading: const Icon(Icons.file_open_rounded),
//           title: Text(result),
//           // trailing: searchItem[index]['key3'] ?? "",
//           onTap: () => {
//            if(className == "CollectionRequestView"){
//             Navigator.push(context,
//             MaterialPageRoute(builder: (context) => CollectionRequestView(name: result.split('\n')[0])))
//             }
//             else if(className == "CollectionAssignmentView"){
//               Navigator.push(context,
//               MaterialPageRoute(builder: (context) => CollectionAssignmentView(name: result.split('\n')[0])))
//             }
//             else if(className == "LRList"){
//               Navigator.push(context,
//               MaterialPageRoute(builder: (context) => LRView(name: result.split('\n')[0])))
//             }
//             else if(className == "GDMView"){
//               Navigator.push(context,
//               MaterialPageRoute(builder: (context) => GDMView(name: result.split('\n')[0])))
//             }
//           },
//         );
//       });
//   }
// }

import 'dart:async';

import 'package:erpnext_logistics_mobile/doc_view/collection_assignment_view.dart';
import 'package:erpnext_logistics_mobile/doc_view/collection_request_view.dart';
import 'package:erpnext_logistics_mobile/doc_view/gdm_view.dart';
import 'package:erpnext_logistics_mobile/doc_view/lr_view.dart';
import 'package:erpnext_logistics_mobile/providers/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; 

class CustomSearchBar extends SearchDelegate {
  final List<Map<dynamic, dynamic>> searchItem;
  final String className;
  final WidgetRef ref;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  CustomSearchBar(this.searchItem, this.className, this.ref){
    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !ref.read(searchProvider).isLoading){
        ref.read(searchProvider.notifier).fetchSearchResults(className, query);
      }
    });
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
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
    ref.read(searchProvider.notifier).fetchSearchResults(className, query);

    return Consumer(
      builder: (context, ref, child) {
        final searchResults = ref.watch(searchProvider);

        return searchResults.when(
          data: (data) {
            if (data.isEmpty) {
              return const Center(child: Text("No results found"));
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: data.length,
              itemBuilder: (context, index) {
                var item = data[index];
                String formattedDate = item['key3'] != null
                    ? DateFormat('yyyy-MM-dd').format(DateTime.parse(item['key3']))
                    : 'N/A';

                return ListTile(
                  leading: const Icon(Icons.file_open_rounded),
                  title: Text(item['key1'] ?? 'N/A'),
                  subtitle: Text(item['key2'] ?? 'N/A'),
                  
                  // Show date and status on the right side
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(item['key4'] ?? 'N/A', style: TextStyle(color: item['key4'] == 'Approved' ? Colors.green : Colors.red)),
                    ],
                  ),
                  
                  onTap: () {
                    // Navigate to the corresponding view
                    if (className == "CollectionRequestView") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CollectionRequestView(name: item['key1']!),
                        ),
                      );
                    } else if (className == "CollectionAssignmentView") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CollectionAssignmentView(name: item['key1']!),
                        ),
                      );
                    } else if (className == "LRList") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LRView(name: item['key1']!),
                        ),
                      );
                    } else if (className == "GDMView") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GDMView(name: item['key1']!),
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => const Center(child: Text("Error loading data")),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // ref.read(searchProvider.notifier).fetchSearchResults(className, query);

    // return buildResults(context); // Reuse the same UI for suggestions

    _onQueryChanged();

    return buildResults(context);
  }

  void _onQueryChanged() {

    if(_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if(query.isNotEmpty){
        ref.read(searchProvider.notifier).fetchSearchResults(className, query);
      }
    });
  }
}
