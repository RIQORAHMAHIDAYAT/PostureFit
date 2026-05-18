import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class ScanController extends GetxController {
  final RxBool isCapturing = false.obs;
  final RxBool hasCapture = false.obs;

  void onCapture() async {
    isCapturing.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    isCapturing.value = false;
    hasCapture.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    Get.toNamed(AppRoutes.result);
  }

  void onRetake() {
    hasCapture.value = false;
  }

  void onBack() {
    Get.back();
  }
}