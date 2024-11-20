import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollectionAssignmentNotifier extends StateNotifier<AsyncValue<List<Map<String, String>>>> {
  final ApiService apiService ;

  int _limitStart = 0;
  bool _isFetching = false;
  bool _hasAllData = false;

  CollectionAssignmentNotifier(this.apiService) : super(const AsyncValue.loading()){
    fetchData();
  }

  Future<void> fetchData({bool isRefreshing = false, String query = ''}) async{
    if(isRefreshing) _hasAllData = false; _isFetching = false;
    if (_isFetching || _hasAllData) return;

    _isFetching = true;

    String fields = '?fields=["name","assigned_vehicle","date","status"]';
    String paginationQuery = '&order_by=modified desc&limit_start=$_limitStart&amp;limit_page_length=15';
    // if(query != ""){
    //   query = '&filters=[["consignor", "like", "$query%"';
    // }
     Object body = {
        "doctype": "Collection Assignment",
        // "filters": [["consignor", "like", "$query%"]]
        "fields": ['name', 'assigned_vehicle', 'date', 'status'],
        "order_by": 'modified desc',
        "limit_start": _limitStart,
        "limit_page_length": 15
      };
    try {
     
      final data = await apiService.getresource(ApiEndpoints.authEndpoints.getList, body);
      for(var i in data){
        print(i);
      }

      print('$data --------------00000000000000000000000-0-0-00-0-0-0-0-0');
      if (isRefreshing) {
        state = AsyncValue.data(data);
      } else {
        final previousData = state.value ?? [];
        // if(previousData.length != data.length){
        state = AsyncValue.data([...previousData, ...data]);
        // }
        if(data.length == 15){
        _limitStart = _limitStart + 15;
        }
        else{
          _hasAllData = true;
          return;
        }
      }} catch (e) {
        if (state.hasValue && isRefreshing == false){
          return;
        }
        else{
          state = AsyncValue.error(e, StackTrace.empty);
        }
    }

    _isFetching = false;
  }
  Future<void> refreshData() async {
    _limitStart = 0;
    await fetchData(isRefreshing: true);
  }
}

final CollectionAssignmentProvider = 
  StateNotifierProvider<CollectionAssignmentNotifier, AsyncValue<List<Map<String, String>>>>((ref) => CollectionAssignmentNotifier(ApiService()),);