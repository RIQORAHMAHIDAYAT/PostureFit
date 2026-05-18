import 'package:get/get.dart';

class ProgressReportController extends GetxController {
  final RxString selectedPeriod = 'Mingguan'.obs;
  final List<String> periods = ['Harian', 'Mingguan', 'Bulanan'];

  final RxList<double> chartData = <double>[40, 60, 55, 80, 75, 90, 85].obs;

  void changePeriod(String period) {
    selectedPeriod.value = period;
    // Mock changing data based on period
    if (period == 'Harian') {
      chartData.value = [30, 45, 40, 65, 60, 80, 70];
    } else if (period == 'Mingguan') {
      chartData.value = [40, 60, 55, 80, 75, 90, 85];
    } else {
      chartData.value = [50, 70, 65, 85, 80, 95, 90];
    }
  }
}
