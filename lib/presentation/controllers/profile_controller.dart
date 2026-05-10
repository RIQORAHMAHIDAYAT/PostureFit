import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

class ProfileController extends GetxController {
  // ── User info ─────────────────────────────────────────────────────────────
  final RxString name   = 'Riqo Rahma H'.obs;
  final RxString email  = 'riqorahma@gmail.com'.obs;
  final RxInt    age    = 24.obs;
  final RxDouble height = 170.0.obs;
  final RxDouble weight = 75.0.obs;
  final RxDouble bmi    = 26.4.obs;

  // ── Settings ──────────────────────────────────────────────────────────────
  // isDarkMode kini mengambil langsung dari ThemeController (single source of truth)
  RxBool get isDarkMode => ThemeController.to.isDarkMode;
  final RxBool isSleepMode = false.obs;

  // ── Computed ──────────────────────────────────────────────────────────────

  /// Returns 2 uppercase initials from the name.
  String get initials {
    final parts = name.value.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  /// BMI category label.
  String get bmiStatus {
    final v = bmi.value;
    if (v < 18.5) return 'Underweight';
    if (v < 25.0) return 'Normal';
    if (v < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Colour used to highlight the current BMI category.
  Color get bmiColor {
    switch (bmiStatus) {
      case 'Underweight': return const Color(0xFF4A90D9);
      case 'Normal':      return const Color(0xFF4CAF82);
      case 'Overweight':  return const Color(0xFFF5A623);
      default:            return const Color(0xFFE05C5C);
    }
  }

  /// 0.0–1.0 progress for the circular BMI indicator (capped at 40 BMI).
  double get bmiProgress => (bmi.value / 40.0).clamp(0.0, 1.0);

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Toggle dark mode — didelegasikan ke ThemeController global
  void toggleDarkMode(bool value) => ThemeController.to.toggleDarkMode(value);

  void toggleSleepMode(bool value) => isSleepMode.value = value;

  void onEditProfile() {
    // TODO: Navigate to edit-profile page.
  }

  void onPrivacyPolicy() {
    // TODO: Navigate to privacy-policy page.
  }

  void onLogout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Apakah kamu yakin ingin keluar?',
      textConfirm: 'Logout',
      textCancel: 'Batal',
      confirmTextColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFE05C5C),
      onConfirm: () {
        Get.back();
        Get.offAllNamed('/login');
      },
    );
  }
}
