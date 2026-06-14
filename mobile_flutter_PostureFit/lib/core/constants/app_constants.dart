import 'package:flutter/foundation.dart';

/// app_constants.dart — Konstanta global aplikasi PostureFit.
class AppConstants {
  AppConstants._();

  // -------------------------------------------------------------------------
  // Base URL Backend
  //
  // Cara penggunaan:
  //   - Emulator Android Studio : flutter run
  //   - HP Fisik (Wi-Fi)        : flutter run --dart-define=USE_PHYSICAL=true
  //   - HP Fisik (USB/adb)      : jalankan `adb reverse tcp:8000 tcp:8000` dulu,
  //                               lalu flutter run (tanpa flag)
  // -------------------------------------------------------------------------
  // IP lokal PC Anda di jaringan Wi-Fi (ganti jika IP berubah)
  static const String _pcLocalIp = '192.168.1.9';

  // Set lewat --dart-define=USE_PHYSICAL=true saat run ke HP fisik via Wi-Fi
  static const bool _usePhysical =
      bool.fromEnvironment('USE_PHYSICAL', defaultValue: false);

  static String get baseUrl {
    // Menggunakan URL ngrok agar bisa diakses dari HP fisik maupun emulator
    return 'https://balsamic-populace-octagon.ngrok-free.dev';
  }

  // -------------------------------------------------------------------------
  // Storage Keys (SharedPreferences)
  // -------------------------------------------------------------------------
  static const String keyToken    = 'auth_token';
  static const String keyUserId   = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';

  // -------------------------------------------------------------------------
  // OTP
  // -------------------------------------------------------------------------
  static const int otpLength         = 6;
  static const int otpResendCooldown = 60; // detik
}
