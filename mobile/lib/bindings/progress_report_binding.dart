import 'package:get/get.dart';
import '../presentation/controllers/progress_report_controller.dart';

class ProgressReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgressReportController>(() => ProgressReportController());
  }
}
