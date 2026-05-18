import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  static const _prefKey = 'isDarkMode';

  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefKey) ?? false;
    isDarkMode.value = saved;
    _applyTheme(saved);
  }

  /// Toggle dipanggil dari ProfileController / UI
  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    _applyTheme(value);
    _saveThemeToPrefs(value);
  }

  void _applyTheme(bool dark) {
    Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);

    // Sesuaikan warna status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            dark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  Future<void> _saveThemeToPrefs(bool dark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, dark);
  }
}
