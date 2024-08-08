import 'dart:async';
import 'dart:convert';
import 'package:erpnext_logistics_mobile/modules/app_drawer.dart';
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

  Future<Map<String, dynamic>> getDocument (String endpoint) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String api = manager.getString("api")!;
    String secret = manager.getString("secret")!;
    final response = await http.get(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'token $api:$secret',
      },
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      Map<String, dynamic> data = jsonResponse['data'];
      print("data======================== $data");
      return data;
    }
    else {
      throw Exception('Failed to load document');
    }
  }

  Future<List<String>> getLinkedNames(String resource, Object body) async {
    print(resource);
    print(body);
    SharedPreferences manager = await SharedPreferences.getInstance();
    String api = manager.getString("api")!;
    String secret = manager.getString("secret")!;
    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl+resource),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'token $api:$secret',
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> data = jsonResponse['message'];
      print("Consignor");
      print(data);
      List<String> list = data.map((item) => item['name'].toString()).toList();
      print("list");
      print(list);
      return list;
      // return data.map((item) => item['name']).toList();
    }
    else {
      throw Exception('Failed to load linked names');
    }
  }

  Future<List<dynamic>> getList(String endpoint, Object body) async{
    SharedPreferences manager = await SharedPreferences.getInstance();
    String api = manager.getString("api")!;
    String secret = manager.getString("secret")!;
    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'token $api:$secret',
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("$jsonResponse=======================================================");
      List<dynamic> data = jsonResponse['message'];
      print("${data} ============================================================");
      return data;
    }
    else { 
      throw Exception("Failed to fetch field data");
    }
  }

  Future<Map<String, dynamic>> getDoc(String endpoint, Object body) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String api = manager.getString("api")!;
    String secret = manager.getString("secret")!;
    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'token $api:$secret',
      },
      body: json.encode(body),
    );
    print("reponse +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ $response");
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("$jsonResponse=======================================================");
      Map<String, dynamic> data = jsonResponse['message'];
      print(data['loading_staffs']);
      print(data['items']);
      print("${data} ============================================================");
      return data;
    }
    else {
      throw Exception('Failed to fetch document');
    }
  }

  Future<Map<String, Map<String,dynamic>>> fetchFieldData(String endpoint, Object body) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String api = manager.getString("api")!;
    String secret = manager.getString("secret")!;
    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'token $api:$secret',
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> data = jsonResponse['message'];
      Map<String, Map<String, dynamic>> transformData = {};
      for(var item in data) {
          var name = item['name'];
          transformData[name] = item;
      }
      print("$transformData transformData=========================");
      return transformData;
    }
    else {
      throw Exception('Failed to fetch field data');
    }
  }

  Future<List<dynamic>> createDocument(String endpoint, Object body) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String api = manager.getString("api")!;
    String secret = manager.getString("secret")!;
    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'token $api:$secret',
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      Map<String, dynamic> data = jsonResponse['data'];

      return [response.statusCode, data['name'].toString()];
    }
    else {
      throw Exception('Failed to create document');
    }
  }

  Future<String> updateDocument(String endpoint, Object body) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String api = manager.getString("api")!;
    String secret = manager.getString("secret")!;
    final response = await http.put(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'token $api:$secret',
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200) {
      return response.statusCode.toString();
    }
    else {
      throw Exception('Failed to update document');
    }
  }

  Future<String> deleteDocument(String endpoint) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String api = manager.getString("api")!;
    String secret = manager.getString("secret")!;
    final response = await http.delete(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'token $api:$secret',
      },
    );
    if(response.statusCode == 202) {
      return response.statusCode.toString();
    }
    else{
      return response.statusCode.toString();
    }
  }
}

