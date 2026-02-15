import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors from HTML designs
  static const Color primary = Color(0xFF5B13EC);
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color backgroundDarkAlt = Color(0xFF161022);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color cardGlass = Color(0x08FFFFFF); // rgba(255,255,255,0.03)
  static const Color borderGlass = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8); // slate-400
  static const Color textTertiary = Color(0xFF64748B); // slate-500

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primary,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.splineSansTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: textTertiary,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: textTertiary,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: Color(0x33FFFFFF),
        thumbColor: Colors.white,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
        trackHeight: 4,
        overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
      ),
    );
  }
}
