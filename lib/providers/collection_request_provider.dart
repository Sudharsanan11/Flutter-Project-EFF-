import 'package:erpnext_logistics_mobile/api_endpoints.dart';
import 'package:erpnext_logistics_mobile/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String employee = prefs.getString("employee")!;
    String customer = prefs.getString("customer")!;

    Map<String, dynamic> body = {
      "doctype": "Collection Request",
      "fields": ['name', 'consignor', 'vehicle_required_date', 'status'],
      "order_by": 'modified desc',
      "limit_start": _limitStart,
      "limit_page_length": 15
    };

    if (customer.isNotEmpty && employee.isEmpty) {
      body["filters"] = [
        ["consignor", "=", customer]
      ];
    }

    try {
      final data = await apiService.getresource(ApiEndpoints.authEndpoints.getList, body);
      for(var i in data){
        print(i);
      }

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
      }

    } catch (e) {
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
final collectionRequestProvider =
    StateNotifierProvider<CollectionRequestNotifier, AsyncValue<List<Map<String, String>>>>(
  (ref) => CollectionRequestNotifier(ApiService()),
);

