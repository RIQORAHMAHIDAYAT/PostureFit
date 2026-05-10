import 'package:get/get.dart';

class ResultController extends GetxController {
  final RxInt selectedFokus = 0.obs;
  final RxDouble umur = 25.0.obs;
  final RxDouble tinggiBadan = 182.0.obs;
  final RxDouble beratBadan = 76.0.obs;
  final RxDouble lingkarPerut = 45.0.obs;

  /// 0 = Rumah, 1 = Gym, 2 = Calisthenics, -1 = belum dipilih
  final RxInt selectedLingkungan = (-1).obs;

  final List<String> fokusOptions = ['Defisit Kalori', 'Surplus Kalori', 'Pertahankan'];

  void setFokus(int index) => selectedFokus.value = index;
  void setUmur(double v) => umur.value = v;
  void setTinggi(double v) => tinggiBadan.value = v;
  void setBerat(double v) => beratBadan.value = v;
  void setLingkar(double v) => lingkarPerut.value = v;

  /// Pilih lingkungan (radio — hanya satu yang aktif)
  void setLingkungan(int index) {
    selectedLingkungan.value = index;
  }

  void onLihatHasil() {}
  void onAnalysis() {
    Get.toNamed(
      '/analysis-result',
      arguments: {
        'tinggi': tinggiBadan.value,
        'berat': beratBadan.value,
        'umur': umur.value,
        'lingkar': lingkarPerut.value,
        // 0=Rumah, 1=Gym, 2=Calisthenics; default 0 jika belum dipilih
        'lingkungan': selectedLingkungan.value < 0 ? 0 : selectedLingkungan.value,
      },
    );
  }

  void onBack() => Get.back();
}
