import 'package:get/get.dart';
import '../presentation/controllers/forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    // fenix: true → controller otomatis dibuat ulang jika sudah di-dispose
    // Penting agar user bisa menggunakan lupa password lebih dari sekali
    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(),
      fenix: true,
    );
  }
}
