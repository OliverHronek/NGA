// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primäre Orange-Töne
  static const Color primaryOrange = Color(0xFFCC4500);      // #cc4500
  static const Color lightOrange = Color(0xFFFF9F66);       // #ff9f66
  static const Color darkOrange = Color(0xFFB8380A);        // Dunklerer Orange-Ton
  
  // Neutrale Farben
  static const Color white = Color(0xFFFFFFFF);             // #ffffff
  static const Color lightGray = Color(0xFFF8F9FA);         // #f8f9fa
  static const Color mediumGray = Color(0xFF666666);        // #666666
  static const Color darkGray = Color(0xFF333333);          // #333333
  
  // Schatten und Transparenz
  static const Color shadowLight = Color(0x14000000);       // rgba(0,0,0,0.08)
  static const Color shadowMedium = Color(0x1F000000);      // rgba(0,0,0,0.12)
  static const Color shadowHeavy = Color(0x26CC4500);       // rgba(204,69,0,0.15)
  
  // Gradient-Farben
  static const List<Color> primaryGradient = [
    primaryOrange,
    lightOrange,
  ];
  
  static const List<Color> backgroundGradient = [
    lightGray,
    white,
  ];
  
  // Border-Farben
  static const Color borderLight = Color(0x4DFF9F66);       // rgba(255,159,102,0.3)
  static const Color borderMedium = Color(0x80FF9F66);      // rgba(255,159,102,0.5)
  
  // Status-Farben (falls benötigt)
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);
}