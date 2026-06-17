import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/activity_log_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  final formKey            = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;

  final _authService = AuthService();
  final _activityLogService = ActivityLogService();

  // -------------------------------------------------------------------------
  // Login dengan email & password ke backend
  // -------------------------------------------------------------------------
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _authService.login(
        email:    emailController.text.trim(),
        password: passwordController.text,
      );

      // Catat aktivitas login berhasil
      await _activityLogService.saveLog(
        icon: 'login',
        title: 'Login Akun',
        desc: 'Berhasil masuk ke aplikasi.',
        email: emailController.text.trim(),
      );

      // Navigasi ke halaman utama setelah login berhasil
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      Get.snackbar(
        'Login Gagal',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------------------------------------------------------------
  // Google Sign-In
  // -------------------------------------------------------------------------
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      // Sign out dulu agar popup pemilihan akun selalu muncul
      // (tanpa ini, Google langsung login pakai akun terakhir tanpa tanya)
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User membatalkan proses login
        isLoading.value = false;
        return;
      }

      // Ambil data profil dari googleUser
      final String email = googleUser.email;
      final String name = googleUser.displayName ?? 'Pengguna Google';

      // Kirim ke backend untuk upsert & generate JWT
      await _authService.loginWithGoogle(
        email: email,
        name: name,
      );

      // Catat aktivitas login Google berhasil
      await _activityLogService.saveLog(
        icon: 'login',
        title: 'Login Akun (Google)',
        desc: 'Berhasil masuk menggunakan akun Google.',
        email: email,
      );

      // Navigasi ke home
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      Get.snackbar(
        'Login Google Gagal',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.offNamed(AppRoutes.register);
  }

  @override
  void onClose() {
    // TIDAK memanggil .dispose() pada TextEditingControllers di sini.
    // Alasan: saat Get.offAllNamed(AppRoutes.login) dipanggil (misalnya setelah reset password),
    // GetX bisa saja me-reuse LoginController ini untuk halaman login yang baru.
    // Lalu saat animasi halaman login yang lama selesai, GetX memanggil onClose() ini.
    // Jika kita dispose controllernya, halaman login yang baru akan crash dengan
    // "TextEditingController used after being disposed".
    // Dart GC akan membersihkan memory-nya secara otomatis.
    super.onClose();
  }
}
