class ApiEndpoints {
  static const String baseUrl = "http://192.168.1.11:8003";
  static _AuthEndPoints authEndpoints = _AuthEndPoints();
}

class _AuthEndPoints {
  final String registerEmail = '';
  final String loginEmail = '/api/method/logistics.api.login';
  final String employee = '/api/resource/Employee';
  final String getList = '/api/method/frappe.client.get_list';
  final String get = '/api/method/frappe.client.get';
  final String CollectionRequest = '/api/resource/Collection Request';
  final String CollectionAssignment = '/api/resource/Collection Assignment';
  final String LR = '/api/resource/LR';
  final String GDM = '/api/resource/GDM';
}