/// app_constants.dart — Konstanta global aplikasi PostureFit.
class AppConstants {
  AppConstants._();

  // -------------------------------------------------------------------------
  // Base URL Backend
  // -------------------------------------------------------------------------
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
