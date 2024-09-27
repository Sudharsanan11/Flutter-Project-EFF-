class ApiEndpoints {
  static const String baseUrl = "https://eff.4csolutions.in";
  // static const String baseUrl = "http://192.168.1.54:8003";
  static _AuthEndPoints authEndpoints = _AuthEndPoints();
}

class _AuthEndPoints {
  final String registerEmail = '';
  final String loginEmail = '/api/method/logistics.api.login';
  final String employee = '/api/resource/Employee';
  final String getList = '/api/method/frappe.client.get_list';
  final String get = '/api/method/frappe.client.get';
  final String getVehicle = '/api/method/vms.api.validate_vehicle';
  final String getDriver = '/api/method/vms.api.get_driver';
  final String getRoute = '/api/resource/Route Places';
  final String getRequest = '/api/method/logistics.pms.doctype.collection_assignment.collection_assignment.get_collection_request';
  final String CollectionRequest = '/api/resource/Collection Request';
  final String CollectionAssignment = '/api/resource/Collection Assignment';
  final String LR = '/api/resource/LR';
  final String GDM = '/api/resource/GDM';
}