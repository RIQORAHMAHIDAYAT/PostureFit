import 'package:get/get.dart';

class ResultController extends GetxController {
  final RxInt selectedFokus = 0.obs;
  final RxDouble umur = 25.0.obs;
  final RxDouble tinggiBadan = 182.0.obs;
  final RxDouble beratBadan = 76.0.obs;
  final RxDouble lingkarPerut = 45.0.obs;
  final RxBool latihanRumah = false.obs;
  final RxBool sesiGym = false.obs;
  final RxBool calisthenics = false.obs;

  final List<String> fokusOptions = ['Defisit Kalori', 'Surplus Kalori', 'Pertahankan'];

  void setFokus(int index) => selectedFokus.value = index;
  void setUmur(double v) => umur.value = v;
  void setTinggi(double v) => tinggiBadan.value = v;
  void setBerat(double v) => beratBadan.value = v;
  void setLingkar(double v) => lingkarPerut.value = v;
  void toggleRumah(bool v) => latihanRumah.value = v;
  void toggleGym(bool v) => sesiGym.value = v;
  void toggleCalisthenics(bool v) => calisthenics.value = v;

  void onLihatHasil() {}
  void onAnalysis() {}
  void onBack() => Get.back();
}