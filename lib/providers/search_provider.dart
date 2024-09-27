


import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchProvider = StateNotifierProvider<SearchNotifier, AsyncValue<List<Map<String, dynamic>>>>(
  (ref) => SearchNotifier(),
);

class SearchNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  SearchNotifier() : super(const AsyncValue.data([]));

  int _currentLimit = 10;
  bool isLoading = false;

  Future<void> fetchSearchResults(String className, String query, {bool isPagination = false}) async {
    if(isPagination) {
      isLoading = true;
    }
    else{
      _currentLimit = 10;
      state = const AsyncValue.loading();
    }
    try {
      state = const AsyncValue.loading();
      List<Map<String, dynamic>> results;

      // Handle different API calls based on the class name
      if (className == "CollectionRequestView") {
        results = await fetchCollectionRequestResults(query, _currentLimit);
      } else if (className == "CollectionAssignmentView") {
        results = await fetchCollectionAssignmentResults(query);
      } else if (className == "LRList") {
        results = await fetchLRResults(query);
      } else if (className == "GDMView") {
        results = await fetchGDMResults(query);
      } else {
        results = [];
      }

      if(isPagination){
        state = state.whenData((oldData) => [...oldData, ...results]);
        _currentLimit++;
      }
      else{
        state = AsyncValue.data(results);
      }

      // state = AsyncValue.data(results);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.empty);
    }
  }

  Future<List<Map<String, dynamic>>> fetchCollectionRequestResults(String query, int currentLimit) async {
    ApiService apiService = ApiService();
    // int _currentLimit = 15;
    String fields = '?fields=["name","consignor","date", "status"]';
    String limit = '&limit=$_currentLimit';
    if(query != ""){
      query = '&filters=[["cosignor", "like", "$query%';
    }
    try{
      final data = await apiService.getresources(
        ApiEndpoints.authEndpoints.CollectionRequest + fields + limit + query,
      );

      _currentLimit = _currentLimit + 5;

      return data;

    }
    catch(e){
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCollectionAssignmentResults(String query) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchLRResults(String query) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchGDMResults(String query) async {
    return [];
  }
}
