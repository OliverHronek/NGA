// lib/core/network/network_test.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'robust_http_client.dart';

class NetworkTest {
  static Future<void> runDiagnostics() async {
    if (kDebugMode) {
      print('=== NETZWERK DIAGNOSE START ===');
      
      // 1. DNS Test
      await _testDNS();
      
      // 2. HTTP Client Tests
      await _testHttpClients();
      
      // 3. HTTPS/SSL Tests
      await _testSSL();
      
      // 4. Backend Test
      await _testBackend();
      
      print('=== NETZWERK DIAGNOSE ENDE ===');
    }
  }
  
  static Future<void> _testDNS() async {
    if (kDebugMode) print('\n🔍 DNS Tests:');
    
    final hosts = [
      'nextgenerationaustria.at',
      'google.com',
      'fonts.gstatic.com',
    ];
    
    for (final host in hosts) {
      try {
        final addresses = await InternetAddress.lookup(host);
        if (kDebugMode) {
          print('✅ $host -> ${addresses.map((a) => a.address).join(', ')}');
        }
      } catch (e) {
        if (kDebugMode) print('❌ $host -> $e');
      }
    }
  }
  
  static Future<void> _testHttpClients() async {
    if (kDebugMode) print('\n🌐 HTTP Client Tests:');
    
    // Test mit RobustHttpClient
    await _testWithRobustClient();
    
    // Test mit Standard HttpClient
    await _testWithHttpClient();
  }
  
  static Future<void> _testWithRobustClient() async {
    if (kDebugMode) print('\n💪 RobustHttpClient Test:');
    
    try {
      final body = await RobustHttpClient.get('https://nextgenerationaustria.at/political-app-api/health');
      if (kDebugMode) {
        print('✅ RobustHttpClient Success: ${body.length} bytes');
        print('✅ Response: ${body.substring(0, body.length.clamp(0, 100))}...');
      }
    } catch (e) {
      if (kDebugMode) print('❌ RobustHttpClient Error: $e');
    }
  }
  
  static Future<void> _testWithHttpClient() async {
    if (kDebugMode) print('\n📡 Standard HttpClient:');
    
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      client.badCertificateCallback = (cert, host, port) => false;
      
      final request = await client.getUrl(Uri.parse('https://nextgenerationaustria.at/political-app-api/health'));
      request.headers.set('User-Agent', 'NGA-Test-Client/1.0');
      
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      
      if (kDebugMode) {
        print('✅ Status: ${response.statusCode}');
        print('✅ Headers: ${response.headers}');
        print('✅ Body: ${body.length > 100 ? body.substring(0, 100) + '...' : body}');
      }
      
      client.close();
    } catch (e) {
      if (kDebugMode) print('❌ HttpClient Error: $e');
    }
    
    // Test mit IP-Adresse
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      client.badCertificateCallback = (cert, host, port) => false;
      
      final request = await client.getUrl(Uri.parse('https://5.104.107.253/political-app-api/health'));
      request.headers.set('User-Agent', 'NGA-Test-Client/1.0');
      request.headers.set('Host', 'nextgenerationaustria.at'); // SNI fix
      
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      
      if (kDebugMode) {
        print('✅ IP Direct Status: ${response.statusCode}');
        print('✅ IP Direct Body: ${body.length > 100 ? body.substring(0, 100) + '...' : body}');
      }
      
      client.close();
    } catch (e) {
      if (kDebugMode) print('❌ IP Direct Error: $e');
    }
  }
  
  static Future<void> _testWithDio() async {
    // Entfernt - verwenden nur Standard-Komponenten
    if (kDebugMode) print('📦 Dio Test: Übersprungen (Standard-Komponenten only)');
  }
  
  /// Test Backend-Erreichbarkeit
  static Future<void> _testBackend() async {
    if (kDebugMode) print('\n� Backend Connectivity Test:');
    
    try {
      final body = await RobustHttpClient.get('https://nextgenerationaustria.at/political-app-api/health');
      if (kDebugMode) {
        print('✅ Backend erreichbar: ${body.length} bytes');
        print('✅ Response: ${body.substring(0, body.length.clamp(0, 200))}...');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Backend nicht erreichbar: $e');
    }
  }
  
  static Future<void> _testSSL() async {
    if (kDebugMode) print('\n🔐 SSL/TLS Tests:');
    
    final testUrls = [
      'https://nextgenerationaustria.at/political-app-api/health',
      'https://5.104.107.253/political-app-api/health',
      'https://google.com',
    ];
    
    for (final url in testUrls) {
      await _testSSLConnection(url);
    }
  }
  
  static Future<void> _testSSLConnection(String url) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 3);
    
    try {
      final uri = Uri.parse(url);
      final request = await client.getUrl(uri);
      
      // Für IP-Adressen Host Header setzen
      if (_isIpAddress(uri.host)) {
        request.headers.set('Host', 'nextgenerationaustria.at');
      }
      
      final response = await request.close();
      await response.drain(); // Consume response
      
      if (kDebugMode) print('✅ SSL OK: $url (${response.statusCode})');
    } catch (e) {
      if (kDebugMode) print('❌ SSL FAIL: $url -> $e');
    } finally {
      client.close();
    }
  }
  
  static bool _isIpAddress(String host) {
    final ipPattern = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
    return ipPattern.hasMatch(host);
  }
}

// Extension für einfachen Aufruf
extension NetworkTestWidget on Widget {
  Widget withNetworkTest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NetworkTest.runDiagnostics();
    });
    return this;
  }
}
