// lib/core/debug/network_debug.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'apk_comparison_debug.dart';

class NetworkDebug {
  static bool get isDebugMode => kDebugMode;
  
  static void log(String message) {
    if (isDebugMode) {
      print('🔍 [NETWORK DEBUG] $message');
    }
  }

  /// Test 1: Basic DNS Resolution Test
  static Future<void> testDNSResolution() async {
    log('=== DNS RESOLUTION TEST START ===');
    
    List<String> testDomains = [
      'nextgenerationaustria.at',
      'google.com',
      'fonts.gstatic.com',
      '5.104.107.253'  // Direct IP
    ];
    
    for (String domain in testDomains) {
      try {
        log('Testing DNS for: $domain');
        
        final addresses = await InternetAddress.lookup(domain);
        log('✅ DNS SUCCESS for $domain: ${addresses.map((a) => a.address).join(', ')}');
        
      } catch (e) {
        log('❌ DNS FAILED for $domain: $e');
      }
    }
    log('=== DNS RESOLUTION TEST END ===');
  }

  /// Test 2: HTTP Client Comparison Test
  static Future<void> testHttpClients() async {
    log('=== HTTP CLIENTS COMPARISON TEST START ===');
    
    // Test standard http package
    await _testStandardHttpClient();
    
    // Test HttpClient directly
    await _testHttpClient();
    
    log('=== HTTP CLIENTS COMPARISON TEST END ===');
  }

  static Future<void> _testStandardHttpClient() async {
    log('--- Testing standard http package ---');
    
    List<String> testUrls = [
      'https://nextgenerationaustria.at/political-app-api/health',
      'https://5.104.107.253/political-app-api/health',
      'https://google.com',
      'https://fonts.gstatic.com'
    ];
    
    for (String url in testUrls) {
      try {
        log('HTTP GET: $url');
        
        final response = await http.get(
          Uri.parse(url),
          headers: {'User-Agent': 'NGA-Debug/1.0'},
        ).timeout(Duration(seconds: 10));
        
        log('✅ HTTP SUCCESS: $url - Status: ${response.statusCode}');
        
      } catch (e) {
        log('❌ HTTP FAILED: $url - Error: $e');
      }
    }
  }

  static Future<void> _testHttpClient() async {
    log('--- Testing HttpClient directly ---');
    
    final client = HttpClient();
    client.connectionTimeout = Duration(seconds: 10);
    client.badCertificateCallback = (cert, host, port) => true; // Debug only
    
    List<String> testUrls = [
      'https://nextgenerationaustria.at/political-app-api/health',
      'https://5.104.107.253/political-app-api/health',
    ];
    
    for (String url in testUrls) {
      HttpClientRequest? request;
      try {
        log('HttpClient GET: $url');
        
        final uri = Uri.parse(url);
        request = await client.getUrl(uri);
        request.headers.set('User-Agent', 'NGA-Debug-HttpClient/1.0');
        
        final response = await request.close();
        await response.drain(); // Consume the response
        
        log('✅ HttpClient SUCCESS: $url - Status: ${response.statusCode}');
        
      } catch (e) {
        log('❌ HttpClient FAILED: $url - Error: $e');
      } finally {
        request?.abort();
      }
    }
    
    client.close();
  }

  /// Test 3: Platform Information Test
  static Future<void> testPlatformInfo() async {
    log('=== PLATFORM INFORMATION TEST START ===');
    
    log('Platform.isAndroid: ${Platform.isAndroid}');
    log('Platform.operatingSystem: ${Platform.operatingSystem}');
    log('Platform.operatingSystemVersion: ${Platform.operatingSystemVersion}');
    log('kIsWeb: $kIsWeb');
    log('kDebugMode: $kDebugMode');
    log('kReleaseMode: $kReleaseMode');
    
    // Network interface information
    try {
      final interfaces = await NetworkInterface.list();
      log('Network interfaces: ${interfaces.length}');
      
      for (var interface in interfaces) {
        log('Interface: ${interface.name} - ${interface.addresses.map((a) => a.address).join(', ')}');
      }
    } catch (e) {
      log('❌ Network interfaces failed: $e');
    }
    
    log('=== PLATFORM INFORMATION TEST END ===');
  }

  /// Test 4: API Constants Test
  static Future<void> testApiConstants() async {
    log('=== API CONSTANTS TEST START ===');
    
    log('ApiConstants.baseUrl: ${ApiConstants.baseUrl}');
    log('ApiConstants.fallbackBaseUrl: ${ApiConstants.fallbackBaseUrl}');
    log('ApiConstants.login: ${ApiConstants.login}');
    
    log('=== API CONSTANTS TEST END ===');
  }

  /// Test 5: Socket Connection Test
  static Future<void> testSocketConnection() async {
    log('=== SOCKET CONNECTION TEST START ===');
    
    List<Map<String, dynamic>> testConnections = [
      {'host': 'nextgenerationaustria.at', 'port': 443},
      {'host': '5.104.107.253', 'port': 443},
      {'host': 'google.com', 'port': 443},
      {'host': 'fonts.gstatic.com', 'port': 443},
    ];
    
    for (var conn in testConnections) {
      try {
        log('Socket test: ${conn['host']}:${conn['port']}');
        
        final socket = await Socket.connect(conn['host'], conn['port'], 
          timeout: Duration(seconds: 10));
        
        log('✅ Socket SUCCESS: ${conn['host']}:${conn['port']}');
        socket.destroy();
        
      } catch (e) {
        log('❌ Socket FAILED: ${conn['host']}:${conn['port']} - Error: $e');
      }
    }
    
    log('=== SOCKET CONNECTION TEST END ===');
  }

  /// Run all debug tests
  static Future<void> runAllTests() async {
    log('🚀 STARTING COMPREHENSIVE NETWORK DEBUG TESTS 🚀');
    
    await testPlatformInfo();
    await testApiConstants();
    await testDNSResolution();
    await testSocketConnection();
    await testHttpClients();
    
    // Add APK comparison tests
    await ApkComparisonDebug.runApkComparison();
    
    log('🏁 NETWORK DEBUG TESTS COMPLETED 🏁');
  }
}
