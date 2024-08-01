class ApiEndpoints {
  static const String baseUrl = "https://eff.4csolutions.in";
  static _AuthEndPoints authEndpoints = _AuthEndPoints();
}

class _AuthEndPoints {
  final String registerEmail = '';
  final String loginEmail = '/api/method/logistics.api.login';
  final String employee = '/api/resource/Employee';
  final String getList = '/api/method/frappe.client.get_list';
  final String collectionRequestList = '/api/resource/Collection Request';
  final String collectionAssignmentList = '/api/resource/Collection Assignment';
  final String lrList = '/api/resource/LR';
  final String gdmList = '/api/resource/GDM';
  final String createCollectionRequest = '/api/resource/Collection Request';
}
