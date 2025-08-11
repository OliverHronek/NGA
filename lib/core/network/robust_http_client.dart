// lib/core/network/robust_http_client.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class RobustHttpClient {
  static final Duration _timeout = Duration(seconds: 30);
  
  static http.Client _getClient() {
    final client = http.Client();
    
    // Set User-Agent for Android
    if (Platform.isAndroid) {
      // No need for custom overrides - use standard http client
    }
    
    return client;
  }

  static Future<String> get(String url, {Map<String, String>? headers}) async {
    final client = _getClient();
    
    try {
      // Try with provided URL first
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'NGA Political App/1.0 (Android)',
          ...?headers,
        },
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
        return response.body;
      }
      
      throw HttpException('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      
    } on SocketException catch (e) {
      // Try fallback if available
      if (url.contains(ApiConstants.baseUrl)) {
        final fallbackUrl = url.replaceFirst(ApiConstants.baseUrl, ApiConstants.fallbackBaseUrl);
        
        try {
          final response = await client.get(
            Uri.parse(fallbackUrl),
            headers: {
              'User-Agent': 'NGA Political App/1.0 (Android)',
              ...?headers,
            },
          ).timeout(_timeout);
          
          if (response.statusCode == 200) {
            return response.body;
          }
        } catch (fallbackError) {
          // Fall through to original error
        }
      }
      
      throw SocketException('Connection failed: ${e.message}');
    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }
  }

  static Future<String> post(String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final client = _getClient();
    
    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'User-Agent': 'NGA Political App/1.0 (Android)',
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: body,
        encoding: encoding,
      ).timeout(_timeout);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      }
      
      throw HttpException('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      
    } on SocketException catch (e) {
      // Try fallback if available
      if (url.contains(ApiConstants.baseUrl)) {
        final fallbackUrl = url.replaceFirst(ApiConstants.baseUrl, ApiConstants.fallbackBaseUrl);
        
        try {
          final response = await client.post(
            Uri.parse(fallbackUrl),
            headers: {
              'User-Agent': 'NGA Political App/1.0 (Android)',
              'Content-Type': 'application/json',
              ...?headers,
            },
            body: body,
            encoding: encoding,
          ).timeout(_timeout);
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            return response.body;
          }
        } catch (fallbackError) {
          // Fall through to original error
        }
      }
      
      throw SocketException('Connection failed: ${e.message}');
    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }
  }
}
