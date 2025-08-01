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

  // ========== NEUE PROFIL-FUNKTIONEN ==========

  // Profil aktualisieren
  static Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Nicht eingeloggt',
        };
      }

      final response = await http.put(
        Uri.parse(ApiConstants.updateProfile), // ← KORRIGIERT
        headers: {
          ...ApiConstants.headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (email != null) 'email': email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Aktualisierte User-Daten speichern
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));
        
        return {
          'success': true,
          'user': User.fromJson(data['user']),
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Profil-Update fehlgeschlagen',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Email-Verifizierung senden
  static Future<Map<String, dynamic>> sendEmailVerification() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Nicht eingeloggt',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConstants.sendVerification), // ← KORRIGIERT
        headers: {
          ...ApiConstants.headers,
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Bestätigungs-Email wurde gesendet',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Email-Versendung fehlgeschlagen',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Email-Verifizierung bestätigen
  static Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyEmail), // ← KORRIGIERT
        headers: ApiConstants.headers,
        body: jsonEncode({
          'token': token,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // User-Daten aktualisieren falls vorhanden
        if (data['user'] != null) {
          await _storage.write(key: _userKey, value: jsonEncode(data['user']));
        }
        
        return {
          'success': true,
          'message': data['message'] ?? 'Email erfolgreich bestätigt',
          'user': data['user'] != null ? User.fromJson(data['user']) : null,
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Verifizierung fehlgeschlagen',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Passwort ändern
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Nicht eingeloggt',
        };
      }

      final response = await http.put(
        Uri.parse(ApiConstants.changePassword), // ← KORRIGIERT
        headers: {
          ...ApiConstants.headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Passwort erfolgreich geändert',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Passwort-Änderung fehlgeschlagen',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Aktualisierte User-Daten vom Server abrufen
  static Future<User?> refreshUserData() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConstants.profile), // ← KORRIGIERT
        headers: {
          ...ApiConstants.headers,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        
        // Lokale Daten aktualisieren
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));
        
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ========== BESTEHENDE FUNKTIONEN ==========

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