import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Poppins';

  static bool get _isDark {
    try {
      final context = Get.context;
      if (context != null) {
        return Theme.of(context).brightness == Brightness.dark;
      }
    } catch (_) {}
    return false;
  }

  static Color get _primaryColor => _isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimary;
  static Color get _secondaryColor => _isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary;
  static Color get _lightColor => _isDark ? const Color(0xFF94A3B8) : AppColors.textLight;

  static TextStyle get displayLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: _primaryColor,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: _primaryColor,
        letterSpacing: -0.3,
      );

  static TextStyle get headingLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _primaryColor,
      );

  static TextStyle get headingMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _primaryColor,
      );

  static TextStyle get headingSmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _primaryColor,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _secondaryColor,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: _secondaryColor,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _secondaryColor,
      );

  static TextStyle get labelLarge => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _secondaryColor,
      );

  static TextStyle get captionStyle => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: _lightColor,
      );

  static TextStyle get logoTitle => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: -0.3,
      );

  static TextStyle get statValue => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
      );

  static TextStyle get statLabel => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.navInactive,
      );
}
