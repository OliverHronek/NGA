import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class WebApiService {
  static late Dio _dio;
  
  static void initialize() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptor for debugging
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ));
    }
  }

  // API Health Check
  static Future<bool> testConnection() async {
    try {
      final response = await _dio.get('http://5.104.107.253:3000/health');
      print('API Response: ${response.statusCode}');
      print('API Body: ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      print('API Connection Error: $e');
      return false;
    }
  }

  // Generic GET Request
  static Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _dio.get(endpoint, options: options);

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': response.statusCode == 200 ? response.data : null,
        'error': null,
      };
    } on DioException catch (e) {
      return _handleDioError(e);
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
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _dio.post(endpoint, data: body, options: options);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': (response.statusCode == 200 || response.statusCode == 201) ? response.data : null,
        'error': null,
      };
    } on DioException catch (e) {
      return _handleDioError(e);
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
      final options = Options(
        headers: {'Authorization': 'Bearer $token'},
      );

      final response = await _dio.put(endpoint, data: body, options: options);

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': response.statusCode == 200 ? response.data : null,
        'error': null,
      };
    } on DioException catch (e) {
      return _handleDioError(e);
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
      final options = Options(
        headers: {'Authorization': 'Bearer $token'},
      );

      final response = await _dio.delete(endpoint, options: options);

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': response.statusCode == 200 ? response.data : null,
        'error': null,
      };
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'statusCode': 0,
        'data': null,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  static Map<String, dynamic> _handleDioError(DioException e) {
    String errorMessage;
    int statusCode = e.response?.statusCode ?? 0;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Verbindungstimeout';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Sende-Timeout';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Empfangs-Timeout';
        break;
      case DioExceptionType.badResponse:
        errorMessage = e.response?.data?['error'] ?? 'Server Fehler';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Anfrage abgebrochen';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Verbindungsfehler - Prüfen Sie Ihre Internetverbindung';
        break;
      default:
        errorMessage = 'Unbekannter Fehler: ${e.message}';
    }

    return {
      'success': false,
      'statusCode': statusCode,
      'data': null,
      'error': errorMessage,
    };
  }
}
