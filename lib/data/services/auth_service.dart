import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'nga_auth_token';
  static const String _userKey = 'nga_user_data';

  // Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: ApiConstants.headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Token und User-Daten speichern
        await _storage.write(key: _tokenKey, value: data['token']);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));
        
        return {
          'success': true,
          'user': User.fromJson(data['user']),
          'token': data['token'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Login fehlgeschlagen',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Registrierung
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: ApiConstants.headers,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Token und User-Daten speichern
        await _storage.write(key: _tokenKey, value: data['token']);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));
        
        return {
          'success': true,
          'user': User.fromJson(data['user']),
          'token': data['token'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Registrierung fehlgeschlagen',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Gespeicherten Token abrufen
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Gespeicherte User-Daten abrufen
  static Future<User?> getUser() async {
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Logout
  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // Prüfen ob eingeloggt
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}