import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true, brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFFAF9FA),
    colorScheme: ColorScheme.light(
      primary: AppColors.amber, secondary: AppColors.ionBlue,
      tertiary: AppColors.scopeGreen, surface: Color(0xFFFFFFFF),
    ),
    cardTheme: CardThemeData(color: Color(0xFFFFFFFF), elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    textTheme: GoogleFonts.jetBrainsMonoTextTheme(ThemeData.light().textTheme).copyWith(
      headlineMedium: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.amber),
      titleLarge: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1B1C1D)),
      titleMedium: GoogleFonts.spaceMono(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B1C1D)),
      bodyLarge: GoogleFonts.spaceMono(fontSize: 13, color: Color(0xFF1B1C1D)),
      bodyMedium: GoogleFonts.spaceMono(fontSize: 12, color: Color(0xFF434653)),
      bodySmall: GoogleFonts.spaceMono(fontSize: 11, color: Color(0xFF434653)),
    ),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Color(0xFFF5F3F4), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Color(0xFFC3C6D5)))),
    appBarTheme: AppBarTheme(backgroundColor: Color(0xFFFAF9FA), elevation: 0, titleTextStyle: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.amber)),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Color(0xFFFAF9FA), selectedItemColor: AppColors.amber, unselectedItemColor: Color(0xFF5C5A55), type: BottomNavigationBarType.fixed, elevation: 0),
  );


  static final darkTheme = ThemeData(
    useMaterial3: true, brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.dark(
      primary: AppColors.amber, onPrimary: AppColors.deep,
      secondary: AppColors.ionBlue, onSecondary: AppColors.deep,
      tertiary: AppColors.scopeGreen, surface: AppColors.surface,
      onSurface: AppColors.textPrimary, surfaceContainerHighest: AppColors.surfaceLight,
      error: AppColors.alertRed, outline: AppColors.border,
      outlineVariant: AppColors.border.withValues(alpha: 0.3),
    ),
    cardTheme: CardThemeData(color: AppColors.surface, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.2), width: 0.5))),
    textTheme: GoogleFonts.jetBrainsMonoTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineMedium: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: AppColors.amber),
      titleLarge: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleMedium: GoogleFonts.spaceMono(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.spaceMono(fontSize: 13, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.spaceMono(fontSize: 12, color: AppColors.textSecondary),
      bodySmall: GoogleFonts.spaceMono(fontSize: 11, color: AppColors.textSecondary),
      labelLarge: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: AppColors.amber),
      labelMedium: GoogleFonts.spaceMono(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      labelSmall: GoogleFonts.spaceMono(fontSize: 9, color: AppColors.textMuted),
    ),
    appBarTheme: AppBarTheme(backgroundColor: AppColors.background, elevation: 0, centerTitle: false,
      titleTextStyle: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.amber)),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: AppColors.ionBlue, foregroundColor: AppColors.deep),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.3))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.3))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.amber, width: 1.5)),
      labelStyle: GoogleFonts.spaceMono(fontSize: 12, color: AppColors.textSecondary),
      hintStyle: GoogleFonts.spaceMono(fontSize: 12, color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.amber, foregroundColor: AppColors.deep,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600))),
    chipTheme: ChipThemeData(backgroundColor: AppColors.surface,
      selectedColor: AppColors.amber.withValues(alpha: 0.2),
      labelStyle: GoogleFonts.spaceMono(fontSize: 11, color: AppColors.textSecondary),
      secondaryLabelStyle: GoogleFonts.spaceMono(fontSize: 11, color: AppColors.amber),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: AppColors.border.withValues(alpha: 0.2)))),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: AppColors.background,
      selectedItemColor: AppColors.amber, unselectedItemColor: AppColors.textMuted, type: BottomNavigationBarType.fixed, elevation: 0),
  );
}

