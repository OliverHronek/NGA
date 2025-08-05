import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'web_api_service.dart';

/// Adaptive API service that automatically chooses the best implementation
/// based on the platform (web vs mobile)
class AdaptiveApiService {
  /// Generic GET Request
  static Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    if (kIsWeb) {
      return await WebApiService.get(endpoint, token: token);
    } else {
      return await ApiService.get(endpoint, token: token);
    }
  }

  /// Generic POST Request
  static Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> body, 
    {String? token}
  ) async {
    if (kIsWeb) {
      return await WebApiService.post(endpoint, body, token: token);
    } else {
      return await ApiService.post(endpoint, body, token: token);
    }
  }

  /// Generic PUT Request
  static Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> body, 
    {required String token}
  ) async {
    if (kIsWeb) {
      return await WebApiService.put(endpoint, body, token: token);
    } else {
      return await ApiService.put(endpoint, body, token: token);
    }
  }

  /// Generic DELETE Request
  static Future<Map<String, dynamic>> delete(
    String endpoint, 
    {required String token}
  ) async {
    if (kIsWeb) {
      return await WebApiService.delete(endpoint, token: token);
    } else {
      return await ApiService.delete(endpoint, token: token);
    }
  }

  /// Test connection - works on both platforms
  static Future<bool> testConnection() async {
    if (kIsWeb) {
      return await WebApiService.testConnection();
    } else {
      return await ApiService.testConnection();
    }
  }
}
