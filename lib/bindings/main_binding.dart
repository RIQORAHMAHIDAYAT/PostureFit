import 'package:get/get.dart';
import '../presentation/controllers/main_controller.dart';
import '../presentation/controllers/home_controller.dart';
import '../presentation/controllers/workout_plan_controller.dart';
import '../presentation/controllers/education_controller.dart';
import '../presentation/controllers/profile_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // WorkoutPlanController harus di-put dulu sebelum MainController.onInit()
    Get.put<WorkoutPlanController>(WorkoutPlanController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.put<EducationController>(EducationController());
    Get.put<ProfileController>(ProfileController());
    Get.put<MainController>(MainController());
  }
}
