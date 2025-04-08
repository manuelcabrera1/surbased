import 'dart:convert';

import 'package:http/http.dart' as http;

class TagService {
  final String _baseUrl = 'http://192.168.1.69:8000';

  Future<Map<String, dynamic>> getTags(String token) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/tags'), headers: {
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

  

}
