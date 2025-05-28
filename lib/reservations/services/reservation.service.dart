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
}