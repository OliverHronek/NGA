// lib/core/network/simple_http_client.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class SimpleHttpClient {
  static HttpClient createClient() {
    final client = HttpClient();
    
    // Einfache, sichere Konfiguration ohne Rekursion
    client.connectionTimeout = const Duration(seconds: 10);
    client.idleTimeout = const Duration(seconds: 30);
    
    // Sichere SSL-Behandlung
    client.badCertificateCallback = (cert, host, port) {
      if (kDebugMode) {
        print('SSL Warning für $host:$port - Certificate: ${cert.subject}');
      }
      // Nur für unsere bekannten Hosts erlauben
      return host == 'nextgenerationaustria.at' || host == '5.104.107.253';
    };
    
    return client;
  }
  
  /// Einfacher HTTP GET mit manueller Header-Kontrolle
  static Future<HttpClientResponse> get(String url, {Map<String, String>? headers}) async {
    final client = createClient();
    
    try {
      final uri = Uri.parse(url);
      final request = await client.getUrl(uri);
      
      // Standard Headers setzen
      request.headers.set('User-Agent', 'NGA-Mobile-App/1.0 Flutter');
      request.headers.set('Accept', 'application/json');
      request.headers.set('Cache-Control', 'no-cache');
      
      // Host Header für IP-Adressen (SNI fix)
      if (_isIpAddress(uri.host)) {
        request.headers.set('Host', 'nextgenerationaustria.at');
        if (kDebugMode) print('Host Header gesetzt für IP: ${uri.host}');
      }
      
      // Custom Headers hinzufügen
      headers?.forEach((key, value) {
        request.headers.set(key, value);
      });
      
      if (kDebugMode) print('HTTP GET: $url');
      
      final response = await request.close();
      return response;
    } catch (e) {
      if (kDebugMode) print('HTTP GET Error für $url: $e');
      rethrow;
    } finally {
      client.close(force: true);
    }
  }
  
  /// Einfacher HTTP POST mit manueller Header-Kontrolle
  static Future<HttpClientResponse> post(String url, {
    Map<String, String>? headers,
    String? body,
  }) async {
    final client = createClient();
    
    try {
      final uri = Uri.parse(url);
      final request = await client.postUrl(uri);
      
      // Standard Headers setzen
      request.headers.set('User-Agent', 'NGA-Mobile-App/1.0 Flutter');
      request.headers.set('Accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Cache-Control', 'no-cache');
      
      // Host Header für IP-Adressen (SNI fix)
      if (_isIpAddress(uri.host)) {
        request.headers.set('Host', 'nextgenerationaustria.at');
        if (kDebugMode) print('Host Header gesetzt für IP: ${uri.host}');
      }
      
      // Custom Headers hinzufügen
      headers?.forEach((key, value) {
        request.headers.set(key, value);
      });
      
      // Body schreiben wenn vorhanden
      if (body != null) {
        request.write(body);
      }
      
      if (kDebugMode) print('HTTP POST: $url');
      
      final response = await request.close();
      return response;
    } catch (e) {
      if (kDebugMode) print('HTTP POST Error für $url: $e');
      rethrow;
    } finally {
      client.close(force: true);
    }
  }
  
  static bool _isIpAddress(String host) {
    final ipPattern = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
    return ipPattern.hasMatch(host);
  }
}
