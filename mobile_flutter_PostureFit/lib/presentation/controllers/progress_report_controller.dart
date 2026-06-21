import 'package:get/get.dart';

class ProgressReportController extends GetxController {
  final RxString selectedPeriod = 'Mingguan'.obs;
  final List<String> periods = ['Harian', 'Mingguan', 'Bulanan'];

  final RxList<double> chartData = <double>[45.0, 60.0, 30.0, 80.0, 50.0, 95.0, 70.0].obs;

  void changePeriod(String period) {
    selectedPeriod.value = period;
    // Mock changing data berdasarkan periode yang dipilih
    if (period == 'Harian') {
      chartData.value = [20.0, 50.0, 80.0, 40.0, 90.0, 60.0, 30.0];
    } else if (period == 'Mingguan') {
      chartData.value = [45.0, 60.0, 30.0, 80.0, 50.0, 95.0, 70.0];
    } else {
      chartData.value = [70.0, 40.0, 90.0, 50.0, 85.0, 30.0, 60.0];
    }
  }
}
