import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8001/api/v1';
  String? _token;
  String? resourceEndPoint;

  Future<String?> getToken() async {
    if (_token != null) return _token;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> get() async {
    final uri = Uri.parse('$baseUrl$resourceEndPoint');
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);
    print(response.statusCode);

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 404) {
      print('No data available');
      return [];
    } else {
      throw Exception('Error loading data: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> post(Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$resourceEndPoint');
    final headers = await _getHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: utf8.encode(json.encode(data)),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(
        utf8.decode(response.bodyBytes),
      );
    } else {
      throw Exception('Error posting data: ${response.reasonPhrase}');
    }
  }
}
