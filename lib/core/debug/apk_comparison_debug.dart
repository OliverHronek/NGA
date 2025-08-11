// lib/core/debug/apk_comparison_debug.dart
import 'package:flutter/foundation.dart';
import 'dart:io';

class ApkComparisonDebug {
  static void log(String message) {
    if (kDebugMode) {
      print('🆚 [APK COMPARISON] $message');
    }
  }

  /// Test what changed between first APK (that worked) and current APK
  static Future<void> compareConfigurations() async {
    log('=== APK CONFIGURATION COMPARISON START ===');
    
    // Test 1: Check current HTTP Overrides
    await _checkHttpOverrides();
    
    // Test 2: Check Android manifest permissions
    await _checkAndroidPermissions();
    
    // Test 3: Check network security configuration
    await _checkNetworkSecurityConfig();
    
    // Test 4: Check build configuration
    await _checkBuildConfiguration();
    
    log('=== APK CONFIGURATION COMPARISON END ===');
  }

  static Future<void> _checkHttpOverrides() async {
    log('--- Checking HTTP Overrides ---');
    
    try {
      // Check if HttpOverrides.global is set
      final currentOverride = HttpOverrides.current;
      
      if (currentOverride == null) {
        log('✅ No HttpOverrides set (this is good - matches first working APK)');
      } else {
        log('⚠️ HttpOverrides ARE set: ${currentOverride.runtimeType}');
        log('   This might be causing DNS issues!');
        log('   First APK probably had no overrides');
      }
      
    } catch (e) {
      log('❌ Error checking HttpOverrides: $e');
    }
  }

  static Future<void> _checkAndroidPermissions() async {
    log('--- Android Permissions Check ---');
    
    // We can't directly read manifest from Dart, but we can log expected permissions
    log('Expected permissions in AndroidManifest.xml:');
    log('  - INTERNET (required for HTTP)');
    log('  - ACCESS_NETWORK_STATE (for network state)');
    log('  - WAKE_LOCK (for background tasks)');
    log('Note: Check actual AndroidManifest.xml file to verify these permissions exist');
  }

  static Future<void> _checkNetworkSecurityConfig() async {
    log('--- Network Security Configuration Check ---');
    
    log('Expected network_security_config.xml should allow:');
    log('  - HTTP traffic (for development)');
    log('  - Clear text traffic to specific domains');
    log('  - Custom CA certificates if needed');
    log('Note: Check android/app/src/main/res/xml/network_security_config.xml');
  }

  static Future<void> _checkBuildConfiguration() async {
    log('--- Build Configuration Check ---');
    
    log('Build mode: ${kDebugMode ? "DEBUG" : "RELEASE"}');
    log('Is Web: $kIsWeb');
    log('Platform: ${Platform.operatingSystem}');
    
    if (!kDebugMode) {
      log('⚠️ Running in RELEASE mode');
      log('  - ProGuard/R8 might be obfuscating network code');
      log('  - Debug prints are disabled');
      log('  - Network security is stricter');
    }
  }

  /// Test specific scenarios that might have changed
  static Future<void> testWhatChanged() async {
    log('=== WHAT CHANGED SINCE FIRST APK? ===');
    
    // Scenario 1: DNS override was added
    log('Scenario 1: DNS Override Impact');
    log('  - First APK: No HttpOverrides (worked perfectly)');
    log('  - Current APK: AndroidDNSOverride added (might break DNS)');
    log('  - Solution: Remove all HttpOverrides to match first APK');
    
    // Scenario 2: Network security tightened
    log('Scenario 2: Network Security Changes');
    log('  - First APK: Standard Flutter HTTP client');
    log('  - Current APK: Modified HTTP client with overrides');
    log('  - Solution: Revert to standard HTTP client');
    
    // Scenario 3: Android version compatibility
    log('Scenario 3: Android Compatibility');
    log('  - Device: Pixel 8 Pro (Android 16 API 36)');
    log('  - High API level might have stricter network policies');
    log('  - Solution: Add network permissions and security config');
    
    log('=== WHAT CHANGED ANALYSIS END ===');
  }

  /// Main debug function to run all tests
  static Future<void> runApkComparison() async {
    log('🔍 STARTING APK COMPARISON DEBUG');
    
    await compareConfigurations();
    await testWhatChanged();
    
    log('🏁 APK COMPARISON DEBUG COMPLETED');
    
    // Provide clear recommendations
    log('');
    log('🎯 RECOMMENDATIONS:');
    log('1. Remove ALL HttpOverrides to match first working APK');
    log('2. Use standard Flutter HTTP client (no modifications)');
    log('3. Ensure AndroidManifest.xml has INTERNET permission');
    log('4. Test with clean APK build (no overrides)');
  }
}
