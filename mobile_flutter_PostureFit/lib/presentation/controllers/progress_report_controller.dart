import 'package:get/get.dart';

class ProgressReportController extends GetxController {
  final RxString selectedPeriod = 'Mingguan'.obs;
  final List<String> periods = ['Harian', 'Mingguan', 'Bulanan'];

  final RxList<double> chartData = <double>[0, 0, 0, 0, 0, 0, 0].obs;

  void changePeriod(String period) {
    selectedPeriod.value = period;
    // Mock changing data based on period
    if (period == 'Harian') {
      chartData.value = [0, 0, 0, 0, 0, 0, 0];
    } else if (period == 'Mingguan') {
      chartData.value = [0, 0, 0, 0, 0, 0, 0];
    } else {
      chartData.value = [0, 0, 0, 0, 0, 0, 0];
    }
  }
}
