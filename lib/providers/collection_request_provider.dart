
// import 'dart:convert';

// import 'package:erpnext_logistics_mobile/api_endpoints.dart';
// import 'package:erpnext_logistics_mobile/api_service.dart';
// import 'package:erpnext_logistics_mobile/doc_list/collection_request_list.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';


// class CollectionRequestState {
//   final List<Map<String, String>> collectionRequest;
//   final bool isLoading;
//   final bool hasError;

//   CollectionRequestState({
//     required this.collectionRequest,
//     required this.isLoading,
//     required this.hasError,
//   });

//   CollectionRequestState copyWith({
//     List<Map<String, String>>? collectionRequest,
//     bool? isLoading,
//     bool? hasError,
//   }) {
//     return CollectionRequestState(
//       collectionRequest: collectionRequest ?? this.collectionRequest,
//       isLoading: isLoading ?? this.isLoading,
//       hasError: hasError ?? this.hasError
//     );
//   }
// }


// class CollectionRequestNotifier extends StateNotifier<CollectionRequestState>{
//   CollectionRequestNotifier() : super(CollectionRequestState(
//     collectionRequest: [],
//     isLoading: false,
//     hasError: false
//   ));

//   final ApiService apiService = ApiService();

//   Future<void> fetchCollectionRequest() async{
//     state = state.copyWith(isLoading: true, hasError: false);

//     String fields = '?fields=["name", "consignor"]';

//     try{
//       final response = await apiService.getresources(ApiEndpoints.authEndpoints.CollectionRequest + fields);
//         state = state.copyWith(collectionRequest: response, isLoading: false);
//     }
//     catch(e){
//         state = state.copyWith(isLoading: false, hasError: true);
//       throw "Date Fetch Error";
//     }
//   }

//   void clearRequest(){
//     state = state.copyWith(collectionRequest: []);
//   }
// }

// final CollectionRequestProvider = StateNotifierProvider<CollectionRequestNotifier, CollectionRequestState>((ref) {
//   return CollectionRequestNotifier();
// });

// import 'package:erpnext_logistics_mobile/api_endpoints.dart';
// import 'package:erpnext_logistics_mobile/api_service.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';


// class CollectionRequestNotifier extends StateNotifier<AsyncValue<List<Map<String, String>>>> {
//   final ApiService apiService;
//   CollectionRequestNotifier(this.apiService) : super(const AsyncValue.loading()) {
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     String fields = '?fields=["name","consignor"]';
//     try {
//       final data = await apiService.getresources(ApiEndpoints.authEndpoints.CollectionRequest + fields);
//       state = AsyncValue.data(data);
//     } catch (e) {
//       state = AsyncValue.error(e, StackTrace.empty);
//     }
//   }

//   // Future<void> refreshData() async {
//   //   state = const AsyncValue.loading();
//   //   await fetchData();,
//   // }
// }


// final collectionRequestProvider =
//     StateNotifierProvider<CollectionRequestNotifier, AsyncValue<List<Map<String, String>>>>(
//   (ref) => CollectionRequestNotifier(ApiService()),
// );


import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollectionRequestNotifier extends StateNotifier<AsyncValue<List<Map<String, String>>>> {
  final ApiService apiService;
  int _limitStart = 0;
  bool _isFetching = false;
  bool _hasAllData = false;

  CollectionRequestNotifier(this.apiService) : super(const AsyncValue.loading()) {
    fetchData();
  }

  Future<void> fetchData({bool isRefreshing = false, String query = ''}) async {
    if(isRefreshing) _hasAllData = false; _isFetching = false;
    print(_hasAllData);
    print(_isFetching);
    if (_isFetching || _hasAllData) return;
    _isFetching = true;
    print("fetchdata");


    String fields = '?fields=["name","consignor","date", "status"]';
    String paginationQuery = '&order_by=modified desc&limit_start=$_limitStart&amp;limit=15';
    if(query != ""){
      query = '&filters=[["consignor", "like", "$query%"';
    }

    try {
      final data = await apiService.getresources(
        ApiEndpoints.authEndpoints.CollectionRequest + fields + paginationQuery,
      );

      if (isRefreshing) {
        state = AsyncValue.data(data);
      } else {
        final previousData = state.value ?? [];
        if(previousData.length != data.length){
        state = AsyncValue.data([...previousData, ...data]);
        }
        if(data.length == 15){
        _limitStart = _limitStart + 15;
        }
        else{
          _hasAllData = true;
          return;
        }
      }

    } catch (e) {
      state = AsyncValue.error(e, StackTrace.empty);
    }

    _isFetching = false;
  }
  Future<void> refreshData() async {
    _limitStart = 0;
    await fetchData(isRefreshing: true);
  }
}
final collectionRequestProvider =
    StateNotifierProvider<CollectionRequestNotifier, AsyncValue<List<Map<String, String>>>>(
  (ref) => CollectionRequestNotifier(ApiService()),
);

