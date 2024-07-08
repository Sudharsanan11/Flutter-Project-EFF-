import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';


class ApiService {

  Future<List<Map<String, String>>> getresources(String resource) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String api = manager.getString("api")!;
    String secret = manager.getString("secret")!;
    final response = await http.get(
      Uri.parse(ApiEndpoints.baseUrl+resource),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'token $api:$secret',
      },
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> data = jsonResponse['data'];
      print("dynamic");
      print(data);
      List<String> keys = data.first.keys.toList();
      print(keys[0]);
      return data.map((item) => {
        'key1' : item[keys[0]].toString(),
        'key2' : item[keys[1]].toString(),
      }).toList();
    }
    else {
      throw Exception('Failed to load resources');
    }
  }
}

