import 'package:get/get.dart';
import '../presentation/controllers/workout_plan_controller.dart';

class WorkoutPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkoutPlanController>(() => WorkoutPlanController());
  }
}
