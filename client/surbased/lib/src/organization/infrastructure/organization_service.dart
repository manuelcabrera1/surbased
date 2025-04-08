import 'dart:convert';

import 'package:http/http.dart' as http;

class OrganizationService {
  final String _baseUrl = 'http://192.168.1.69:8000/organizations';

  Future<Map<String, dynamic>> createOrganization(String name, String token) async {
    try {
      final response = await http.post(Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: json.encode({'name': name}));

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(utf8.decode(response.bodyBytes)),
        };
      } else {
        return {
          'success': false,
          'data': json.decode(utf8.decode(response.bodyBytes))['detail'],
        };
      }
    } catch (e) {
      return {'success': false, 'data': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getOrganizations(String token) async {
    try {
      final response = await http.get(Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          });


      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(utf8.decode(response.bodyBytes)),
        };
      } else {
        return {
          'success': false,
          'data': json.decode(utf8.decode(response.bodyBytes))['detail'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getOrganizationById(
      String id, String token) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          });

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(utf8.decode(response.bodyBytes)),
        };
      } else {
        return {
          'success': false,
          'data': json.decode(utf8.decode(response.bodyBytes))['detail'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getUsersInCurrentOrganization(
      String token, String organizationId,
      {String? sortBy, String? order}) async {
    try {
      String sortByExists = sortBy != null ? '?sortBy=$sortBy' : '';
      String orderExists = order != null ? '&order=$order' : '';
      final response = await http.get(
        Uri.parse('$_baseUrl/$organizationId/users$sortByExists$orderExists'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
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

  Future<Map<String, dynamic>> getSurveysInOrganization(
      String orgId, String token, {String? category}) async {
    try {
      final existingCategory = category != null ? '?category=$category' : '';
      final response = await http
          .get(Uri.parse('$_baseUrl/$orgId/surveys$existingCategory'), headers: {
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
