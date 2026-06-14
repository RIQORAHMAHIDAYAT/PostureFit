// forgot_password_controller.dart — Controller untuk alur Lupa Password.
//
// Mengelola 3 langkah alur reset password:
//   Langkah 1: Input email → request OTP reset password
//   Langkah 2: Verifikasi OTP 6 digit
//   Langkah 3: Input password baru → simpan ke backend

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../data/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // State — Langkah 1: Email
  // ─────────────────────────────────────────────────────────────────────────
  final emailController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // State — Langkah 2: OTP Verifikasi
  // ─────────────────────────────────────────────────────────────────────────
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  final RxBool isOtpLoading = false.obs;
  final RxBool isResending = false.obs;
  final RxInt secondsLeft = 60.obs;
  final RxString otpErrorMessage = ''.obs;

  Timer? _timer;

  // ─────────────────────────────────────────────────────────────────────────
  // State — Langkah 3: Password Baru
  // ─────────────────────────────────────────────────────────────────────────
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final newPasswordFormKey = GlobalKey<FormState>();
  final RxBool isResetLoading = false.obs;
  final RxString resetErrorMessage = ''.obs;
  final RxInt passwordStrength = 0.obs;

  final _authService = AuthService();

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    newPasswordController.addListener(_checkPasswordStrength);
  }

  @override
  void onClose() {
    _timer?.cancel();
    // Hapus listener dulu sebelum widget tree di-unmount
    newPasswordController.removeListener(_checkPasswordStrength);
    
    // TIDAK memanggil .dispose() pada TextEditingControllers & FocusNodes di sini.
    // Alasan: saat Get.offAllNamed() dipanggil, Flutter masih merender halaman lama
    // selama animasi transisi. Jika di-dispose sekarang, widget yang masih aktif
    // akan crash dengan error:
    // 1. "TextEditingController used after being disposed"
    // 2. "_dependents.isEmpty is not true" (karena FocusNode di-dispose saat masih nempel)
    // Dart GC akan membersihkan semuanya secara otomatis setelah tidak ada referensi aktif.
    
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Langkah 1: Kirim OTP Reset Password ke Email
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> sendResetOtp() async {
    errorMessage.value = '';
    final email = emailController.text.trim();

    if (email.isEmpty) {
      errorMessage.value = 'Email wajib diisi.';
      return;
    }
    if (!email.contains('@')) {
      errorMessage.value = 'Format email tidak valid.';
      return;
    }

    isLoading.value = true;
    try {
      await _authService.sendForgotPasswordOtp(email: email);

      // Reset OTP fields & start countdown
      _resetOtpFields();
      _startCountdown();

      // Navigasi ke halaman verifikasi OTP
      Get.toNamed(AppRoutes.resetOtpVerification);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Langkah 2: Verifikasi OTP
  // ─────────────────────────────────────────────────────────────────────────
  String get _otpCode =>
      otpControllers.map((c) => c.text.trim()).join();

  bool get _isOtpComplete => _otpCode.length == 6;

  Future<void> verifyResetOtp() async {
    otpErrorMessage.value = '';

    if (!_isOtpComplete) {
      otpErrorMessage.value = 'Masukkan 6 digit kode OTP.';
      return;
    }

    isOtpLoading.value = true;
    try {
      await _authService.verifyForgotPasswordOtp(
        email: emailController.text.trim(),
        otpCode: _otpCode,
      );

      // OTP valid → navigasi ke halaman reset password
      Get.toNamed(AppRoutes.newPassword);
    } catch (e) {
      otpErrorMessage.value = e.toString().replaceAll('Exception: ', '');
      _resetOtpFields();
    } finally {
      isOtpLoading.value = false;
    }
  }

  void onOtpFieldChanged(int index, String value) {
    otpErrorMessage.value = '';
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    // Auto-submit jika semua terisi
    if (_isOtpComplete) verifyResetOtp();
  }

  Future<void> resendResetOtp() async {
    if (secondsLeft.value > 0) return;

    isResending.value = true;
    otpErrorMessage.value = '';
    try {
      await _authService.sendForgotPasswordOtp(
          email: emailController.text.trim());
      _startCountdown();
      _resetOtpFields();

      Get.snackbar(
        'OTP Dikirim Ulang',
        'Kode OTP baru telah dikirim ke ${emailController.text.trim()}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      otpErrorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isResending.value = false;
    }
  }

  void _resetOtpFields() {
    for (final c in otpControllers) {
      c.clear();
    }
    if (focusNodes.isNotEmpty) {
      focusNodes.first.requestFocus();
    }
  }

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

  // ─────────────────────────────────────────────────────────────────────────
  // Langkah 3: Simpan Password Baru
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> resetPassword() async {
    resetErrorMessage.value = '';

    if (!newPasswordFormKey.currentState!.validate()) return;

    isResetLoading.value = true;
    try {
      await _authService.resetPassword(
        email: emailController.text.trim(),
        newPassword: newPasswordController.text,
      );

      // ⚠️ Setel loading = false SEBELUM navigasi agar tidak menyentuh
      // controller yang sudah di-dispose oleh Get.offAllNamed
      isResetLoading.value = false;

      // Snackbar ditampilkan sebelum navigasi (snackbar bersifat overlay global)
      Get.snackbar(
        '✅ Password Berhasil Diubah',
        'Silakan login dengan password baru Anda.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );

      // Navigasi terakhir — setelah ini controller akan di-dispose
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      isResetLoading.value = false;
      resetErrorMessage.value = e.toString().replaceAll('Exception: ', '');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Password Strength Checker
  // ─────────────────────────────────────────────────────────────────────────
  void _checkPasswordStrength() {
    final pw = newPasswordController.text;
    if (pw.isEmpty) {
      passwordStrength.value = 0;
      return;
    }

    int score = 0;
    if (pw.length >= 6) score++;
    if (pw.length >= 10) score++;
    if (pw.contains(RegExp(r'[A-Z]'))) score++;
    if (pw.contains(RegExp(r'[0-9]'))) score++;
    if (pw.contains(RegExp(r'[!@#\$&*~%^()_\-+=\[\]{};:,.<>?/\\|]'))) {
      score++;
    }
    passwordStrength.value = score > 4 ? 4 : score;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Navigasi
  // ─────────────────────────────────────────────────────────────────────────
  void goBackToForgotPassword() => Get.back();
  void goBackToOtp() => Get.back();
}
