import 'package:flutter/material.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool isVerified;
  final bool isAdmin;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.isVerified = false,  // Standard: nicht verifiziert
    this.isAdmin = false,     // Standard: kein Admin
    this.emailVerifiedAt,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final emailVerifiedAt = json['email_verified_at'] != null 
        ? DateTime.parse(json['email_verified_at'])
        : null;
    
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      // Determine verification status based on email_verified_at field
      isVerified: emailVerifiedAt != null,
      isAdmin: json['is_admin'] ?? false,
      emailVerifiedAt: emailVerifiedAt,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_verified': isVerified,
      'is_admin': isAdmin,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get displayName {
    print('User displayName - firstName: $firstName, lastName: $lastName, username: $username');
    if (firstName != null && lastName != null) {
      final fullName = '$firstName $lastName';
      print('Returning full name: $fullName');
      return fullName;
    }
    print('Returning username: $username');
    return username;
  }

  // Hilfsmethoden für Verifizierung
  String get verificationStatus {
    if (isVerified) return 'Verifiziert ✅';
    return 'Nicht verifiziert ❌';
  }

  Color get verificationColor {
    return isVerified ? const Color(0xFF4CAF50) : const Color(0xFFFF5722);
  }

  // Copy-with Methode für Updates
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    bool? isVerified,
    bool? isAdmin,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isVerified: isVerified ?? this.isVerified,
      isAdmin: isAdmin ?? this.isAdmin,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}