import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkoutItem {
  final String nama;
  final String target;
  final IconData icon;
  final Color iconColor;

  const WorkoutItem({
    required this.nama,
    required this.target,
    required this.icon,
    required this.iconColor,
  });
}

class WorkoutPlanController extends GetxController {
  // Data dari AnalysisResultPage (mutable agar bisa di-assign ulang via loadData)
  double bmi = 0.0;
  String kategoriBMI = 'Normal';
  double tinggiBadan = 0.0;
  double beratBadan = 0.0;
  double umur = 0.0;
  double lingkarPerut = 0.0;

  // State
  final RxInt selectedTab = 0.obs;
  final RxDouble progress = 0.85.obs;
  final RxInt tugasSelesai = 4.obs;
  final RxInt tugasTotal = 5.obs;
  final RxInt kalori = 420.obs;
  final RxInt durasi = 35.obs;
  final RxInt selectedNavIndex = 2.obs;

  /// true jika halaman dibuka dari AnalysisResultPage (ada data BMI)
  /// false jika dibuka langsung dari Home (belum ada analisis)
  final RxBool hasAnalysisData = false.obs;

  final List<String> tabs = ['Rumah', 'Gym', 'Calisthenics'];

  // Workout utama & tambahan per tab & kategori
  final RxString workoutUtamaNama = ''.obs;
  final RxString workoutUtamaSet = ''.obs;
  final RxList<WorkoutItem> workoutTambahan = <WorkoutItem>[].obs;

  String get fokusLatihan {
    switch (kategoriBMI) {
      case 'Kurus':
        return 'Strength & Bulking';
      case 'Normal':
        return 'Maintenance & Kebugaran';
      case 'Gemuk':
        return 'Fat Loss & Cardio';
      case 'Obesitas':
        return 'Mobilitas & Core';
      default:
        return 'Umum';
    }
  }

