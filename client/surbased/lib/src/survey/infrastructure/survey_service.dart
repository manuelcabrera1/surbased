import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:surbased/src/survey/domain/answer_model.dart';

class SurveyService {
  final String _baseUrl = 'http://10.0.2.2:8000';

  Future<Map<String, dynamic>> createSurvey(
      Map<String, dynamic> survey, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/surveys'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(survey),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(utf8.decode(response.bodyBytes)),
        };
      } else {
        return {
          'success': false,
          'data': json.decode(utf8.decode(response.bodyBytes))['detail']
        };
      }
    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getSurveys(
      String token, String? org, String? category) async {
    try {
      final existingCategory = category != null ? '?category=$category' : '';
      final response = await http
          .get(Uri.parse('$_baseUrl/surveys$existingCategory'), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(utf8.decode(response.bodyBytes)),
        };
      } else {
        return {
          'success': false,
          'data': json.decode(utf8.decode(response.bodyBytes))['detail']
        };
      }
    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getParticipantSurveys(
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
        return {
          'success': true,
          'data': json.decode(utf8.decode(response.bodyBytes)),
        };
      } else {
        return {
          'success': false,
          'data': json.decode(utf8.decode(response.bodyBytes))['detail']
        };
      }
    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getSurveyParticipants(
      String surveyId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/surveys/$surveyId/participants'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(utf8.decode(response.bodyBytes)),
        };
      } else {
        return {
          'success': false,
          'data': json.decode(utf8.decode(response.bodyBytes))['detail']
        };
      }
    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }
  
  Future<Map<String, dynamic>> registerSurveyAnswers(
      String surveyId, Answer answer, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/surveys/$surveyId/answers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(answer),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(utf8.decode(response.bodyBytes)),
        };
      } else {
        return {
          'success': false,
          'data': json.decode(utf8.decode(response.bodyBytes))['detail']
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': e.toString(),
      };
    }
  }
}
