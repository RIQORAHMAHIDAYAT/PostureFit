import 'package:get/get.dart';
import 'workout_plan_controller.dart';

class MainController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('initialTab')) {
      selectedIndex.value = (args['initialTab'] as int? ?? 0);
      // Jika ada data analisis, teruskan ke WorkoutPlanController
      if (args.containsKey('bmi')) {
        final wc = Get.find<WorkoutPlanController>();
        wc.loadData(args);
      }
    }
  }

  void changeTab(int index) {
    // Index 1 = Scan → navigate separately (bukan tab biasa)
    if (index == 1) {
      Get.toNamed('/scan');
      return;
    }
    selectedIndex.value = index;
  }

  void goToWorkoutTab() {
    selectedIndex.value = 2;
  }
}
