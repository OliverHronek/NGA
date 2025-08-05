import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';

class ApiService {
  // Create HTTP client with web-specific configuration
  static http.Client _createClient() {
    if (kIsWeb) {
      // For web, we need to handle CORS differently
      return http.Client();
    }
    return http.Client();
  }

  // API Health Check
  static Future<bool> testConnection() async {
    final client = _createClient();
    try {
      final response = await client.get(
        Uri.parse('http://5.104.107.253:3000/health'),
        headers: {
          ...ApiConstants.headers,
          if (kIsWeb) 'Access-Control-Allow-Origin': '*',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('API Response: ${response.statusCode}');
      print('API Body: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('API Connection Error: $e');
      return false;
    } finally {
      client.close();
    }
  }

  // Generic GET Request
  static Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    final client = _createClient();
    try {
      final headers = {
        ...(token != null ? ApiConstants.authHeaders(token) : ApiConstants.headers),
        if (kIsWeb) 'Access-Control-Allow-Origin': '*',
      };

      final response = await client.get(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

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
    } finally {
      client.close();
    }
  }

  // Generic POST Request
  static Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> body, 
    {String? token}
  ) async {
    final client = _createClient();
    try {
      final headers = {
        ...(token != null ? ApiConstants.authHeaders(token) : ApiConstants.headers),
        if (kIsWeb) 'Access-Control-Allow-Origin': '*',
      };

      final response = await client.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

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
    } finally {
      client.close();
    }
  }

  // Generic PUT Request
  static Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> body, 
    {required String token}
  ) async {
    final client = _createClient();
    try {
      final headers = {
        ...ApiConstants.authHeaders(token),
        if (kIsWeb) 'Access-Control-Allow-Origin': '*',
      };

      final response = await client.put(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

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
    } finally {
      client.close();
    }
  }

  // Generic DELETE Request
  static Future<Map<String, dynamic>> delete(
    String endpoint, 
    {required String token}
  ) async {
    final client = _createClient();
    try {
      final headers = {
        ...ApiConstants.authHeaders(token),
        if (kIsWeb) 'Access-Control-Allow-Origin': '*',
      };

      final response = await client.delete(
        Uri.parse(endpoint),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

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
    } finally {
      client.close();
    }
  }
}