import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de colores Dark Neon
  static const Color backgroundDark = Color(0xFF070B19); // Fondo principal azul oscuro casi negro
  static const Color surfaceDark = Color(0xFF111827); // Color de las tarjetas
  static const Color neonBlue = Color(0xFF00E5FF); // Cian neón principal
  static const Color neonBlueDark = Color(0xFF0055FF); // Azul neón secundario (gradientes)
  static const Color neonPurple = Color(0xFFD946EF); // Púrpura neón para contrastes
  
  // Colores para las tarjetas del Dashboard
  static const Color cardBlueStart = Color(0xFF1E3A8A);
  static const Color cardBlueEnd = Color(0xFF0F172A);
  
  static const Color cardPurpleStart = Color(0xFF4C1D95);
  static const Color cardPurpleEnd = Color(0xFF0F172A);
  
  static const Color cardRedStart = Color(0xFF7F1D1D);
  static const Color cardRedEnd = Color(0xFF0F172A);
  
  static const Color cardGreenStart = Color(0xFF064E3B);
  static const Color cardGreenEnd = Color(0xFF0F172A);

  // Estados
  static const Color successColor = Color(0xFF10B981); // Verde neón
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);

  // Tema exclusivo Oscuro (Neon)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: neonBlue,
        secondary: neonBlueDark,
        surface: surfaceDark,
        background: backgroundDark,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: Colors.white70),
        bodyMedium: GoogleFonts.inter(color: Colors.white70),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: neonBlue, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIconColor: Colors.white.withOpacity(0.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonBlue,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: neonBlue,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundDark,
        selectedItemColor: neonBlue,
        unselectedItemColor: Colors.white.withOpacity(0.4),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
      ),
    );
  }
}
