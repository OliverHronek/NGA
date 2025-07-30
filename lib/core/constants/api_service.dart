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
}