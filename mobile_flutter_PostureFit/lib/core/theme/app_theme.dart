import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppTheme {
  AppTheme._();

  // ── Warna khusus dark mode ──────────────────────────────────────────────────
  static const Color _darkBg          = Color(0xFF0D1B2E); // latar utama
  static const Color _darkBgSecondary = Color(0xFF112240); // latar sekunder
  static const Color _darkCard        = Color(0xFF1A2E4A); // kartu
  static const Color _darkCardAlt     = Color(0xFF162035); // kartu alt
  static const Color _darkBorder      = Color(0xFF243B55); // garis
  static const Color _darkInput       = Color(0xFF1A2E4A); // input
  static const Color _darkTextPrimary = Color(0xFFF8FAFC); // teks utama
  static const Color _darkTextSecond  = Color(0xFFCBD5E1); // teks sekunder

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.cardBackground,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundStart,
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLG,
          vertical: AppDimensions.paddingMD,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: _darkCard,
        error: AppColors.error,
        onSurface: _darkTextPrimary,
        outline: _darkBorder,
      ),
      scaffoldBackgroundColor: _darkBg,
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerColor: _darkBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkInput,
        hintStyle: TextStyle(color: _darkTextSecond),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: _darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: _darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLG,
          vertical: AppDimensions.paddingMD,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          elevation: 0,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge:  TextStyle(color: _darkTextPrimary, fontFamily: 'Poppins'),
        displayMedium: TextStyle(color: _darkTextPrimary, fontFamily: 'Poppins'),
        displaySmall:  TextStyle(color: _darkTextPrimary, fontFamily: 'Poppins'),
        headlineLarge: TextStyle(color: _darkTextPrimary, fontFamily: 'Poppins'),
        headlineMedium:TextStyle(color: _darkTextPrimary, fontFamily: 'Poppins'),
        headlineSmall: TextStyle(color: _darkTextPrimary, fontFamily: 'Poppins'),
        titleLarge:    TextStyle(color: _darkTextPrimary, fontFamily: 'Poppins'),
        titleMedium:   TextStyle(color: _darkTextPrimary, fontFamily: 'Poppins'),
        titleSmall:    TextStyle(color: _darkTextPrimary, fontFamily: 'Poppins'),
        bodyLarge:     TextStyle(color: _darkTextPrimary, fontFamily: 'Poppins'),
        bodyMedium:    TextStyle(color: _darkTextSecond,  fontFamily: 'Poppins'),
        bodySmall:     TextStyle(color: _darkTextSecond,  fontFamily: 'Poppins'),
        labelLarge:    TextStyle(color: _darkTextPrimary, fontFamily: 'Poppins'),
        labelMedium:   TextStyle(color: _darkTextSecond,  fontFamily: 'Poppins'),
        labelSmall:    TextStyle(color: _darkTextSecond,  fontFamily: 'Poppins'),
      ),
      // Expose warna khusus agar widget bisa mengakses via extension
      extensions: const [AppDarkColors()],
    );
  }

  // ── Helper: warna card berdasarkan brightness aktif ────────────────────────
  static Color cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkCard
        : AppColors.cardBackground;
  }

  static Color cardAltColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkCardAlt
        : const Color(0xFFF2F7FD);
  }

  static Color bgColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkBg
        : AppColors.backgroundStart;
  }

  static Color bgSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkBgSecondary
        : AppColors.backgroundEnd;
  }

  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkTextPrimary
        : AppColors.textPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkTextSecond
        : AppColors.textSecondary;
  }

  static Color borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkBorder
        : AppColors.inputBorder;
  }

  static Color inputBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkInput
        : AppColors.inputBackground;
  }

  static Color dividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkBorder
        : AppColors.divider;
  }
}

// ── ThemeExtension agar widget bisa akses warna dark secara langsung ──────────
class AppDarkColors extends ThemeExtension<AppDarkColors> {
  const AppDarkColors();

  @override
  AppDarkColors copyWith() => const AppDarkColors();

  @override
  AppDarkColors lerp(ThemeExtension<AppDarkColors>? other, double t) =>
      const AppDarkColors();
}
