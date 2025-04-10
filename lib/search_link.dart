// import 'package:erpnext_logistics_mobile/doc_list/customer_list.dart';
// import 'package:erpnext_logistics_mobile/providers/search_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class SearchLink extends SearchDelegate {
//   final String className;
//   final WidgetRef ref;

//   SearchLink(this.className, this.ref);

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//           ref.read(searchProvider.notifier).search(query);
//         },
//       ),
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
//     ref.read(searchProvider.notifier).search(query);

//     return Consumer(
//       builder: (context, ref, _) {
//         final searchResults = ref.watch(searchProvider);

//         return searchResults.when(
//           data: (data) {
//             if (data.isEmpty) {
//               return const Center(child: Text("No results found"));
//             }
//             return ListView.builder(
//               itemCount: data.length,
//               itemBuilder: (context, index) {
//                 final item = data[index];
//                 return ListTile(
//                   leading: const Icon(Icons.file_open_rounded),
//                   title: Text(item['key1'] ?? 'N/A'),
//                   subtitle: Text(item['key2'] ?? 'N/A'),
//                   onTap: () {
//                     // Navigator.push(
//                     //   context,
//                     //   MaterialPageRoute(
//                     //     builder: (context) => CollectionAssignmentView(name: item['name']!),
//                     //   ),
//                     // );
//                   },
//                 );
//               },
//             );
//           },
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (Object error, StackTrace _) => Center(child: Text("Error: $error")),
//         );
//       },
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     ref.read(searchProvider.notifier).search(query);
//     return buildResults(context);
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpnext_logistics_mobile/providers/search_provider.dart';

class SearchLink extends SearchDelegate {
  final String endpoint;
  final Map<String, dynamic> baseBody;
  final WidgetRef ref;
  final void Function(Map<String, dynamic>) onSelected;
  final List<String> searchFields;

  SearchLink({required this.endpoint, required this.baseBody, required this.ref, required this.onSelected, required this.searchFields});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          ref.read(searchProvider.notifier).search(endpoint, {...baseBody, "filters": []});
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
    final dynamicBody = {
      ...baseBody,
      "filters": [
        ['docstatus', '!=', 2]
      ],
      "or_filters": [
        [searchFields[0], 'like', "%$query%"],
        [searchFields[1], 'like', "%$query%"]
      ],
      // "filters": filters,
      "order_by": 'modified desc',
      "limit_page_length": 15
    };

    ref.read(searchProvider.notifier).search(endpoint, dynamicBody);

    return Consumer(
      builder: (context, ref, _) {
        final AsyncValue<List<Map<String, dynamic>>> searchResults = ref.watch(searchProvider);

        return searchResults.when(
          data: (List<Map<String, dynamic>> data) {
            if (data.isEmpty) {
              return const Center(child: Text("No results found"));
            }
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return ListTile(
                  leading: const Icon(Icons.file_open_rounded),
                  title: Text(item['key1'] ?? 'N/A'),
                  subtitle: Text(item['key2'] ?? 'N/A'),
                  onTap: () {
                    onSelected(item);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace _) => Center(child: Text("Error: $error")),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
