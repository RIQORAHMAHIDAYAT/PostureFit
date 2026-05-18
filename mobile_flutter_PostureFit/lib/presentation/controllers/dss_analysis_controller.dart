import 'package:get/get.dart';

class DssAnalysisController extends GetxController {
  final RxList<Map<String, dynamic>> analysisResults = <Map<String, dynamic>>[
    {
      'title': 'Analisis Postur Tubuh',
      'score': 85,
      'status': 'Baik',
      'date': '15 Mei 2026',
      'recommendation': 'Lanjutkan latihan peregangan rutin.',
    },
    {
      'title': 'Analisis BMI & Nutrisi',
      'score': 72,
      'status': 'Normal',
      'date': '14 Mei 2026',
      'recommendation': 'Tingkatkan asupan protein harian.',
    },
    {
      'title': 'Kualitas Tidur',
      'score': 60,
      'status': 'Cukup',
      'date': '13 Mei 2026',
      'recommendation': 'Usahakan tidur sebelum jam 10 malam.',
    },
  ].obs;

  void refreshAnalysis() {
    // Logic to refresh or recalculate DSS
  }
}
