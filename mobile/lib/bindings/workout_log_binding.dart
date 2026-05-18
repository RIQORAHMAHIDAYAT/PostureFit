import 'package:get/get.dart';
import '../presentation/controllers/workout_log_controller.dart';

class WorkoutLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkoutLogController>(() => WorkoutLogController());
  }
}
