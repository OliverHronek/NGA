// lib/core/network/android_dns_override.dart
import 'dart:io';

class AndroidDNSOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    
    // Configure for Android DNS resolution
    client.connectionTimeout = Duration(seconds: 10);
    client.idleTimeout = Duration(seconds: 30);
    
    // Allow self-signed certificates for our domain (debugging only)
    client.badCertificateCallback = (cert, host, port) {
      return host == 'nextgenerationaustria.at';
    };
    
    return client;
  }
}

void enableAndroidDNS() {
  if (Platform.isAndroid) {
    HttpOverrides.global = AndroidDNSOverride();
  }
}
