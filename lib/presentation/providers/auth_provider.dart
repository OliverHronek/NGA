import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  // Automatisch einloggen beim App-Start
  Future<void> autoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        _user = await AuthService.getUser();
      }
    } catch (e) {
      _error = 'Auto-Login fehlgeschlagen';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.login(username, password);
      
      if (result['success']) {
        _user = result['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login fehlgeschlagen: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Registrierung
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      
      if (result['success']) {
        _user = result['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registrierung fehlgeschlagen: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  // ========== NEUE PROFIL-FUNKTIONEN ==========

  // User-Profil aktualisieren
  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      
      if (result['success']) {
        // User-Daten lokal aktualisieren
        _user = _user!.copyWith(
          firstName: firstName ?? _user!.firstName,
          lastName: lastName ?? _user!.lastName,
          email: email ?? _user!.email,
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Profil-Update fehlgeschlagen: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Email-Verifizierung senden
  Future<bool> sendEmailVerification() async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.sendEmailVerification();
      
      if (result['success']) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Email-Versendung fehlgeschlagen: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verifizierungs-Status aktualisieren (nach Bestätigung)
  Future<bool> checkVerificationStatus() async {
    if (_user == null) return false;

    try {
      final result = await AuthService.getUser();
      if (result != null) {
        print('DEBUG: checkVerificationStatus - User data from server: ${result.toJson()}');
        print('DEBUG: checkVerificationStatus - emailVerifiedAt: ${result.emailVerifiedAt}');
        print('DEBUG: checkVerificationStatus - isVerified: ${result.isVerified}');
        _user = result;
        notifyListeners();
        return _user!.isVerified;
      }
      return false;
    } catch (e) {
      print('DEBUG: checkVerificationStatus error: $e');
      _error = 'Status-Check fehlgeschlagen: $e';
      notifyListeners();
      return false;
    }
  }

  // Email-Verifizierung durchführen (mit Token aus Email-Link)
  Future<bool> verifyEmail(String verificationToken) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('DEBUG: verifyEmail - Starting verification with token: $verificationToken');
      final result = await AuthService.verifyEmail(verificationToken);
      print('DEBUG: verifyEmail - Server response: $result');
      
      if (result['success']) {
        // Update user data if provided
        if (result['user'] != null) {
          _user = result['user'];
          print('DEBUG: verifyEmail - Updated user from response: ${_user?.toJson()}');
        } else {
          // Fallback: fetch updated user data
          print('DEBUG: verifyEmail - No user in response, fetching user data');
          final userData = await AuthService.getUser();
          if (userData != null) {
            _user = userData;
            print('DEBUG: verifyEmail - Fetched user data: ${_user?.toJson()}');
          }
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('DEBUG: verifyEmail - Verification failed: ${result['error']}');
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('DEBUG: verifyEmail - Exception: $e');
      _error = 'Email-Verifizierung fehlgeschlagen: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Passwort ändern
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      if (result['success']) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Passwort-Änderung fehlgeschlagen: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // User-Daten manuell aktualisieren (für lokale Updates)
  void updateUserData(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  // Refresh user data from server
  Future<void> refreshUserData() async {
    if (_user == null) return;

    try {
      final refreshedUser = await AuthService.refreshUserData();
      if (refreshedUser != null) {
        _user = refreshedUser;
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing user data in provider: $e');
    }
  }

  // Verifizierungs-Status prüfen für Voting
  bool canVote() {
    return _user?.isVerified ?? false;
  }

  // Admin-Status prüfen für Content-Erstellung
  bool canCreateContent() {
    return _user?.isAdmin ?? false;
  }

  // Error zurücksetzen
  void clearError() {
    _error = null;
    notifyListeners();
  }
}