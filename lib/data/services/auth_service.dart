import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';
import 'dart:async';  // ← FEHLT für TimeoutException

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'nga_auth_token';
  static const String _userKey = 'nga_user_data';

  // HTTP Client mit erweiterten Konfigurationen
  static http.Client _getHttpClient() {
    final client = http.Client();
    return client;
  }

  // Alternative: HttpClient mit DNS-Konfiguration
  static HttpClient _createHttpClient() {
    final client = HttpClient();
    
    // DNS-Timeout erhöhen
    client.connectionTimeout = const Duration(seconds: 10);
    
    // SSL-Probleme umgehen (nur für Debugging)
    client.badCertificateCallback = (cert, host, port) {
      // Nur für nextgenerationaustria.at erlauben
      return host == 'nextgenerationaustria.at';
    };
    
    return client;
  }

  // Login mit verbesserter Fehlerbehandlung
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Nur bei remote server testen
      if (!ApiConstants.baseUrl.contains('localhost')) {
        await _testConnection();
      }
      
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: ApiConstants.headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15)); // Längerer Timeout

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // DEBUG: Log the actual server response
        print('=== SERVER LOGIN RESPONSE ===');
        print('Full response: $data');
        print('User data: ${data['user']}');
        print('User first_name: ${data['user']?['first_name']}');
        print('User last_name: ${data['user']?['last_name']}');
        print('=============================');
        
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
    } on SocketException catch (e) {
      return {
        'success': false,
        'error': 'DNS-Fehler: Server nicht erreichbar. Prüfe deine Internetverbindung.',
      };
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'error': 'Timeout: Server antwortet nicht rechtzeitig.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Verbindungstest
  static Future<void> _testConnection() async {
    try {
      final result = await InternetAddress.lookup('nextgenerationaustria.at');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('DNS Lookup erfolgreich: ${result[0].address}');
      }
    } catch (e) {
      print('DNS Lookup fehlgeschlagen: $e');
      throw SocketException('DNS-Auflösung fehlgeschlagen für nextgenerationaustria.at');
    }
  }

  // Registrierung mit verbesserter Fehlerbehandlung
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      await _testConnection();
      
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
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
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
    } on SocketException catch (e) {
      return {
        'success': false,
        'error': 'DNS-Fehler: Server nicht erreichbar. Prüfe deine Internetverbindung.',
      };
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'error': 'Timeout: Server antwortet nicht rechtzeitig.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  // Alle anderen Methoden bleiben gleich...
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
        Uri.parse(ApiConstants.updateProfile),
        headers: {
          ...ApiConstants.headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (email != null) 'email': email,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
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
    } on SocketException catch (e) {
      return {
        'success': false,
        'error': 'Verbindung fehlgeschlagen. Prüfe deine Internetverbindung.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

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
        Uri.parse(ApiConstants.sendVerification),
        headers: {
          ...ApiConstants.headers,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

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
    } on SocketException catch (e) {
      return {
        'success': false,
        'error': 'Verbindung fehlgeschlagen. Prüfe deine Internetverbindung.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyEmail),
        headers: ApiConstants.headers,
        body: jsonEncode({
          'token': token,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
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
    } on SocketException catch (e) {
      return {
        'success': false,
        'error': 'Verbindung fehlgeschlagen. Prüfe deine Internetverbindung.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

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
        Uri.parse(ApiConstants.changePassword),
        headers: {
          ...ApiConstants.headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 15));

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
    } on SocketException catch (e) {
      return {
        'success': false,
        'error': 'Verbindung fehlgeschlagen. Prüfe deine Internetverbindung.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Verbindungsfehler: $e',
      };
    }
  }

  static Future<User?> refreshUserData() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConstants.profile),
        headers: {
          ...ApiConstants.headers,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // DEBUG: Log the refresh response
        print('=== REFRESH USER DATA RESPONSE ===');
        print('User data: ${data['user']}');
        print('User first_name: ${data['user']?['first_name']}');
        print('User last_name: ${data['user']?['last_name']}');
        print('===================================');
        
        final user = User.fromJson(data['user']);
        
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));
        
        return user;
      }
      return null;
    } catch (e) {
      print('Error refreshing user data: $e');
      return null;
    }
  }

  // Bestehende Hilfsmethoden
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<User?> getUser() async {
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    return await _storage.delete(key: _userKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}