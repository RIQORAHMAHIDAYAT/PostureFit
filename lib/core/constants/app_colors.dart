import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4A90D9);
  static const Color primaryLight = Color(0xFF6AAEE8);
  static const Color primaryDark = Color(0xFF2C6FAC);
  static const Color secondary = Color(0xFF5BB8F5);
  static const Color accent = Color(0xFF3DD6C8);

  static const Color backgroundStart = Color(0xFFF4F8FC); // Off-white blue yang sangat soft
  static const Color backgroundEnd = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBlue = Color(0xFFE8F3FC);
  static const Color cardBlueDark = Color(0xFF3A7FC1);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF334155);
  static const Color textLight = Color(0xFF64748B);
  static const Color textWhite = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF4CAF82);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFE05C5C);

  static const Color inputBackground = Color(0xFFF5F9FF);
  static const Color inputBorder = Color(0xFFD0E4F5);
  static const Color divider = Color(0xFFE8F0F8);
  static const Color shadow = Color(0x1A4A90D9);

  static const Color navBackground = Color(0xFF3A7FC1);
  static const Color navActive = Color(0xFFFFFFFF);
  static const Color navInactive = Color(0xFFADD0EC);

  static const LinearGradient primaryAppBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF183B6B),
      Color(0xFF6FA9E7),
    ],
  );

  static final List<BoxShadow> primaryAppBarShadow = [
    BoxShadow(
      color: const Color(0xFF183B6B).withValues(alpha: 0.15),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundStart, backgroundEnd],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A90D9), Color(0xFF3A7FC1)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF4CAF82), Color(0xFF3DD6C8)],
  );
}
