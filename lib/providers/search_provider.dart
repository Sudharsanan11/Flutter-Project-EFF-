


import 'dart:async';

import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// class CustomerSearchNotifier extends StateNotifier<AsyncValue<List<Map<String, String>>>> {
//   final ApiService apiService;

//   CustomerSearchNotifier(this.apiService) : super(const AsyncValue.data([]));

//   Timer? _debounce;

//   void searchCustomers(String query) {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();

//     _debounce = Timer(const Duration(milliseconds: 300), () async {
//       if (query.isEmpty) {
//         state = const AsyncValue.data([]);
//         return;
//       }

//       state = const AsyncValue.loading();

//       try {
//         Map<String, dynamic> body = {
//           "doctype": "Customer",
//           "fields": ['name', 'custom_party_type', 'custom_location', 'custom_branch'],
//           "filters": [["name", "like", "%$query%"]],
//           "order_by": 'modified desc',
//           "limit_page_length": 15,
//         };
//         final data = await apiService.getresource(ApiEndpoints.authEndpoints.getList, body);
//         state = AsyncValue.data(data);
//       } catch (e) {
//         state = AsyncValue.error(e, StackTrace.current);
//       }
//     });
//   }
// }

// final customerSearchProvider =
//     StateNotifierProvider<CustomerSearchNotifier, AsyncValue<List<Map<String, String>>>>(
//   (ref) => CustomerSearchNotifier(ApiService()),
// );

// import 'dart:async';
// import 'package:erpnext_logistics_mobile/api_endpoints.dart';
// import 'package:erpnext_logistics_mobile/api_service.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ApiService apiService;

  SearchNotifier(this.apiService) : super(const AsyncValue.data([]));

  Timer? _debounce;

  void search(String endpoint, Map<String, dynamic> body) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (body["filters"] == null || body["filters"].isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      state = const AsyncValue.loading();

      try {print(body);
        final data = await apiService.getresource(endpoint, body);
        state = AsyncValue.data(List<Map<String, dynamic>>.from(data));
      } catch (e) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    });
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, AsyncValue<List<Map<String, dynamic>>>>(
  (ref) => SearchNotifier(ApiService()),
);
