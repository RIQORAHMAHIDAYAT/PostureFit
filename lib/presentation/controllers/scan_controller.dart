import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../routes/app_routes.dart';

class ScanController extends GetxController {
  final RxBool isCapturing = false.obs;
  final RxBool hasCapture = false.obs;
  final Rx<File?> capturedImage = Rx<File?>(null);

  final _picker = ImagePicker();

  /// Ambil foto dari kamera
  Future<void> onCapture() async {
    isCapturing.value = true;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (picked != null) {
        capturedImage.value = File(picked.path);
        hasCapture.value = true;
        await Future.delayed(const Duration(milliseconds: 300));
        Get.toNamed(AppRoutes.result);
      }
    } catch (e) {
      Get.snackbar(
        'Kamera tidak tersedia',
        'Coba gunakan galeri atau periksa izin kamera.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isCapturing.value = false;
    }
  }

  /// Ambil gambar dari galeri
  Future<void> onPickFromGallery() async {
    isCapturing.value = true;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked != null) {
        capturedImage.value = File(picked.path);
        hasCapture.value = true;
        await Future.delayed(const Duration(milliseconds: 300));
        Get.toNamed(AppRoutes.result);
      }
    } catch (e) {
      Get.snackbar(
        'Galeri tidak tersedia',
        'Periksa izin penyimpanan aplikasi.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isCapturing.value = false;
    }
  }

  void onRetake() {
    capturedImage.value = null;
    hasCapture.value = false;
  }

  void onBack() {
    Get.back();
  }
}
