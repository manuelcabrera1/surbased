import 'dart:convert';

import 'package:http/http.dart' as http;

class CategoryService {
  final String _baseUrl = 'http://10.0.2.2:8000/categories';

  Future<Map<String, dynamic>> getCategories(
      String? organizationId, String token) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/categories/'), headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'data': json.decode(response.body)['detail'],
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
