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
    if (kIsWeb) {
      return 'http://127.0.0.1:8000'; // Browser Web
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (_usePhysical) {
        // HP Fisik via Wi-Fi — backend harus dijalankan dengan --host 0.0.0.0
        return 'http://$_pcLocalIp:8000';
      }
      // Emulator Android Studio
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000'; // Windows / Platform lain
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
