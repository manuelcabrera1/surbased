import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MailService {
  final _baseUrl = 'http://192.168.1.69:8000/mail';

  Future<Map<String, dynamic>> sendForgotPasswordMail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(utf8.decode(response.bodyBytes))};
      } 
      else if (response.statusCode == 404) {
        return {'success': false, 'data': 'User not found'};
      }
      else {
        return {'success': false, 'data': json.decode(utf8.decode(response.bodyBytes))};
      }
    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }

  Future<Map<String, dynamic>> sendSurveyInvitationMail(String email, String surveyName, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/survey-invitation'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode({'email': email, 
        'survey_name': surveyName, 
        'survey_url': dotenv.env['APK_URL']}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(utf8.decode(response.bodyBytes))};
      }
      else {
        return {'success': false, 'data': json.decode(utf8.decode(response.bodyBytes))};
      }
    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }
}
