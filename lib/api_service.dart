import 'dart:convert';

import 'package:http/http.dart' as http;


class ApiService {
  // final String baseurl = dotenv.env['API_BASE_URL']!;
  // final String apikey = dotenv.env['API_KEY']!;
  // final String apisecret = dotenv.env['API_SECRET']!;
  final String baseurl = "http://192.168.1.6:8003";
  final String apikey = "942e5fd49c7af84";
  final String apiSecret = "87d8de62bc1b513";

  Future<List<String>> getresources(String resource) async {
    final url = "http://192.168.1.6:8003";
    final response = await http.get(
      Uri.parse(baseurl+resource),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'token $apikey:$apiSecret',
      },
    );
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> data = jsonResponse['data'];
      print("dynamic");
      print(data);
      return data.map((item) => item['name'].toString()).toList();
    }
    else {
      throw Exception('Failed to load resources');
    }
  }
}

