import 'package:flutter/material.dart';

class AppColors {
  // NGA Brand Colors (Österreich inspiriert)
  static const Color primary = Color.fromARGB(6, 109, 109, 109); // Österreich Rot
  static const Color secondary = Color(0xFF1976D2); // Demokratie Blau
  static const Color accent = Color(0xFF388E3C); // Hoffnung Grün
  
  // UI Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Poll Results Colors
  static const List<Color> pollColors = [
    Color(0xFF2196F3), // Blau
    Color(0xFF4CAF50), // Grün  
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Lila
    Color(0xFFF44336), // Rot
    Color(0xFF795548), // Braun
  ];
}