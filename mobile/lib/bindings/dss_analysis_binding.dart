import 'package:get/get.dart';
import '../presentation/controllers/dss_analysis_controller.dart';

class DssAnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DssAnalysisController>(() => DssAnalysisController());
  }
}
