class ApiEndpoints {
  static const String baseUrl = "https://eff.4csolutions.in";
  // static const String baseUrl = "http://192.168.31.208:8000";
  // static const String baseUrl = "http://192.168.1.2:8000";
  static _AuthEndPoints authEndpoints = _AuthEndPoints();
}

class _AuthEndPoints {
  final String registerEmail = '';
  final String loginEmail = '/api/method/logistics.api.login';
  final String session = '/api/method/logistics.api.session';
  final String login = '/api/method/login';
  final String employee = '/api/resource/Employee';
  final String getList = '/api/method/frappe.client.get_list';
  final String get = '/api/method/frappe.client.get';
  final String getVehicle = '/api/method/vms.api.validate_vehicle';
  final String getDriver = '/api/method/vms.api.get_driver';
  final String storeToken = '/api/method/logistics.api.store_token';
  final String updateStatus = '/api/method/logistics.api.update_collection_status';
  final String hasPermission = '/api/method/logistics.api.has_permission';
  final String getRoute = '/api/resource/Route Places';
  final String getRequest = '/api/method/logistics.pms.doctype.collection_assignment.collection_assignment.get_cr';
  final String CollectionRequest = '/api/resource/Collection Request';
  final String CollectionAssignment = '/api/resource/Collection Assignment';
  final String LR = '/api/resource/LR';
  final String GDM = '/api/resource/GDM';
  final String customer = '/api/resource/Customer';
  final String inwardItems = 'api/resource/Inward CFA Items';
  final String outwardItems = 'api/resource/Outward CFA Items';
  final String getSession = '/api/method/logistics.api.get_session';
  final String vehicleLog = '/api/resource/Vehicle Log';
  final String tripLog = '/api/method/logistics.pms.doctype.collection_assignment.collection_assignment.make_vehicle_log';
  final String gdmTripLog = '/api/method/logistics.pms.doctype.gdm.gdm.make_trip_log';
  final String gdmloadingDetails = '/api/method/logistics.whitelist_api.get_loading_deatils';
  final String returnLog = '/api/method/logistics.pms.doctype.collection_assignment.collection_assignment.make_vehicle_return';
  final String loadingDetails = '/api/resource/Loading Details';
  final String gdmDelivery = '/api/method/logistics.whitelist_api.get_delivery_details';
  final String gdmReturnLog = '/api/method/logistics.pms.doctype.gdm.gdm.make_vehicle_return';
  final String branchDelivery = '/api/method/logistics.whitelist_api.get_branch_delivery_details';
  final String getUnloadingDetails = '/api/method/logistics.whitelist_api.make_unloading_details';
  final String fetchLR = '/api/method/logistics.pms.doctype.gdm.gdm.get_lrs';
  final String setPMChecklist = '/api/method/logistics.api.update_pm_checklist';
  final String unLoadingDetails = '/api/resource/Unloading Details';
  final String getLastMonthData = '/api/method/logistics.api.get_last_month_data';
  final String updateLocation = '/api/method/logistics.api.update_location';
  final String updateCustomerLocation = '/api/method/logistics.api.update_customer_location';
}