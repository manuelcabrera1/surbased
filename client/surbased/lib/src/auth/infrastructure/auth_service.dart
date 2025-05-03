import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  final _baseUrl = 'http://192.168.1.69:8000/users';

  Future<Map<String, dynamic>> register(
      String name,
      String lastname,
      String role,
      String organization,
      String email,
      String password,
      String birthdate,
      String gender) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'lastname': lastname,
          'organization': organization,
          'email': email,
          'password': password,
          'role': role,
          'birthdate': birthdate,
          'gender': gender,
        }),
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

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': email,
          'password': password,
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

  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {'Authorization': 'Bearer $token'},
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

  Future<void> logout() async {
    try {
      final response = await http.post(Uri.parse('$_baseUrl/logout'));
      if (response.statusCode != 200) {
        throw Exception('Error al cerrar sesión');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> updateUser(String id, String token, {String? name,
      String? lastname, String? role, String? organization, String? email, String? birthdate, String? gender}) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          if (name != null) 'name': name,
          if (lastname != null) 'lastname': lastname,
          if (role != null) 'role': role,
          if (organization != null) 'organization': organization,
          if (email != null) 'email': email,
          if (birthdate != null) 'birthdate': birthdate,
          if (gender != null) 'gender': gender,
        }),
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

  Future<Map<String, dynamic>> updateUserPassword(
      String id, String password, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'password': password,
        }),
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

  Future<Map<String, dynamic>> updateUserNotifications(
      String id, bool notifications, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'allow_notifications': notifications,
        }),
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

  Future<Map<String, dynamic>> resetUserPassword(
      String email, String password) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/reset-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
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

  

  Future<Map<String, dynamic>> getSurveysAssignedToUser(
      String userId, String token, {String? category}) async {
    try {
      final existingCategory = category != null ? '?category=$category' : '';
      final response = await http.get(
          Uri.parse('$_baseUrl/$userId/surveys$existingCategory'),
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

  Future<Map<String, dynamic>> acceptSurveyAssignment(String userId, String surveyId, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$userId/surveys/$surveyId/accept'),
        headers: {'Authorization': 'Bearer $token'},
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

  Future<Map<String, dynamic>> rejectSurveyAssignment(String userId, String surveyId, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$userId/surveys/$surveyId/reject'),
        headers: {'Authorization': 'Bearer $token'},
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

  Future<Map<String, dynamic>> deleteUser(String id, String? password, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: json.encode({if (password != null) 'password': password})
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(utf8.decode(response.bodyBytes))};
      } 
      else if (response.statusCode == 401) {
        return {'success': false, 'data': json.decode(utf8.decode(response.bodyBytes))['detail']};
      }
      else {
        return {'success': false, 'data': json.decode(utf8.decode(response.bodyBytes))['detail']};
      }


    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }

}
