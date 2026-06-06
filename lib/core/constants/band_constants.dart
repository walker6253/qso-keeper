import 'package:flutter/material.dart';
import '../design/app_colors.dart';

class BandConstants {
  static const modes = ['USB', 'LSB', 'CW', 'FM', 'AM', 'FT8', 'FT4', 'RTTY', 'PSK31', 'JT65', 'JS8', 'SSTV'];

  static Color modeColor(String mode) {
    switch (mode.toUpperCase()) {
      case 'USB': case 'SSB': return AppColors.accentUsb;
      case 'LSB': return AppColors.accentLsb;
      case 'CW': return AppColors.accentCw;
      case 'FM': case 'AM': return AppColors.accentFm;
      case 'FT8': case 'FT4': case 'RTTY': case 'PSK31': return AppColors.accentFt8;
      default: return AppColors.accentDefault;
    }
  }
}
