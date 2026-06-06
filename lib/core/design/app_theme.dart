import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ── Light Theme (Alexandria) ──
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      secondary: Color(0xFF5A5F63),
      tertiary: AppColors.amber,
      surface: AppColors.lightSurface,
      onSurface: AppColors.textLight,
      onSurfaceVariant: AppColors.textLightVariant,
      outline: AppColors.textLightMuted,
      outlineVariant: AppColors.borderLight,
      error: AppColors.error,
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
    ),
    textTheme: GoogleFonts.spaceMonoTextTheme(ThemeData.light().textTheme).copyWith(
      headlineMedium: GoogleFonts.spaceMono(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textLight),
      titleLarge: GoogleFonts.spaceMono(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textLight),
      titleMedium: GoogleFonts.spaceMono(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textLight),
      bodyLarge: GoogleFonts.spaceMono(fontSize: 13, color: AppColors.textLight),
      bodyMedium: GoogleFonts.spaceMono(fontSize: 12, color: AppColors.textLightVariant),
      bodySmall: GoogleFonts.spaceMono(fontSize: 11, color: AppColors.textLightVariant),
      labelLarge: GoogleFonts.spaceMono(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: AppColors.primary),
      labelMedium: GoogleFonts.spaceMono(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textLightVariant),
      labelSmall: GoogleFonts.spaceMono(fontSize: 9, color: AppColors.textLightMuted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBg,
      elevation: 0,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'monospace'),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurfaceLow,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      labelStyle: GoogleFonts.spaceMono(fontSize: 12, color: AppColors.textLightVariant),
      hintStyle: GoogleFonts.spaceMono(fontSize: 12, color: AppColors.textLightMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: GoogleFonts.spaceMono(fontSize: 13, fontWeight: FontWeight.w600),
    )),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightSurfaceLow,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: GoogleFonts.spaceMono(fontSize: 11, color: AppColors.textLightVariant),
      secondaryLabelStyle: GoogleFonts.spaceMono(fontSize: 11, color: AppColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5))),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightBg,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLightMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  // ── Dark Theme (Alexandria) ──
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: Color(0xFF001946),
      primaryContainer: AppColors.primaryContainer,
      secondary: Color(0xFFC2C7CC),
      tertiary: AppColors.amberDark,
      surface: AppColors.darkSurface,
      onSurface: AppColors.textDark,
      onSurfaceVariant: AppColors.textDarkVariant,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.borderDark,
      error: AppColors.error,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.borderDark, width: 0.5),
      ),
    ),
    textTheme: GoogleFonts.spaceMonoTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineMedium: GoogleFonts.spaceMono(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.amberDark),
      titleLarge: GoogleFonts.spaceMono(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
      titleMedium: GoogleFonts.spaceMono(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
      bodyLarge: GoogleFonts.spaceMono(fontSize: 13, color: AppColors.textDark),
      bodyMedium: GoogleFonts.spaceMono(fontSize: 12, color: AppColors.textDarkVariant),
      bodySmall: GoogleFonts.spaceMono(fontSize: 11, color: AppColors.textDarkVariant),
      labelLarge: GoogleFonts.spaceMono(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: AppColors.amberDark),
      labelMedium: GoogleFonts.spaceMono(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textDarkVariant),
      labelSmall: GoogleFonts.spaceMono(fontSize: 9, color: AppColors.textMuted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.amberDark, fontFamily: 'monospace'),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Color(0xFF001946),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderDark)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderDark)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5)),
      labelStyle: GoogleFonts.spaceMono(fontSize: 12, color: AppColors.textDarkVariant),
      hintStyle: GoogleFonts.spaceMono(fontSize: 12, color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.amberDark,
      foregroundColor: AppColors.darkBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: GoogleFonts.spaceMono(fontSize: 13, fontWeight: FontWeight.w600),
    )),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedColor: AppColors.primaryDark.withValues(alpha: 0.2),
      labelStyle: GoogleFonts.spaceMono(fontSize: 11, color: AppColors.textDarkVariant),
      secondaryLabelStyle: GoogleFonts.spaceMono(fontSize: 11, color: AppColors.amberDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: const BorderSide(color: AppColors.borderDark)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBg,
      selectedItemColor: AppColors.amberDark,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
