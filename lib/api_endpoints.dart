class ApiEndpoints {
  static const String baseUrl = "http://192.168.1.19:8003";
  static _AuthEndPoints authEndpoints = _AuthEndPoints();
}

class _AuthEndPoints {
  final String registerEmail = '';
  final String loginEmail = '/api/method/logistics.api.login';
  final String employee = '/api/resource/Employee';
  final String collectionRequestList = '/api/resource/Collection Request';
  final String collectionAssignmentList = '/api/resource/Collection Assignment';
  final String lrList = '/api/resource/LR';
  final String gdmList = '/api/resource/GDM';
}