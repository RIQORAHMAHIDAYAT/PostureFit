import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class AnalysisResultController extends GetxController {
  late final double tinggiBadan;
  late final double beratBadan;
  late final double umur;
  late final double lingkarPerut;
  late final int lingkungan; // 0=Rumah, 1=Gym, 2=Calisthenics

  final RxDouble bmi = 0.0.obs;
  final RxString kategori = ''.obs;
  final RxList<Map<String, dynamic>> rekomendasi = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    tinggiBadan = (args['tinggi'] ?? 170.0).toDouble();
    beratBadan = (args['berat'] ?? 70.0).toDouble();
    umur = (args['umur'] ?? 25.0).toDouble();
    lingkarPerut = (args['lingkar'] ?? 80.0).toDouble();
    lingkungan = (args['lingkungan'] ?? 0) as int;
    _hitungBMI();
  }

  void _hitungBMI() {
    final tinggiM = tinggiBadan / 100;
    final nilaBMI = beratBadan / (tinggiM * tinggiM);
    bmi.value = double.parse(nilaBMI.toStringAsFixed(1));
    _tentukanKategori(nilaBMI);
    _generateRekomendasi();
  }

  void _tentukanKategori(double nilaBMI) {
    if (nilaBMI < 18.5) {
      kategori.value = 'Kurus';
    } else if (nilaBMI < 25.0) {
      kategori.value = 'Normal';
    } else if (nilaBMI < 30.0) {
      kategori.value = 'Gemuk';
    } else {
      kategori.value = 'Obesitas';
    }
  }

  void _generateRekomendasi() {
    final kat = kategori.value;
    if (kat == 'Kurus') {
      rekomendasi.value = [
        {'warna': 0xFF4A90D9, 'teks': 'Tingkatkan asupan kalori 300–500 kkal/hari di atas kebutuhan.'},
        {'warna': 0xFF3BB88F, 'teks': 'Fokus latihan kekuatan (strength training) 3–4x per minggu.'},
        {'warna': 0xFFE07B39, 'teks': 'Konsumsi protein minimal 1.6 g per kg berat badan.'},
        {'warna': 0xFF9B59B6, 'teks': 'Istirahat cukup 7–9 jam agar otot dapat berkembang optimal.'},
      ];
    } else if (kat == 'Normal') {
      rekomendasi.value = [
        {'warna': 0xFF3BB88F, 'teks': 'Pertahankan pola makan seimbang dengan gizi lengkap.'},
        {'warna': 0xFF4A90D9, 'teks': 'Lakukan aktivitas fisik minimal 150 menit per minggu.'},
        {'warna': 0xFFE07B39, 'teks': 'Kombinasikan latihan kardio dan kekuatan untuk kebugaran optimal.'},
        {'warna': 0xFF9B59B6, 'teks': 'Monitor berat badan secara rutin setiap 2 minggu sekali.'},
      ];
    } else if (kat == 'Gemuk') {
      rekomendasi.value = [
        {'warna': 0xFFE07B39, 'teks': 'Kurangi asupan kalori 300–500 kkal/hari dari kebutuhan maintenance.'},
        {'warna': 0xFF4A90D9, 'teks': 'Prioritaskan kardio intensitas sedang 4–5x per minggu.'},
        {'warna': 0xFF3BB88F, 'teks': 'Perbanyak konsumsi sayuran dan protein tanpa lemak.'},
        {'warna': 0xFF9B59B6, 'teks': 'Kurangi makanan olahan, gula tambahan, dan minuman manis.'},
      ];
    } else {
      rekomendasi.value = [
        {'warna': 0xFFE05252, 'teks': 'Konsultasi dengan dokter atau ahli gizi untuk program penurunan berat badan.'},
        {'warna': 0xFFE07B39, 'teks': 'Mulai dengan aktivitas ringan seperti jalan kaki 30 menit setiap hari.'},
        {'warna': 0xFF4A90D9, 'teks': 'Kurangi makanan tinggi kalori, lemak jenuh, dan gula.'},
        {'warna': 0xFF3BB88F, 'teks': 'Target penurunan berat badan realistis: 0.5–1 kg per minggu.'},
      ];
    }
  }

  // Progress BMI: posisi pada skala 10–40
  double get bmiProgress {
    final clamped = bmi.value.clamp(10.0, 40.0);
    return (clamped - 10.0) / 30.0;
  }

  int get kategoriColor {
    switch (kategori.value) {
      case 'Kurus':
        return 0xFF4A90D9;
      case 'Normal':
        return 0xFF3BB88F;
      case 'Gemuk':
        return 0xFFE07B39;
      case 'Obesitas':
        return 0xFFE05252;
      default:
        return 0xFF4A90D9;
    }
  }

  // Progress per zona BMI
  double get kururProgress {
    if (bmi.value >= 18.5) return 1.0;
    return (bmi.value / 18.5).clamp(0.0, 1.0);
  }

  double get normalProgress {
    if (bmi.value < 18.5) return 0.0;
    if (bmi.value >= 24.9) return 1.0;
    return ((bmi.value - 18.5) / (24.9 - 18.5)).clamp(0.0, 1.0);
  }

  double get gemukProgress {
    if (bmi.value < 25.0) return 0.0;
    if (bmi.value >= 29.9) return 1.0;
    return ((bmi.value - 25.0) / (29.9 - 25.0)).clamp(0.0, 1.0);
  }

  double get obesitasProgress {
    if (bmi.value < 30.0) return 0.0;
    return ((bmi.value - 30.0) / 10.0).clamp(0.0, 1.0);
  }

  String get kategoriBadgeText {
    switch (kategori.value) {
      case 'Kurus':
        return 'Kurus - Berat badan kurang';
      case 'Normal':
        return 'Normal - Berat badan ideal';
      case 'Gemuk':
        return 'Gemuk - Kelebihan berat badan';
      case 'Obesitas':
        return 'Obesitas - Sangat kelebihan berat badan';
      default:
        return kategori.value;
    }
  }

  void onSimpan() {
    Get.offAllNamed(
      '/main',
      arguments: {
        'initialTab': 2,
        'bmi': bmi.value,
        'kategori': kategori.value,
        'tinggi': tinggiBadan,
        'berat': beratBadan,
        'umur': umur,
        'lingkar': lingkarPerut,
        'lingkungan': lingkungan, // 0=Rumah, 1=Gym, 2=Calisthenics
      },
    );
  }

  void onLihatHasil() {
    Get.toNamed(AppRoutes.imagePreview);
  }
  void onUbahData() => Get.back();
  void onBack() => Get.back();
}
