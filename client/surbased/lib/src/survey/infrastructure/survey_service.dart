import 'dart:convert';

import 'package:http/http.dart' as http;

class SurveyService {
  final String _baseUrl = 'http://10.0.2.2:8000';

  Future<Map<String, dynamic>> getSurveys(
      String token, String? category) async {
    try {
      final existingCategory = category != null ? '?category=$category' : '';
      final response = await http
          .get(Uri.parse('$_baseUrl/surveys$existingCategory'), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'data': json.decode(response.body)['detail']};
      }
    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getSurveysParticipant(
      String userId, String token, String? category) async {
    try {
      final existingCategory = category != null ? '?category=$category' : '';
      final response = await http.get(
          Uri.parse('$_baseUrl/participants/$userId/surveys$existingCategory'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          });

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'data': json.decode(response.body)['detail']};
      }
    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }
}
