import 'dart:convert';

import 'package:http/http.dart' as http;


class ApiService {
  // final String baseurl = dotenv.env['API_BASE_URL']!;
  // final String apikey = dotenv.env['API_KEY']!;
  // final String apisecret = dotenv.env['API_SECRET']!;
  final String baseurl = "http://192.168.1.18:8003";
  final String apikey = "942e5fd49c7af84";
  final String apiSecret = "87d8de62bc1b513";

  Future<Map<String, dynamic>> getresources(String resource) async {
    final response = await http.get(
      Uri.parse(baseurl+resource),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'token $apikey:$apiSecret',
      },
    );
    if(response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    else {
      throw Exception('Failed to load resources');
    }
  }
}

