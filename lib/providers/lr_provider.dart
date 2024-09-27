

import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LRNotifier extends StateNotifier<AsyncValue<List<Map<String, String>>>> {
  final ApiService apiService;

  int _limitStart = 0;
  bool _isFetching = false;
  bool _hasAllData = false;

  LRNotifier(this.apiService) : super(const AsyncLoading()){
    fetchData();
  }

  Future<void> fetchData({bool isRefreshing = false, String query = ''}) async{
    if(isRefreshing) _hasAllData = false; _isFetching = false;
    if (_isFetching || _hasAllData) return;
    // if(_hasAllData) return;
    _isFetching = true;

    String fields = '?fields=["name","consignor","creation", "status"]';
    String paginationQuery = '&order_by=modified desc&limit_start=$_limitStart&amp;limit=15';

    if(query != ""){
      query = '&filters=[["consignor", "like", "$query%"';
    }

    try {
      final data = await apiService.getresources(
        ApiEndpoints.authEndpoints.LR + fields + paginationQuery,
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
        // else if(previousData.length != data.length){
        //   state = AsyncValue.data([...previousData, data[data.length - 1]]);
        // }
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
final lrProvider =
    StateNotifierProvider<LRNotifier, AsyncValue<List<Map<String, String>>>>(
  (ref) => LRNotifier(ApiService()),
);