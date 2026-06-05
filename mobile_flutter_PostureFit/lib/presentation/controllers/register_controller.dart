import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../data/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterController extends GetxController {
  final nameController            = TextEditingController();
  final emailController           = TextEditingController();
  final passwordController        = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey                   = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;

  final _authService = AuthService();

  // -------------------------------------------------------------------------
  // Langkah 1: Kirim OTP ke Email
  // -------------------------------------------------------------------------
  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _authService.sendOtp(
        name:     nameController.text.trim(),
        email:    emailController.text.trim(),
        password: passwordController.text,
      );

      Get.toNamed(
        AppRoutes.otpVerification,
        arguments: {
          'email': emailController.text.trim(),
          'name':  nameController.text.trim(),
        },
      );
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(String msg) {
    Get.snackbar(
      'Pendaftaran Gagal',
      msg.replaceAll('Exception: ', ''),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  // -------------------------------------------------------------------------
  // Google Sign-In
  // -------------------------------------------------------------------------
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      // await googleSignIn.signOut(); // Opsional jika ingin selalu milih akun
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        isLoading.value = false;
        return; // User membatalkan
      }

      final String email = googleUser.email;
      final String name = googleUser.displayName ?? 'Pengguna Google';

      await _authService.loginWithGoogle(
        email: email,
        name: name,
      );

      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.offNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
