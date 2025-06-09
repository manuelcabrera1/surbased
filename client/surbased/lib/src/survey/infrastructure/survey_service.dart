import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:surbased/src/survey/domain/answer_model.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

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

      print(response.body); 

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

  Future<Map<String, dynamic>> updateSurvey(
      Map<String, dynamic> survey, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/surveys/${survey['id']}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(survey),
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

  Future<Map<String, dynamic>> getSurveysByScope(String scope, String token) async {
    try {
      final scopeQuery = '?scope=$scope';
      final response = await http
          .get(Uri.parse('$_baseUrl/surveys/$scopeQuery'), headers: {
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


  Future<Map<String, dynamic>> getHighlightedPublicSurveys(String token) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/surveys/public/highlighted'), headers: {
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

  Future<Map<String, dynamic>> getSurveysByOwner(String ownerId, String token, {bool? includeFinished}) async {
    try {
      final existsIncludeFinished = includeFinished != null ? '?includeFinished=$includeFinished' : '';
      final response = await http
          .get(Uri.parse('$_baseUrl/surveys/owner/$ownerId$existsIncludeFinished'), headers: {
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

  

  Future<Map<String, dynamic>> getUsersAssignedToSurvey(
      String surveyId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/surveys/$surveyId/users'),
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

  Future<Map<String, dynamic>> removeSurvey(String surveyId, String token ) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/surveys/$surveyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        return {'success': true, 'data': 'Survey removed successfully'};
      } else {
        return {'success': false, 'data': 'Failed to remove survey'};
      }
    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getSurveyAnswers(String surveyId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/surveys/$surveyId/answers'),
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

  Future<Map<String, dynamic>> addUserToSurvey(String surveyId, String email, String token, String notificationTitle, String notificationBody) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/surveys/$surveyId/users/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': email, 'notification_title': notificationTitle, 'notification_body': notificationBody}),
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

  Future<Map<String, dynamic>> requestSurveyAccess(String surveyId, String userId, String notificationTitle, String notificationBody, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/surveys/$surveyId/users/$userId/request'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: json.encode({'notification_title': notificationTitle, 'notification_body': notificationBody}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(utf8.decode(response.bodyBytes))};
      } else {
        return {'success': false, 'data': json.decode(utf8.decode(response.bodyBytes))['detail']};
      }
    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }
}
