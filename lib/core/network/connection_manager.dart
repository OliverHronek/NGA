import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ConnectionManager {
  static String? _activeBaseUrl;
  static bool _isInitialized = false;

  /// Initialisiert die beste verfügbare Verbindung
  static Future<String> getActiveBaseUrl() async {
    if (!_isInitialized) {
      await _initializeConnection();
      _isInitialized = true;
    }
    
    return _activeBaseUrl ?? ApiConstants.baseUrl;
  }

  /// Testet verschiedene Verbindungsoptionen und wählt die beste aus
  static Future<void> _initializeConnection() async {
    if (kIsWeb) {
      _activeBaseUrl = ApiConstants.baseUrl;
      return;
    }

    // Option 1: Versuche Standard Domain
    if (await _testUrl(ApiConstants.baseUrl)) {
      _activeBaseUrl = ApiConstants.baseUrl;
      print('✅ Domain Connection erfolgreich: ${ApiConstants.baseUrl}');
      return;
    }

    // Option 2: Versuche IP Fallback
    if (await _testUrl(ApiConstants.fallbackBaseUrl)) {
      _activeBaseUrl = ApiConstants.fallbackBaseUrl;
      print('✅ IP Fallback Connection erfolgreich: ${ApiConstants.fallbackBaseUrl}');
      return;
    }

    // Option 3: DNS Test
    try {
      final result = await InternetAddress.lookup('nextgenerationaustria.at');
      if (result.isNotEmpty) {
        final detectedIp = result[0].address;
        print('🔍 DNS resolved IP: $detectedIp');
        
        final dynamicUrl = 'https://$detectedIp/political-app-api';
        if (await _testUrl(dynamicUrl)) {
          _activeBaseUrl = dynamicUrl;
          print('✅ Dynamic IP Connection erfolgreich: $dynamicUrl');
          return;
        }
      }
    } catch (e) {
      print('❌ DNS Lookup fehlgeschlagen: $e');
    }

    // Fallback auf Standard URL
    _activeBaseUrl = ApiConstants.baseUrl;
    print('⚠️  Alle Tests fehlgeschlagen, verwende Standard URL: ${ApiConstants.baseUrl}');
  }

  /// Testet eine spezifische URL
  static Future<bool> _testUrl(String baseUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {
          ...ApiConstants.headers,
          if (baseUrl.contains('5.104.107.253')) 'Host': 'nextgenerationaustria.at',
        },
      ).timeout(const Duration(seconds: 8));
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ URL Test fehlgeschlagen für $baseUrl: $e');
      return false;
    }
  }

  /// Setzt die Initialisierung zurück (für Tests oder Neuverbindung)
  static void reset() {
    _isInitialized = false;
    _activeBaseUrl = null;
  }

  /// Erstellt eine HTTP GET Anfrage mit automatischem Fallback
  static Future<http.Response> get(String endpoint, {Map<String, String>? additionalHeaders}) async {
    final baseUrl = await getActiveBaseUrl();
    final headers = {
      ...ApiConstants.headers,
      if (additionalHeaders != null) ...additionalHeaders,
      if (baseUrl.contains('5.104.107.253')) 'Host': 'nextgenerationaustria.at',
    };

    try {
      return await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));
    } catch (e) {
      // Bei Fehler: Reset und nochmal versuchen
      reset();
      final fallbackUrl = await getActiveBaseUrl();
      final fallbackHeaders = {
        ...ApiConstants.headers,
        if (additionalHeaders != null) ...additionalHeaders,
        if (fallbackUrl.contains('5.104.107.253')) 'Host': 'nextgenerationaustria.at',
      };
      
      return await http.get(
        Uri.parse('$fallbackUrl$endpoint'),
        headers: fallbackHeaders,
      ).timeout(const Duration(seconds: 30));
    }
  }

  /// Erstellt eine HTTP POST Anfrage mit automatischem Fallback
  static Future<http.Response> post(String endpoint, {
    Map<String, String>? additionalHeaders,
    Object? body,
  }) async {
    final baseUrl = await getActiveBaseUrl();
    final headers = {
      ...ApiConstants.headers,
      if (additionalHeaders != null) ...additionalHeaders,
      if (baseUrl.contains('5.104.107.253')) 'Host': 'nextgenerationaustria.at',
    };

    try {
      return await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));
    } catch (e) {
      // Bei Fehler: Reset und nochmal versuchen
      reset();
      final fallbackUrl = await getActiveBaseUrl();
      final fallbackHeaders = {
        ...ApiConstants.headers,
        if (additionalHeaders != null) ...additionalHeaders,
        if (fallbackUrl.contains('5.104.107.253')) 'Host': 'nextgenerationaustria.at',
      };
      
      return await http.post(
        Uri.parse('$fallbackUrl$endpoint'),
        headers: fallbackHeaders,
        body: body,
      ).timeout(const Duration(seconds: 30));
    }
  }
}
