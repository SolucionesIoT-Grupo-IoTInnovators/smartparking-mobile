import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smartparking_mobile_application/shared/services/http-common.dart';

class ReservationService extends ApiClient {
  ReservationService() {
    resourceEndPoint = '/reservations';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> createReservationPayment(Map<String, dynamic> data, int reservationId) async {
    final uri = Uri.parse('$baseUrl/payments/reservation/$reservationId');
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