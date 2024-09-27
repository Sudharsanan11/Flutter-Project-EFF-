

import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GDMNotifier extends StateNotifier<AsyncValue<List<Map<String, String>>>> {
  final ApiService apiService;

  int _limitStart = 0;
  bool _isFetching = false;
  bool _hasAllData = false;

  GDMNotifier(this.apiService) : super(const AsyncLoading()){
    fetchData();
  }

  Future<void> fetchData({bool isRefreshing = false, String query = ''}) async{
    if(isRefreshing) _hasAllData = false; _isFetching = false;
    
    if (_isFetching || _hasAllData) return;
    _isFetching = true;

    String fields = '?fields=["name","vehicle_register_no","dispatch_on", "status"]';
    String paginationQuery = '&order_by=modified desc&limit_start=$_limitStart&amp;limit=15';

     try {
      final data = await apiService.getresources(
        ApiEndpoints.authEndpoints.GDM + fields + paginationQuery,
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
final gdmProvider =
    StateNotifierProvider<GDMNotifier, AsyncValue<List<Map<String, String>>>>(
  (ref) => GDMNotifier(ApiService()),
);