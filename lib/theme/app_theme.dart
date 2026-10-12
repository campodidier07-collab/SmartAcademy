import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de Superficies M3 Dark Premium
  static const Color backgroundMain = Color(0xFF080A16);
  static const Color surfaceLowest = backgroundMain;
  static const Color backgroundSecondary = Color(0xFF0E1224);
  static const Color surfaceLow = backgroundSecondary;

  static const Color cardBase = Color(0xFF141930);
  static const Color cardElevated = Color(0xFF1A213D);
  static const Color cardHighest = Color(0xFF222B4D);

  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color secondaryPurple = Color(0xFF8B5CF6);
  static const Color tertiaryCyan = Color(0xFF06B6D4);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textPrimary = textMain;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const Color surfaceLight = Color(0xFF1E2646);
  static const Color surfaceDark = Color(0xFF0E1224);
  static const Color surfaceCard = cardBase;
  static const Color surfaceCardElevated = cardElevated;
  static const Color accentPurple = Color(0xFF8B5CF6);

  static const Color borderLight = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
  static const Color borderFocused = Color(0x4D3B82F6);

  // Espaciado estándar (8-point grid)
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 22.0;
  static const double radiusPill = 999.0;

  // Tema Global Material Design 3
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundMain,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF1E3A8A),
        onPrimaryContainer: Color(0xFFDBEAFE),
        secondary: secondaryPurple,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF4C1D95),
        onSecondaryContainer: Color(0xFFEDE9FE),
        tertiary: tertiaryCyan,
        onTertiary: Colors.black,
        surface: cardBase,
        onSurface: textMain,
        onSurfaceVariant: textSecondary,
        outline: borderLight,
        outlineVariant: Color(0x33FFFFFF),
        error: error,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textMain,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.2,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          color: textMain,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          height: 1.25,
          letterSpacing: -0.3,
        ),
        displaySmall: GoogleFonts.outfit(
          color: textMain,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: textMain,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.outfit(
          color: textMain,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textMain,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
        titleMedium: GoogleFonts.outfit(
          color: textMain,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        titleSmall: GoogleFonts.outfit(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: textMain,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        bodySmall: GoogleFonts.outfit(
          color: textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.outfit(
          color: textMain,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.outfit(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
        labelSmall: GoogleFonts.outfit(
          color: textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textMain),
        titleTextStyle: GoogleFonts.outfit(
          color: textMain,
          fontSize: 19,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBase,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardElevated,
        hintStyle: GoogleFonts.outfit(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.outfit(color: textSecondary, fontSize: 14),
        floatingLabelStyle: GoogleFonts.outfit(
          color: primaryBlue,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textMain,
          side: const BorderSide(color: borderLight, width: 1),
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBase,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        titleTextStyle: GoogleFonts.outfit(
          color: textMain,
          fontSize: 19,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.outfit(
          color: textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardElevated,
        contentTextStyle: GoogleFonts.outfit(color: textMain, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardBase,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardElevated,
        labelStyle: GoogleFonts.outfit(color: textSecondary, fontSize: 13),
        side: const BorderSide(color: borderLight, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
