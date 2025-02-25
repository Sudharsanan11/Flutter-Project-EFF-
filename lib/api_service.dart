import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';


class ApiService {

  Future<List<Map<String, String>>> getresources(String resource) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;
    print(sid);
    final response = await http.get(
      Uri.parse(ApiEndpoints.baseUrl+resource),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',
      },
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('$jsonResponse 000000000000000000000000000000000');
      List<dynamic> data = jsonResponse['data'];
      print("dynamic");
      print(data);
      List<String> keys = data.first.keys.toList();
      print(keys[0]);
      return data.map((item) => {
        'key1' : item[keys[0]].toString(),
        'key2' : item[keys[1]].toString(),
        'key3' : item[keys[2]].toString().split(" ")[0],
        'key4' : item[keys[3]].toString(),
      }).toList();
    }
    else {
      throw Exception('Failed to load resources');
    }
  }

 Future<List<Map<String, String>>> getresource(String resource, Object body) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;
    print(sid);
    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl+resource),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('$jsonResponse 000000000000000000000000000000000');
      List<dynamic> data = jsonResponse['message'];
      print("dynamic");
      print(data);
      List<String> keys = data.first.keys.toList();
      print(keys[0]);
      return data.map((item) => {
        'key1' : item[keys[0]].toString(),
        'key2' : item[keys[1]].toString(),
        'key3' : item[keys[2]].toString().split(" ")[0],
        'key4' : item[keys[3]].toString(),
      }).toList();
    }
    else {
      throw Exception('Failed to load resources');
    }
  }

  Future<Map<String, dynamic>> getDocument (String endpoint) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;
    final response = await http.get(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',
      },
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('$jsonResponse =====================++++++++++++++++=');
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
    String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;
    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl+resource),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',
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
    }
    else {
      throw Exception('Failed to load linked names');
    }
  }

  Future<List<Map<String,dynamic>>> getList(String endpoint, Object body) async{
    SharedPreferences manager = await SharedPreferences.getInstance();
   String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;
    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('$jsonResponse ===========================++++++++++++++++++++++++++++++++');
      List<dynamic> res = jsonResponse['message']; 
      print("$res=======================================================json");
      List<Map<String,dynamic>> data = List<Map<String,dynamic>>.from(
        res.map((item) => item as Map<String, dynamic>)
      );
      print("$data ============================================================data");
      return data;
    }
    else { 
      throw Exception("Failed to fetch field data");
    }
  }


  Future<void> storetoken(String token) async{
    print("storetoken");
    SharedPreferences manager = await SharedPreferences.getInstance();
    // String api = manager.getString("api")!;
    // String secret = manager.getString("secret")!;
    String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;
    String email = manager.getString("email")!;
    Object body =  {
      "args" : {
        "usr": email,
        "token": token
      },
    };

    final endpoint = ApiEndpoints.authEndpoints.storeToken;

    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl + endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',

      },
      body: json.encode(body),
    );

    if(response.statusCode == 200){
      print("Token Stored Successfully!!");
    }
    else{
      throw Exception("Failed to Store Token");
    }
  }

  Future<Map<String, dynamic>> getDoc(String endpoint, Object body) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;
    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',
      },
      body: json.encode(body),
    );
    print("reponse +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ $response");
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("$jsonResponse=======================================================");
      Map<String, dynamic> data = jsonResponse['message'];
      print("$data ============================================================");
      return data;
    }
    else {
      print(response);
      throw Exception('Failed to fetch document');
    }
  }
  
  Future<bool> checkPermission(String endpoint, Object body) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;
    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("jsonResponse");
      print(jsonResponse);
      return jsonResponse['message'];
    }
    else {
      throw Exception('Failed to check permission');
    }
  }

  Future<List<dynamic>> fetchFieldData(String endpoint, Object body) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
   String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;
    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> data = jsonResponse['message'];
      // Map<String, Map<String, dynamic>> transformData = {};
      // for(var item in data) {
      //     var name = item['name'];
      //     transformData[name] = item;
      // }
      // print("$transformData transformData=========================");
      // return transformData;

      return data;
      
    }
    else {
      throw Exception('Error Code ${response.statusCode} ${response.body}');
    }
  }

  Future<List<dynamic>> createDocument(String endpoint, Object body) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;
    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      Map<String, dynamic> data = jsonResponse['data'];

      return [response.statusCode, data['name'].toString()];
    }
    else {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
    String exceptionMessage = errorResponse['exception'] ?? 'Unknown error';
      throw Exception("${response.statusCode}: $exceptionMessage");
    }
  }

  Future<String> updateDocument(String endpoint, Object body) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;
    final response = await http.put(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200) {
      return response.statusCode.toString();
    }
    else {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
    String exceptionMessage = errorResponse['exception'] ?? 'Unknown error';
    print("$errorResponse errrrrrrrrrrrrrrrrrrrrrrrrrrrorrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr");
      throw Exception("${response.statusCode}: $exceptionMessage");
    }
  }

  Future<String> updateStatus(String endpoint, Object body) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;
    final response = await http.put(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',
      },
      body: json.encode(body),
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse['message'];
    }
    else {
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
    String exceptionMessage = errorResponse['exception'] ?? 'Unknown error';
    print("$errorResponse errrrrrrrrrrrrrrrrrrrrrrrrrrrorrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr");
      throw Exception("${response.statusCode}: $exceptionMessage");
    }
  }

  Future<String> deleteDocument(String endpoint) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
   String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;
    final response = await http.delete(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',
      },
    );
    if(response.statusCode == 202) {
      return response.statusCode.toString();
    }
    else{
      Map<String, dynamic> errorResponse = jsonDecode(response.body);
    String exceptionMessage = errorResponse['exception'] ?? 'Unknown error';
      throw Exception("${response.statusCode}: $exceptionMessage");
    }
  }

  Future<Map<String, dynamic>> updateLocation(String endpoint, Object body) async {
    print(body);
    SharedPreferences manager = await SharedPreferences.getInstance();
    String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;

    final response  = await http.post(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',
      },
      body: json.encode(body),
    );

    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("$jsonResponse=======================================================");
      Map<String, dynamic> data = jsonResponse['message'];
      print("$data ============================================================");
      return data;
    }
    else {
      throw "$response";
    }
  }
   Future<Map<String, dynamic>> get_session(String endpoint) async {
    SharedPreferences manager = await SharedPreferences.getInstance();
    String sid = manager.getString("sid")!;
    String cookies = manager.getString("cookies")!;
    // Object body = {
    //   'usr': 'sudharsanan@aerele.in',
    //   'pwd': 'admin@123'
    // };
    final response  = await http.post(
      Uri.parse(ApiEndpoints.baseUrl+endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'sid=$sid; $cookies',
      },
    );

    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("$jsonResponse=======================================================");
      String? cookies = response.headers['set-cookie'];
    print('Cookies: $cookies');
      // Map<String, dynamic> data = jsonResponse['message'];
      // print("$data ============================================================");
      // return data;
      return jsonResponse;
    }
    else {
      throw "Password Mismatched";
    }
  }
}
