import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class ApiService {
  // API Health Check
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('http://5.104.107.253:3000/health'),
        headers: ApiConstants.headers,
      );
      
      print('API Response: ${response.statusCode}');
      print('API Body: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('API Connection Error: $e');
      return false;
    }
  }

  // Generic GET Request
  static Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    try {
      final headers = token != null 
        ? ApiConstants.authHeaders(token)
        : ApiConstants.headers;

      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': response.statusCode == 200 ? jsonDecode(response.body) : null,
        'error': response.statusCode != 200 ? jsonDecode(response.body)['error'] : null,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 0,
        'data': null,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Generic POST Request
  static Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> body, 
    {String? token}
  ) async {
    try {
      final headers = token != null 
        ? ApiConstants.authHeaders(token)
        : ApiConstants.headers;

      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': (response.statusCode == 200 || response.statusCode == 201) ? responseData : null,
        'error': (response.statusCode != 200 && response.statusCode != 201) ? responseData['error'] : null,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 0,
        'data': null,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Generic PUT Request
  static Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> body, 
    {required String token}
  ) async {
    try {
      final response = await http.put(
        Uri.parse(endpoint),
        headers: ApiConstants.authHeaders(token),
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': response.statusCode == 200 ? responseData : null,
        'error': response.statusCode != 200 ? responseData['error'] : null,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 0,
        'data': null,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Generic DELETE Request
  static Future<Map<String, dynamic>> delete(
    String endpoint, 
    {required String token}
  ) async {
    try {
      final response = await http.delete(
        Uri.parse(endpoint),
        headers: ApiConstants.authHeaders(token),
      );

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': response.statusCode == 200 ? jsonDecode(response.body) : null,
        'error': response.statusCode != 200 ? jsonDecode(response.body)['error'] : null,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 0,
        'data': null,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }
}