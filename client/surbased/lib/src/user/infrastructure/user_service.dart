import 'dart:convert';

import 'package:http/http.dart' as http;

class UserService {
  final String _baseUrl = 'http://10.0.2.2:8000/users';

  Future<Map<String, dynamic>> getUserById(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$userId'),
        headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(utf8.decode(response.bodyBytes))};
    } else {
      return {'success': false, 'data': jsonDecode(utf8.decode(response.bodyBytes))};
    }
    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getUserByEmail(String email, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/?email=$email'),
        headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(utf8.decode(response.bodyBytes))};
    } else {
      return {'success': false, 'data': jsonDecode(utf8.decode(response.bodyBytes))};
    }
    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }
  
  Future<Map<String, dynamic>> getUsers(
      String token, String? org, String? role) async {
    try {
      final existingOrg = org != null ? '?organization=$org' : '';
      final existingRole = role != null ? '?role=$role' : '';
      final response = await http.get(
        Uri.parse('$_baseUrl$existingOrg$existingRole'),
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
}
