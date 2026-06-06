import 'package:flutter/material.dart';

/// Alexandria Design System — 1:1 from original ham-logs Tailwind/Compose theme
class AppColors {
  // ── Primary (Blue) ──
  static const primary = Color(0xFF094CB2);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF3366CC);
  static const primaryDark = Color(0xFFB1C5FF);
  static const primaryFixed = Color(0xFFD9E2FF);

  // ── Tertiary (Gold/Amber) ──
  static const amber = Color(0xFFBFAB49);
  static const amberDark = Color(0xFFDCC661);
  static const amberContainer = Color(0xFFF9E37A);

  // ── Light surface tokens ──
  static const lightBg = Color(0xFFFAF9FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceLow = Color(0xFFF5F3F4);
  static const lightSurfaceContainer = Color(0xFFEFEDEE);
  static const lightSurfaceHigh = Color(0xFFE9E8E9);

  // ── Dark surface tokens ──
  static const darkBg = Color(0xFF0B0D0F);
  static const darkSurface = Color(0xFF0B0D0F);
  static const darkSurfaceLight = Color(0xFF1C1E22);
  static const darkSurfaceHigh = Color(0xFF2A2C30);

  // ── Text ──
  static const textLight = Color(0xFF1B1C1D);
  static const textLightVariant = Color(0xFF434653);
  static const textLightMuted = Color(0xFF737784);
  static const textDark = Color(0xFFE8EAF0);
  static const textDarkVariant = Color(0xFFA0A4B0);

  // ── Border / Outline ──
  static const borderLight = Color(0xFFC3C6D5);
  static const borderDark = Color(0xFF3A3E47);

  // ── Status ──
  static const error = Color(0xFFBA1A1A);
  static const success = Color(0xFF00C853);

  // ── Mode accent badges ──
  static const accentUsb = Color(0xFF094CB2);
  static const accentLsb = Color(0xFFFF8C00);
  static const accentCw = Color(0xFF00C853);
  static const accentFm = Color(0xFFBA1A1A);
  static const accentFt8 = Color(0xFF8B5CF6);
  static const accentDefault = Color(0xFF094CB2);

  // ── Legacy aliases (keep existing code compiling) ──
  static const deep = Color(0xFF050508);
  static const ionBlue = primary;          // now Alexandria primary blue
  static const scopeGreen = success;
  static const alertRed = error;

  static const background = darkBg;
  static const surface = darkSurface;
  static const surfaceLight = darkSurfaceLight;
  static const border = borderDark;
  static const textPrimary = textDark;
  static const textSecondary = textDarkVariant;
  static const textMuted = Color(0xFF6B6A75);
}
