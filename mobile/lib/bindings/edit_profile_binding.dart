import 'package:get/get.dart';
import '../presentation/pages/profile/edit_profile/edit_profile_controller.dart';

/// Binding untuk halaman Edit Profile.
/// Mendaftarkan [EditProfileController] dengan lazyPut agar di-dispose otomatis.
class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController>(() => EditProfileController());
  }
}
