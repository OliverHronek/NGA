// lib/core/constants/app_colors.dart - ORANGE & WEISS DESIGN
import 'package:flutter/material.dart';

class AppColors {
  // Primäre Orange-Töne (Next Generation Austria Branding)
  static const Color primary = Color(0xFFCC4500);        // Dunkles Orange #cc4500
  static const Color primaryLight = Color(0xFFFF9F66);   // Helles Orange #ff9f66
  static const Color primaryDark = Color(0xFFB8380A);    // Noch dunkleres Orange
  
  // Sekundäre Farben
  static const Color secondary = Color(0xFFFF9F66);      // Helles Orange als Sekundär
  static const Color accent = Color(0xFFCC4500);         // Dunkles Orange als Akzent
  
  // Hintergründe
  static const Color background = Color(0xFFF8F9FA);     // Hellgrau #f8f9fa
  static const Color surface = Color(0xFFFFFFFF);        // Weiß
  static const Color cardBackground = Color(0xFFFFFFFF); // Weiß für Karten
  
  // Text-Farben
  static const Color textPrimary = Color(0xFF333333);    // Dunkelgrau für Haupttext
  static const Color textSecondary = Color(0xFF666666);  // Mittelgrau für Sekundärtext
  static const Color textHint = Color(0xFF999999);       // Hellgrau für Hints
  static const Color textOnPrimary = Colors.white;       // Weiß auf Orange
  
  // Status-Farben
  static const Color success = Color(0xFF28A745);        // Grün für Erfolg
  static const Color error = Color(0xFFDC3545);          // Rot für Fehler
  static const Color warning = Color(0xFFFFC107);        // Gelb für Warnung
  static const Color info = Color(0xFF17A2B8);           // Blau für Info
  
  // Interaktions-Farben
  static const Color onSurface = Color(0xFF333333);      // Text auf Oberflächen
  static const Color onPrimary = Colors.white;           // Text auf Orange
  static const Color onSecondary = Colors.white;         // Text auf hellem Orange
  
  // Schatten und Transparenz
  static const Color shadowLight = Color(0x14000000);    // rgba(0,0,0,0.08)
  static const Color shadowMedium = Color(0x1F000000);   // rgba(0,0,0,0.12)
  static const Color shadowHeavy = Color(0x26CC4500);    // rgba(204,69,0,0.15)
  
  // Border-Farben
  static const Color border = Color(0xFFE5E5E5);         // Hellgrau für Borders
  static const Color borderActive = Color(0xFFCC4500);   // Orange für aktive Borders
  static const Color borderLight = Color(0x4DFF9F66);    // Transparentes helles Orange
  
  // Gradient-Definitionen
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFCC4500),  // Dunkles Orange
      Color(0xFFFF9F66),  // Helles Orange
    ],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8F9FA),  // Hellgrau
      Color(0xFFFFFFFF),  // Weiß
    ],
  );
  
  // Voting/Forum spezifische Farben
  static const Color forumCategory = Color(0xFFFF9F66);  // Helles Orange für Kategorien
  static const Color postBackground = Colors.white;       // Weiß für Posts
  static const Color commentBackground = Color(0xFFFAFAFA); // Sehr hellgrau für Kommentare
  
  // Voting-Farben
  static const Color voteYes = Color(0xFFCC4500);        // Orange für Ja-Stimmen
  static const Color voteNo = Color(0xFF999999);         // Grau für Nein-Stimmen
  static const Color voteNeutral = Color(0xFFE5E5E5);    // Hellgrau für neutral

  
  // Poll-spezifische Farben für Charts und Diagramme
  static const List<Color> pollColors = [
    Color(0xFFCC4500), // Primäres Orange (Ihr Branding)
    Color(0xFFFF9F66), // Helles Orange
    Color(0xFF28A745), // Grün (Success)
    Color(0xFF17A2B8), // Blau (Info)
    Color(0xFFFFC107), // Gelb (Warning)
    Color(0xFFDC3545), // Rot (Error)
    Color(0xFF6C757D), // Grau
    Color(0xFF20C997), // Teal
    Color(0xFFE83E8C), // Pink
    Color(0xFF6F42C1), // Lila
    Color(0xFFB8380A), // Dunkles Orange
    Color(0xFF343A40), // Dunkelgrau
    Color(0xFF007BFF), // Blau
    Color(0xFF28A745), // Grün (doppelt für mehr Variation)
    Color(0xFFFF9F66), // Helles Orange (doppelt)
  ];
  
  // Interactive States
  static const Color hover = Color(0x0FCC4500);          // Leichtes Orange für Hover
  static const Color pressed = Color(0x1FCC4500);        // Stärkeres Orange für Pressed
  static const Color disabled = Color(0xFF999999);       // Grau für disabled
  
  // Spezielle UI-Elemente
  static const Color floatingActionButton = Color(0xFFFF9F66); // Helles Orange für FAB
  static const Color bottomNavActive = Color(0xFFCC4500);      // Dunkles Orange für aktive Navigation
  static const Color bottomNavInactive = Color(0xFF999999);   // Grau für inaktive Navigation
  
  // Helper Methods für dynamische Farben
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}