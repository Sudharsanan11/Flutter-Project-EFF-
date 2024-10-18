import 'dart:async';

import 'package:erpnext_logistics_mobile/doc_view/collection_assignment_view.dart';
import 'package:erpnext_logistics_mobile/doc_view/collection_request_view.dart';
import 'package:erpnext_logistics_mobile/doc_view/gdm_view.dart';
import 'package:erpnext_logistics_mobile/doc_view/lr_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomSearchBar extends SearchDelegate {
  final List<Map<dynamic, dynamic>> searchItem;
  final String className;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  CustomSearchBar(this.searchItem, this.className);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);  // Refresh the suggestion view when query is cleared
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
    List<Map<dynamic, dynamic>> matchQuery = [];
    for (var item in searchItem) {
      if (item['key1'].toLowerCase().contains(query.toLowerCase()) ||
          item['key2'].toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }

    if (matchQuery.isEmpty) {
      return const Center(child: Text("No results found"));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var item = matchQuery[index];
        String formattedDate = item['key3'] != null
            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(item['key3']))
            : 'N/A';

        return ListTile(
          leading: const Icon(Icons.file_open_rounded),
          title: Text(item['key1'] ?? 'N/A'),
          subtitle: Text(item['key2'] ?? 'N/A'),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(item['key4'] ?? 'N/A', style: TextStyle(color: item['key4'] == 'Approved' ? Colors.green : Colors.red)),
            ],
          ),
          onTap: () {
            // Navigate to the corresponding view based on the className
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
                  builder: (context) => LRView(name: item['key1']!, data: const {},),
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
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // _onQueryChanged();

    List<Map<dynamic, dynamic>> matchQuery = [];
    for (var item in searchItem) {
      if (item['key1'].toLowerCase().contains(query.toLowerCase()) ||
          item['key2'].toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var item = matchQuery[index];
        String formattedDate = item['key3'] != null
            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(item['key3']))
            : 'N/A';

        return ListTile(
          leading: const Icon(Icons.file_open_rounded),
          title: Text(item['key1'] ?? 'N/A'),
          subtitle: Text(item['key2'] ?? 'N/A'),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(item['key4'] ?? 'N/A', style: TextStyle(color: item['key4'] == 'Approved' ? Colors.green : Colors.red)),
            ],
          ),
          onTap: () {
            // Same navigation logic as buildResults
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
                  builder: (context) => LRView(name: item['key1']!, data: const {},),
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
  }

//   void _onQueryChanged() {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();

//     _debounce = Timer(const Duration(milliseconds: 300), () {
//       showSuggestions(); // Rebuild the suggestion view
//     });
//   }
}
