// lib/core/network/android_http_client.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class AndroidHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = HttpClient(context: context);
    
    // Konfiguration für Android-spezifische HTTP-Probleme
    client.badCertificateCallback = (cert, host, port) {
      // Nur für Debug-Builds SSL-Validierung lockern
      if (kDebugMode) {
        print('SSL Cert Warning für $host:$port');
        // Akzeptiere Self-Signed Certificates nur für unsere Domain
        return host == 'nextgenerationaustria.at' || host == '5.104.107.253';
      }
      return false; // Strenge SSL-Validierung in Release
    };
    
    client.connectionTimeout = const Duration(seconds: 15);
    client.idleTimeout = const Duration(seconds: 30);
    
    // DNS-Konfiguration für Android
    client.findProxy = (uri) {
      if (Platform.isAndroid) {
        return HttpClient.findProxyFromEnvironment(uri, environment: Platform.environment);
      }
      return 'DIRECT';
    };
    
    return client;
  }
  
  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
    if (Platform.isAndroid) {
      return HttpClient.findProxyFromEnvironment(url, environment: environment ?? Platform.environment);
    }
    return super.findProxyFromEnvironment(url, environment);
  }
}
