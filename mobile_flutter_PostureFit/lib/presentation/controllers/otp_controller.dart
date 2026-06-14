// otp_controller.dart — Controller untuk halaman verifikasi OTP.
// Mengelola: Input 6 digit OTP, Timer countdown resend,
// Pemanggilan verify-otp & resend-otp ke backend.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../data/services/auth_service.dart';

class OtpController extends GetxController {
  // -------------------------------------------------------------------------
  // State
  // -------------------------------------------------------------------------
  final RxBool   isLoading     = false.obs;
  final RxBool   isResending   = false.obs;
  final RxInt    secondsLeft   = 60.obs;
  final RxString errorMessage  = ''.obs;

  // OTP fields — 6 kotak input terpisah
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  // -------------------------------------------------------------------------
  // Data dari argumen route
  // -------------------------------------------------------------------------
  late String email;
  late String name;

  final _authService = AuthService();
  Timer? _timer;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    // Ambil data dari argumen navigasi
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    email = args['email'] as String? ?? '';
    name  = args['name']  as String? ?? '';

    _startCountdown();
  }

  @override
  void onClose() {
    _timer?.cancel();
    // TIDAK memanggil .dispose() pada TextEditingControllers & FocusNodes di sini.
    // Menghindari crash "_dependents.isEmpty is not true" saat animasi route berjalan.
    // Dart GC akan membersihkan semuanya secara otomatis.
    super.onClose();
  }

  // -------------------------------------------------------------------------
  // Countdown untuk tombol Kirim Ulang
  // -------------------------------------------------------------------------
  void _startCountdown() {
    secondsLeft.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft.value > 0) {
        secondsLeft.value--;
      } else {
        t.cancel();
      }
    });
  }

  // -------------------------------------------------------------------------
  // Ambil kode OTP dari semua field
  // -------------------------------------------------------------------------
  String get _otpCode =>
      otpControllers.map((c) => c.text.trim()).join();

  bool get _isOtpComplete => _otpCode.length == 6;

  // -------------------------------------------------------------------------
  // Verify OTP → buat akun Backend → navigasi ke main
  // -------------------------------------------------------------------------
  Future<void> verifyOtp() async {
    errorMessage.value = '';

    if (!_isOtpComplete) {
      errorMessage.value = 'Masukkan 6 digit kode OTP.';
      return;
    }

    isLoading.value = true;
    try {
      await _authService.verifyOtp(email: email, otpCode: _otpCode);

      // OTP valid → akun dibuat → langsung masuk ke halaman utama
      Get.offAllNamed(AppRoutes.main);

      Get.snackbar(
        '🎉 Selamat Datang!',
        'Akun Anda berhasil dibuat. Selamat berolahraga!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      _resetOtpFields();
    } finally {
      isLoading.value = false;
    }
  }

  void _resetOtpFields() {
    for (final c in otpControllers) {
      c.clear();
    }
    focusNodes.first.requestFocus();
  }

  // -------------------------------------------------------------------------
  // Resend OTP via Backend (Email)
  // -------------------------------------------------------------------------
  Future<void> resendOtp() async {
    if (secondsLeft.value > 0) return;

    isResending.value = true;
    errorMessage.value = '';
    try {
      await _authService.resendOtp(email: email);
      _startCountdown();
      _resetOtpFields();

      Get.snackbar(
        'OTP Dikirim Ulang',
        'Kode OTP baru telah dikirim ke $email.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isResending.value = false;
    }
  }

  // -------------------------------------------------------------------------
  // Handle input pada setiap kotak OTP (auto-focus next)
  // -------------------------------------------------------------------------
  void onOtpFieldChanged(int index, String value) {
    errorMessage.value = '';
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    // Auto-submit jika semua terisi
    if (_isOtpComplete) verifyOtp();
  }

  void goBack() => Get.back();
}
