import 'package:get/get.dart';
import '../../data/services/workout_plan_service.dart';

class DssAnalysisController extends GetxController {
  final _service = WorkoutPlanService();

  // Loading / error state
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasData = false.obs;

  // Data dari backend
  final RxString kategoriTerpilih = ''.obs;
  final RxInt skorKesehatan = 0.obs;
  final RxString posturLabel = 'standing'.obs;
  final RxString posturCatatan = ''.obs;
  final RxString rekomendasi = ''.obs;
  final RxString tanggalAssessment = ''.obs;
  final RxDouble bmi = 0.0.obs;
  final RxString kategoriBmi = ''.obs;

  /// List skor SAW per kategori [{kategori, skor, persentase}, ...]
  final RxList<Map<String, dynamic>> sawDetail = <Map<String, dynamic>>[].obs;

  /// Riwayat analisis DSS (untuk halaman riwayat)
  final RxList<Map<String, dynamic>> analysisResults = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshAnalysis();
  }

  Future<void> refreshAnalysis() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final data = await _service.getLatestDss();
      if (data == null) {
        hasData.value = false;
      } else {
        hasData.value = true;
        _applyData(data);
      }

      // Juga ambil riwayat
      final history = await _service.getDssHistory();
      analysisResults.value = history;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _applyData(Map<String, dynamic> data) {
    kategoriTerpilih.value = data['kategori_terpilih'] ?? '';
    skorKesehatan.value = data['skor_kesehatan'] ?? 0;
    posturLabel.value = data['postur_label'] ?? 'standing';
    posturCatatan.value = data['postur_catatan'] ?? '';
    rekomendasi.value = data['rekomendasi'] ?? '';
    tanggalAssessment.value = data['tanggal_assessment'] ?? '';
    bmi.value = (data['bmi'] ?? 0.0).toDouble();
    kategoriBmi.value = data['kategori_bmi'] ?? '';

    final detail = data['saw_detail'] as List<dynamic>? ?? [];
    sawDetail.value = detail.cast<Map<String, dynamic>>();
  }
}
