// lib/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Font Family
  static const String fontFamily = 'Segoe UI'; // Oder eine andere Schriftart
  
  // Logo/Header Styles
  static const TextStyle logo = TextStyle(
    fontSize: 48.0,           // 3rem
    fontWeight: FontWeight.w900,
    color: AppColors.primaryOrange,
    fontFamily: fontFamily,
    height: 1.2,
  );
  
  static const TextStyle tagline = TextStyle(
    fontSize: 20.8,           // 1.3rem
    fontWeight: FontWeight.w300,
    color: AppColors.mediumGray,
    fontFamily: fontFamily,
    height: 1.6,
  );
  
  // Überschriften
  static const TextStyle heroTitle = TextStyle(
    fontSize: 40.0,           // 2.5rem
    fontWeight: FontWeight.w700,
    color: AppColors.primaryOrange,
    fontFamily: fontFamily,
    height: 1.2,
  );
  
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 32.0,           // 2rem
    fontWeight: FontWeight.w600,
    color: AppColors.primaryOrange,
    fontFamily: fontFamily,
    height: 1.2,
  );
  
  static const TextStyle featureTitle = TextStyle(
    fontSize: 22.4,           // 1.4rem
    fontWeight: FontWeight.w700,
    color: AppColors.primaryOrange,
    fontFamily: fontFamily,
    height: 1.2,
  );
  
  static const TextStyle ctaTitle = TextStyle(
    fontSize: 32.0,           // 2rem
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    fontFamily: fontFamily,
    height: 1.2,
  );
  
  // Body Text
  static const TextStyle heroText = TextStyle(
    fontSize: 19.2,           // 1.2rem
    color: Color(0xFF555555),
    fontFamily: fontFamily,
    height: 1.8,
  );
  
  static const TextStyle bodyText = TextStyle(
    fontSize: 17.6,           // 1.1rem
    color: Color(0xFF555555),
    fontFamily: fontFamily,
    height: 1.8,
  );
  
  static const TextStyle featureText = TextStyle(
    fontSize: 16.0,           // 1rem
    color: AppColors.mediumGray,
    fontFamily: fontFamily,
    height: 1.7,
  );
  
  static const TextStyle ctaText = TextStyle(
    fontSize: 17.6,           // 1.1rem
    color: AppColors.white,
    fontFamily: fontFamily,
    height: 1.6,
    fontWeight: FontWeight.w400,
  );
  
  // Button Styles
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 17.6,           // 1.1rem
    fontWeight: FontWeight.w600,
    color: AppColors.primaryOrange,
    fontFamily: fontFamily,
  );
  
  static const TextStyle buttonWebApp = TextStyle(
    fontSize: 19.2,           // 1.2rem
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    fontFamily: fontFamily,
  );
  
  // Coming Soon
  static const TextStyle comingSoon = TextStyle(
    fontSize: 24.0,           // 1.5rem
    fontWeight: FontWeight.w600,
    color: AppColors.primaryOrange,
    fontFamily: fontFamily,
  );
  
  // Footer
  static const TextStyle footer = TextStyle(
    fontSize: 16.0,
    color: AppColors.mediumGray,
    fontFamily: fontFamily,
    height: 1.6,
  );
  
  // Mobile Responsive Varianten
  static const TextStyle logoMobile = TextStyle(
    fontSize: 32.0,           // 2rem auf Mobile
    fontWeight: FontWeight.w900,
    color: AppColors.primaryOrange,
    fontFamily: fontFamily,
    height: 1.2,
  );
  
  static const TextStyle heroTitleMobile = TextStyle(
    fontSize: 32.0,           // 2rem auf Mobile
    fontWeight: FontWeight.w700,
    color: AppColors.primaryOrange,
    fontFamily: fontFamily,
    height: 1.2,
  );
  
  static const TextStyle heroTextMobile = TextStyle(
    fontSize: 16.0,           // 1rem auf Mobile
    color: Color(0xFF555555),
    fontFamily: fontFamily,
    height: 1.8,
  );
}