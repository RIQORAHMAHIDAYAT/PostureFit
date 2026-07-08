import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/workout_plan_service.dart';

class WorkoutItem {
  final String nama;
  final String target;
  final IconData icon;
  final Color iconColor;
  final String setReps;
  final int kalori;

  const WorkoutItem({
    required this.nama,
    required this.target,
    required this.icon,
    required this.iconColor,
    required this.setReps,
    required this.kalori,
  });
}

class WorkoutPlanController extends GetxController {
  final _service = WorkoutPlanService();

  // State
  final RxInt selectedTab = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasAnalysisData = false.obs;

  // Data dari backend
  final RxString kategoriBMI = 'Normal'.obs;
  final RxString posturLabel = 'standing'.obs;
  final RxString posturCatatan = ''.obs;
  final RxString lingkunganAktif = 'Rumah'.obs;
  final RxInt estimasiKalori = 0.obs;
  final RxInt estimasiDurasi = 35.obs;

  final RxString workoutUtamaNama = ''.obs;
  final RxString workoutUtamaSet = ''.obs;
  final Rxn<WorkoutItem> workoutUtamaItem = Rxn<WorkoutItem>();
  final RxList<WorkoutItem> workoutTambahan = <WorkoutItem>[].obs;
  final RxList<WorkoutItem> workoutKoreksiPostur = <WorkoutItem>[].obs;

  final List<String> tabs = ['Rumah', 'Gym', 'Calisthenics'];

  // Untuk navigasi
  final RxInt selectedNavIndex = 2.obs;

  String get tanggal {
    final now = DateTime.now();
    const hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${hari[now.weekday - 1]}, ${now.day} ${bulan[now.month - 1]} ${now.year}';
  }

  String get fokusLatihan {
    switch (kategoriBMI.value) {
      case 'Kurus':
        return 'Strength & Bulking';
      case 'Normal':
        return 'Maintenance & Kebugaran';
      case 'Skinnyfat':
        return 'Body Recomposition';
      case 'Obesitas':
        return 'Fat Loss & Mobilitas';
      default:
        return 'Umum';
    }
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('bmi')) {
      // Dibuka langsung dari AnalysisResultPage — tetap fetch dari API
      final int lingkungan = (args['lingkungan'] ?? 0) as int;
      lingkunganAktif.value = tabs[lingkungan.clamp(0, 2)];
      selectedTab.value = lingkungan.clamp(0, 2);
    }
    fetchWorkoutPlan();
  }

  void setTab(int index) {
    selectedTab.value = index;
    lingkunganAktif.value = tabs[index];
    fetchWorkoutPlan();
  }

  /// Dipanggil oleh MainController saat navigasi dari AnalysisResultPage
  void loadData(Map<String, dynamic> args) {
    final int lingkungan = (args['lingkungan'] ?? 0) as int;
    lingkunganAktif.value = tabs[lingkungan.clamp(0, 2)];
    selectedTab.value = lingkungan.clamp(0, 2);
    fetchWorkoutPlan();
  }

  Future<void> fetchWorkoutPlan() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final data = await _service.getLatestWorkoutPlan(lingkungan: lingkunganAktif.value);
      if (data == null) {
        hasAnalysisData.value = false;
      } else {
        hasAnalysisData.value = true;
        _applyData(data);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _applyData(Map<String, dynamic> data) {
    kategoriBMI.value = data['kategori_tubuh'] ?? 'Normal';
    posturLabel.value = data['postur_label'] ?? 'standing';
    posturCatatan.value = data['postur_catatan'] ?? '';
    estimasiKalori.value = data['estimasi_kalori_total'] ?? 0;
    estimasiDurasi.value = data['estimasi_durasi_menit'] ?? 35;

    final utama = data['latihan_utama'] as Map<String, dynamic>?;
    if (utama != null) {
      workoutUtamaNama.value = utama['nama_latihan'] ?? '';
      workoutUtamaSet.value = utama['set_reps'] ?? '';
      workoutUtamaItem.value = WorkoutItem(
        nama: utama['nama_latihan'] ?? '',
        target: utama['target_otot'] ?? '',
        icon: _iconFromKey(utama['icon_key'] ?? 'fitness_center'),
        iconColor: _colorFromIcon(utama['icon_key'] ?? ''),
        setReps: utama['set_reps'] ?? '',
        kalori: utama['kalori_estimasi'] ?? 0,
      );
    } else {
      workoutUtamaItem.value = null;
    }

    workoutTambahan.value = _parseItems(data['latihan_tambahan']);
    workoutKoreksiPostur.value = _parseItems(data['latihan_koreksi_postur']);
  }

  List<WorkoutItem> _parseItems(dynamic rawList) {
    if (rawList == null || rawList is! List) return [];
    return rawList.map((item) {
      final m = item as Map<String, dynamic>;
      return WorkoutItem(
        nama: m['nama_latihan'] ?? '',
        target: m['target_otot'] ?? '',
        icon: _iconFromKey(m['icon_key'] ?? 'fitness_center'),
        iconColor: _colorFromIcon(m['icon_key'] ?? ''),
        setReps: m['set_reps'] ?? '',
        kalori: m['kalori_estimasi'] ?? 0,
      );
    }).toList();
  }

  IconData _iconFromKey(String key) {
    switch (key) {
      case 'directions_run':   return Icons.directions_run;
      case 'self_improvement': return Icons.self_improvement;
      case 'accessibility_new': return Icons.accessibility_new;
      case 'sports_gymnastics': return Icons.sports_gymnastics;
      default:                 return Icons.fitness_center;
    }
  }

  Color _colorFromIcon(String key) {
    switch (key) {
      case 'directions_run':   return const Color(0xFFE07B39);
      case 'self_improvement': return const Color(0xFF3BB88F);
      case 'accessibility_new': return const Color(0xFF9B59B6);
      case 'sports_gymnastics': return const Color(0xFF3BB88F);
      default:                 return const Color(0xFF4A90D9);
    }
  }

  void onNavTap(int index) {
    selectedNavIndex.value = index;
    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 1:
        Get.toNamed('/scan');
        break;
    }
  }
}
