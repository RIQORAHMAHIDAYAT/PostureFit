import 'package:get/get.dart';
import '../../data/services/workout_log_service.dart';
import '../../data/services/progress_report_service.dart';

class ProgressReportController extends GetxController {
  final _logService = WorkoutLogService();
  final _progressService = ProgressReportService();

  // State
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString selectedPeriod = 'Mingguan'.obs;
  final List<String> periods = ['Harian', 'Mingguan', 'Bulanan'];

  // Chart Data (activity_score)
  final RxList<double> chartData = <double>[].obs;
  final RxList<String> chartLabels = <String>[].obs;

  // Stats
  final RxInt totalKalori = 0.obs;
  final RxInt totalDurasi = 0.obs;
  final RxInt totalSesi = 0.obs;
  final RxDouble beratBadan = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      // 1. Fetch stats
      final stats = await _logService.getWorkoutStats();
      totalKalori.value = stats['total_kalori'] ?? 0;
      totalDurasi.value = stats['total_durasi'] ?? 0;
      totalSesi.value = stats['total_sesi'] ?? 0;
      
      // (Opsional) Ambil berat dari profile, mock untuk saat ini
      beratBadan.value = 68.5; 

      // 2. Fetch chart data sesuai periode
      await _fetchChart(selectedPeriod.value);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePeriod(String period) async {
    selectedPeriod.value = period;
    isLoading.value = true;
    try {
      await _fetchChart(period);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchChart(String period) async {
    final data = await _progressService.getProgress(period: period);
    
    // Map data ke list chart
    chartData.value = data.map((e) => (e['activity_score'] as int).toDouble()).toList();
    chartLabels.value = data.map((e) => (e['tanggal'] as String)).toList();
  }
}