  String get tanggal {
    final now = DateTime.now();
    const hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${hari[now.weekday - 1]}, ${now.day} ${bulan[now.month - 1]} ${now.year}';
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('bmi')) {
      // Dibuka dari AnalysisResultPage
      hasAnalysisData.value = true;
      bmi = (args['bmi'] ?? 22.0).toDouble();
      kategoriBMI = args['kategori'] ?? 'Normal';
      tinggiBadan = (args['tinggi'] ?? 170.0).toDouble();
      beratBadan = (args['berat'] ?? 70.0).toDouble();
      umur = (args['umur'] ?? 25.0).toDouble();
      lingkarPerut = (args['lingkar'] ?? 80.0).toDouble();
      // Prioritaskan tab sesuai pilihan lingkungan dari ResultPage
      final int lingkungan = (args['lingkungan'] ?? 0) as int;
      selectedTab.value = lingkungan.clamp(0, tabs.length - 1);
    } else {
      // Dibuka langsung dari Home tanpa data analisis
      hasAnalysisData.value = false;
      bmi = 0.0;
      kategoriBMI = 'Normal';
      tinggiBadan = 0.0;
      beratBadan = 0.0;
      umur = 0.0;
      lingkarPerut = 0.0;
      selectedTab.value = 0;
    }
    _loadWorkout();
  }

  void setTab(int index) {
    selectedTab.value = index;
    _loadWorkout();
  }

  /// Dipanggil oleh MainController saat navigasi dari AnalysisResultPage
  void loadData(Map<String, dynamic> args) {
    hasAnalysisData.value = true;
    bmi = (args['bmi'] ?? 0.0).toDouble();
    kategoriBMI = args['kategori'] ?? 'Normal';
    tinggiBadan = (args['tinggi'] ?? 0.0).toDouble();
    beratBadan = (args['berat'] ?? 0.0).toDouble();
    umur = (args['umur'] ?? 0.0).toDouble();
    lingkarPerut = (args['lingkar'] ?? 0.0).toDouble();
    // Prioritaskan tab sesuai pilihan lingkungan dari ResultPage
    final int lingkungan = (args['lingkungan'] ?? 0) as int;
    selectedTab.value = lingkungan.clamp(0, tabs.length - 1);
    _loadWorkout();
  }

  void _loadWorkout() {
    final tab = tabs[selectedTab.value];
    final kat = kategoriBMI;

    // Workout utama
    final mainMap = {
      'Kurus': {
        'Rumah': ['Wall Squats', '4 Set'],
        'Gym': ['Barbell Squat', '5 Set'],
        'Calisthenics': ['Pistol Squat', '4 Set'],
      },
      'Normal': {
        'Rumah': ['Push-Up Circuit', '3 Set'],
        'Gym': ['Bench Press', '4 Set'],
        'Calisthenics': ['Muscle-Up', '3 Set'],
      },
      'Gemuk': {
        'Rumah': ['Jumping Jacks', '4 Set'],
        'Gym': ['Treadmill HIIT', '5 Sesi'],
        'Calisthenics': ['Burpees', '4 Set'],
      },
      'Obesitas': {
        'Rumah': ['Wall Squats', '2 Set'],
        'Gym': ['Elliptical Cardio', '3 Sesi'],
        'Calisthenics': ['Chair Dips', '2 Set'],
      },
    };

    final main = mainMap[kat]?[tab] ?? ['Wall Squats', '3 Set'];
    workoutUtamaNama.value = main[0];
    workoutUtamaSet.value = main[1];

    // Workout tambahan
    final tambahanMap = {
      'Kurus': {
        'Rumah': [
          WorkoutItem(nama: 'Diamond Pushups', target: 'Trisep & Dada', icon: Icons.fitness_center, iconColor: const Color(0xFF4A90D9)),
          WorkoutItem(nama: 'Plank Hold', target: 'Stabilitas Inti', icon: Icons.self_improvement, iconColor: const Color(0xFF3BB88F)),
          WorkoutItem(nama: 'Peregangan Cat-Cow', target: 'Mobilitas Tulang Belakang', icon: Icons.accessibility_new, iconColor: const Color(0xFF9B59B6)),
          WorkoutItem(nama: 'Glute Bridge', target: 'Gluteus & Hamstring', icon: Icons.sports_gymnastics, iconColor: const Color(0xFF3BB88F)),
        ],
        'Gym': [
          WorkoutItem(nama: 'Dumbbell Row', target: 'Punggung & Bisep', icon: Icons.fitness_center, iconColor: const Color(0xFF4A90D9)),
          WorkoutItem(nama: 'Leg Press', target: 'Paha & Betis', icon: Icons.directions_run, iconColor: const Color(0xFF3BB88F)),
          WorkoutItem(nama: 'Cable Fly', target: 'Dada', icon: Icons.sports_gymnastics, iconColor: const Color(0xFFE07B39)),
          WorkoutItem(nama: 'Lat Pulldown', target: 'Punggung Atas', icon: Icons.self_improvement, iconColor: const Color(0xFF9B59B6)),
        ],
        'Calisthenics': [
          WorkoutItem(nama: 'Pull-Up', target: 'Punggung & Bisep', icon: Icons.fitness_center, iconColor: const Color(0xFF4A90D9)),
          WorkoutItem(nama: 'Dip', target: 'Trisep & Dada', icon: Icons.sports_gymnastics, iconColor: const Color(0xFF3BB88F)),
          WorkoutItem(nama: 'Hollow Hold', target: 'Core', icon: Icons.self_improvement, iconColor: const Color(0xFF9B59B6)),
          WorkoutItem(nama: 'L-Sit', target: 'Core & Hip Flexor', icon: Icons.accessibility_new, iconColor: const Color(0xFFE07B39)),
        ],
      },
      'Normal': {
        'Rumah': [
          WorkoutItem(nama: 'Diamond Pushups', target: 'Trisep & Dada', icon: Icons.fitness_center, iconColor: const Color(0xFF4A90D9)),
          WorkoutItem(nama: 'Plank Hold', target: 'Stabilitas Inti', icon: Icons.self_improvement, iconColor: const Color(0xFF3BB88F)),
          WorkoutItem(nama: 'Peregangan Cat-Cow', target: 'Mobilitas Tulang Belakang', icon: Icons.accessibility_new, iconColor: const Color(0xFF9B59B6)),
          WorkoutItem(nama: 'Glute Bridge', target: 'Gluteus & Hamstring', icon: Icons.sports_gymnastics, iconColor: const Color(0xFF3BB88F)),
        ],
        'Gym': [
          WorkoutItem(nama: 'Incline Press', target: 'Dada Atas', icon: Icons.fitness_center, iconColor: const Color(0xFF4A90D9)),
          WorkoutItem(nama: 'Deadlift', target: 'Punggung & Hamstring', icon: Icons.sports_gymnastics, iconColor: const Color(0xFF3BB88F)),
          WorkoutItem(nama: 'Cable Crunch', target: 'Core', icon: Icons.self_improvement, iconColor: const Color(0xFF9B59B6)),
          WorkoutItem(nama: 'Shoulder Press', target: 'Bahu', icon: Icons.accessibility_new, iconColor: const Color(0xFFE07B39)),
        ],
        'Calisthenics': [
          WorkoutItem(nama: 'Archer Push-Up', target: 'Dada & Trisep', icon: Icons.fitness_center, iconColor: const Color(0xFF4A90D9)),
          WorkoutItem(nama: 'Australian Pull-Up', target: 'Punggung', icon: Icons.sports_gymnastics, iconColor: const Color(0xFF3BB88F)),
          WorkoutItem(nama: 'Plank Shoulder Tap', target: 'Core & Bahu', icon: Icons.self_improvement, iconColor: const Color(0xFF9B59B6)),
          WorkoutItem(nama: 'Jump Squat', target: 'Paha & Kardio', icon: Icons.directions_run, iconColor: const Color(0xFFE07B39)),
        ],
      },
      'Gemuk': {
        'Rumah': [
          WorkoutItem(nama: 'High Knees', target: 'Kardio & Core', icon: Icons.directions_run, iconColor: const Color(0xFFE07B39)),
          WorkoutItem(nama: 'Mountain Climber', target: 'Kardio & Core', icon: Icons.fitness_center, iconColor: const Color(0xFF4A90D9)),
          WorkoutItem(nama: 'Peregangan Cat-Cow', target: 'Mobilitas Tulang Belakang', icon: Icons.accessibility_new, iconColor: const Color(0xFF9B59B6)),
          WorkoutItem(nama: 'Glute Bridge', target: 'Gluteus & Hamstring', icon: Icons.sports_gymnastics, iconColor: const Color(0xFF3BB88F)),
        ],
        'Gym': [
          WorkoutItem(nama: 'Rowing Machine', target: 'Punggung & Kardio', icon: Icons.fitness_center, iconColor: const Color(0xFF4A90D9)),
          WorkoutItem(nama: 'Leg Press', target: 'Paha', icon: Icons.sports_gymnastics, iconColor: const Color(0xFF3BB88F)),
          WorkoutItem(nama: 'Cable Row', target: 'Punggung Tengah', icon: Icons.self_improvement, iconColor: const Color(0xFF9B59B6)),
          WorkoutItem(nama: 'Battle Rope', target: 'Full Body Kardio', icon: Icons.directions_run, iconColor: const Color(0xFFE07B39)),
        ],
        'Calisthenics': [
          WorkoutItem(nama: 'Jump Rope', target: 'Kardio', icon: Icons.directions_run, iconColor: const Color(0xFFE07B39)),
          WorkoutItem(nama: 'Box Jump', target: 'Paha & Kardio', icon: Icons.fitness_center, iconColor: const Color(0xFF4A90D9)),
          WorkoutItem(nama: 'Plank Hold', target: 'Core', icon: Icons.self_improvement, iconColor: const Color(0xFF3BB88F)),
          WorkoutItem(nama: 'Bear Crawl', target: 'Full Body', icon: Icons.sports_gymnastics, iconColor: const Color(0xFF9B59B6)),
        ],
      },
      'Obesitas': {
        'Rumah': [
          WorkoutItem(nama: 'Diamond Pushups', target: 'Trisep & Dada', icon: Icons.fitness_center, iconColor: const Color(0xFF4A90D9)),
          WorkoutItem(nama: 'Plank Hold', target: 'Stabilitas Inti', icon: Icons.self_improvement, iconColor: const Color(0xFF3BB88F)),
          WorkoutItem(nama: 'Peregangan Cat-Cow', target: 'Mobilitas Tulang Belakang', icon: Icons.accessibility_new, iconColor: const Color(0xFF9B59B6)),
          WorkoutItem(nama: 'Glute Bridge', target: 'Gluteus & Hamstring', icon: Icons.sports_gymnastics, iconColor: const Color(0xFF3BB88F)),
        ],
        'Gym': [
          WorkoutItem(nama: 'Seated Row', target: 'Punggung', icon: Icons.fitness_center, iconColor: const Color(0xFF4A90D9)),
          WorkoutItem(nama: 'Leg Extension', target: 'Paha Depan', icon: Icons.sports_gymnastics, iconColor: const Color(0xFF3BB88F)),
          WorkoutItem(nama: 'Cable Pulldown', target: 'Punggung Atas', icon: Icons.self_improvement, iconColor: const Color(0xFF9B59B6)),
          WorkoutItem(nama: 'Standing Calf Raise', target: 'Betis', icon: Icons.accessibility_new, iconColor: const Color(0xFFE07B39)),
        ],
        'Calisthenics': [
          WorkoutItem(nama: 'Wall Push-Up', target: 'Dada & Trisep', icon: Icons.fitness_center, iconColor: const Color(0xFF4A90D9)),
          WorkoutItem(nama: 'Seated Leg Raise', target: 'Core', icon: Icons.self_improvement, iconColor: const Color(0xFF3BB88F)),
          WorkoutItem(nama: 'Peregangan Leher', target: 'Leher & Bahu', icon: Icons.accessibility_new, iconColor: const Color(0xFF9B59B6)),
          WorkoutItem(nama: 'Ankle Circles', target: 'Pergelangan Kaki', icon: Icons.sports_gymnastics, iconColor: const Color(0xFFE07B39)),
        ],
      },
    };

    workoutTambahan.value = tambahanMap[kat]?[tab] ?? tambahanMap['Normal']!['Rumah']!;
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
      case 3:
        // Edukasi
        break;
      case 4:
        // Profile
        break;
    }
  }
}
