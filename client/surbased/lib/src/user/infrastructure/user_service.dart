import 'dart:convert';

import 'package:http/http.dart' as http;

class UserService {
  final String _baseUrl = 'http://10.0.2.2:8000/users';

  Future<Map<String, dynamic>> updateUser(String id, String name,
      String lastname, String email, String birthdate, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'lastname': lastname,
          'email': email,
          'birthdate': birthdate,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'data': json.decode(response.body)['detail']};
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
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'data': json.decode(response.body)['detail']};
      }
    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }
}
