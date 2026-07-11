import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../../routes/app_routes.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user_model.dart';

class ProfileController extends GetxController {
  // ── User info ─────────────────────────────────────────────────────────────
  final RxString name   = ''.obs;
  final RxString email  = ''.obs;
  final RxString gender = ''.obs;
  final RxInt    age    = 0.obs;
  final RxDouble height = 0.0.obs;
  final RxDouble weight = 0.0.obs;
  final RxDouble bmi    = 0.0.obs;
  final RxString profilePicture = ''.obs;
  final RxBool isLoading = true.obs;

  final _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    isLoading.value = true;
    try {
      final data = await _authService.getMe();
      final user = UserModel.fromJson(data);

      name.value   = user.name;
      email.value  = user.email;
      height.value = user.height ?? 0.0;
      weight.value = user.weight ?? 0.0;
      bmi.value    = user.bmi ?? 0.0;
      age.value    = user.age ?? 0;
      gender.value = user.gender ?? '';
      profilePicture.value = user.profilePicture ?? '';

      // Simpan ke cache lokal agar bisa ditampilkan saat offline
      await _authService.cacheUserData(user);
    } catch (e) {
      debugPrint('[ProfileController] getMe() gagal: $e — mencoba data cache lokal.');
      // Gunakan data yang sudah tersimpan di SharedPreferences (bukan dummy)
      final cached = await _authService.getCachedUser();
      if (cached != null) {
        name.value   = cached.name;
        email.value  = cached.email;
        height.value = cached.height ?? 0.0;
        weight.value = cached.weight ?? 0.0;
        bmi.value    = cached.bmi ?? 0.0;
        age.value    = cached.age ?? 0;
        gender.value = cached.gender ?? '';
        profilePicture.value = cached.profilePicture ?? '';
      }
      // Jika tidak ada cache sama sekali (misal baru install), biarkan kosong —
      // user akan tetap pada akun mereka karena token masih ada.
    } finally {
      isLoading.value = false;
    }
  }

  // ── Settings ──────────────────────────────────────────────────────────────
  // isDarkMode kini mengambil langsung dari ThemeController (single source of truth)
  RxBool get isDarkMode => ThemeController.to.isDarkMode;
  final RxBool isSleepMode = false.obs;

  // ── Computed ──────────────────────────────────────────────────────────────

  /// Returns 2 uppercase initials from the name.
  String get initials {
    if (name.value.isEmpty) return '?';
    final parts = name.value.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  /// BMI category label.
  String get bmiStatus {
    final v = bmi.value;
    if (v <= 0.0) return 'Belum Diatur';
    if (v < 18.5) return 'Underweight';
    if (v < 25.0) return 'Normal';
    if (v < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Colour used to highlight the current BMI category.
  Color get bmiColor {
    switch (bmiStatus) {
      case 'Belum Diatur': return Colors.grey;
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
    Get.toNamed(AppRoutes.editProfile);
  }

  void onActivityLog() {
    Get.toNamed(AppRoutes.activityLog);
  }

  void onPrivacyPolicy() {
    Get.toNamed(AppRoutes.privacyPolicy);
  }

  void onLogout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Apakah kamu yakin ingin keluar?',
      textConfirm: 'Logout',
      textCancel: 'Batal',
      confirmTextColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFE05C5C),
      onConfirm: () async {
        Get.back(); // close dialog
        await _authService.logout();
        Get.offAllNamed('/login');
      },
    );
  }
}
