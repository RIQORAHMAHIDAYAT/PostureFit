import 'package:get/get.dart';
import '../presentation/controllers/activity_log_controller.dart';

class ActivityLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActivityLogController>(() => ActivityLogController());
  }
}
