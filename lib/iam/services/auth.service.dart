import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';

class AuthService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8001/api/v1';
  final String resourceEndPoint = '/authentication';

  Future<Map<String, dynamic>> logIn(String email, String password) async {
  print("Base URL: $baseUrl");
    final uri = Uri.parse('$baseUrl$resourceEndPoint/sign-in');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error signing in: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> singUp(Map<String, dynamic> userData) async {
    final uri = Uri.parse('$baseUrl$resourceEndPoint/sign-up/driver');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(userData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error signing up: ${response.body}');
    }
  }
}