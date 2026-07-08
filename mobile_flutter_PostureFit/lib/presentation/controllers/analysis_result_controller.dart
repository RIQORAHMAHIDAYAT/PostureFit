import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class AnalysisResultController extends GetxController {
  late final double tinggiBadan;
  late final double beratBadan;
  late final double umur;
  late final double lingkarPerut;
  late final int lingkungan; // 0=Rumah, 1=Gym, 2=Calisthenics
  late final String? imageUrl;           // Foto asli
  late final String? annotatedImageUrl;  // Foto + skeleton overlay MediaPipe
  late final String posturLabel;         // Hasil klasifikasi YOLOv8
  late final double posturConfidence;    // Confidence score YOLOv8 (0.0–1.0)

  final RxDouble bmi        = 0.0.obs;
  final RxString kategori   = ''.obs;
  /// Teks rekomendasi dari server (SAW engine)
  final RxString rekomendasiServer = ''.obs;
  /// Daftar rekomendasi dengan warna untuk tampilan card UI
  final RxList<Map<String, dynamic>> rekomendasi = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    tinggiBadan  = (args['tinggi']   ?? 170.0).toDouble();
    beratBadan   = (args['berat']    ?? 70.0).toDouble();
    umur         = (args['umur']     ?? 25.0).toDouble();
    lingkarPerut = (args['lingkar']  ?? 80.0).toDouble();
    lingkungan   = (args['lingkungan'] ?? 0) as int;
    imageUrl           = args['image_url']          as String?;
    annotatedImageUrl  = args['annotated_image_url'] as String?;
    posturLabel        = args['postur_label']        as String? ?? 'standing';
    posturConfidence   = (args['postur_confidence']  as num?)?.toDouble() ?? 0.0;

    // ── Prioritaskan data dari server ──────────────────────────────────────
    final serverBmi      = args['bmi'];
    final serverKategori = args['kategori_tubuh'] as String?;
    final serverRek      = args['rekomendasi']   as String?;

    if (serverBmi != null && serverKategori != null) {
      // Gunakan hasil SAW engine dari backend
      bmi.value      = (serverBmi as num).toDouble();
      kategori.value = serverKategori;
      if (serverRek != null) rekomendasiServer.value = serverRek;
    } else {
      // Fallback: hitung lokal jika tidak ada data server
      _hitungBMI();
    }

    // Selalu generate list rekomendasi UI berdasarkan kategori
    _generateRekomendasi();
  }

  // ── Postur Helpers ─────────────────────────────────────────────────────────

  /// Teks display postur yang ramah (Indonesian)
  String get posturDisplayName {
    switch (posturLabel.toLowerCase()) {
      case 'standing':  return 'Berdiri Tegak';
      case 'bending':   return 'Membungkuk';
      case 'sitting':   return 'Duduk';
      case 'squatting': return 'Jongkok';
      case 'lying':     return 'Berbaring';
      default:          return posturLabel;
    }
  }

  /// Catatan / peringatan terkait postur
  String get posturCatatan {
    switch (posturLabel.toLowerCase()) {
      case 'bending':
        return '⚠️ Terdeteksi kebiasaan membungkuk. Tambahkan latihan penguatan punggung atas dan peregangan dada.';
      case 'sitting':
        return '⚠️ Postur duduk terlalu lama terdeteksi. Prioritaskan peregangan hip flexor dan penguatan glute.';
      case 'squatting':
        return '⚠️ Posisi jongkok terdeteksi. Perhatikan keseimbangan dan kekuatan betis saat berlatih.';
      case 'lying':
        return '⚠️ Posisi rebah terdeteksi saat scan. Pastikan Anda berdiri tegak saat scan postur berikutnya.';
      default:
        return 'Postur Anda terdeteksi normal (berdiri tegak). Pertahankan postur baik ini!';
    }
  }

  /// Apakah postur bermasalah (bukan standing normal)
  bool get isPosturBermasalah => posturLabel.toLowerCase() != 'standing';

  /// Warna badge postur
  int get posturColor {
    switch (posturLabel.toLowerCase()) {
      case 'standing':  return 0xFF3BB88F; // hijau
      case 'bending':   return 0xFFE07B39; // oranye
      case 'sitting':   return 0xFF9B59B6; // ungu
      case 'squatting': return 0xFF4A90D9; // biru
      case 'lying':     return 0xFFE05252; // merah
      default:          return 0xFF4A90D9;
    }
  }

  /// Icon postur
  String get posturIconName {
    switch (posturLabel.toLowerCase()) {
      case 'standing':  return 'accessibility';
      case 'bending':   return 'warning';
      case 'sitting':   return 'chair';
      case 'squatting': return 'fitness_center';
      case 'lying':     return 'airline_seat_flat';
      default:          return 'accessibility';
    }
  }


  void _hitungBMI() {
    final tinggiM = tinggiBadan / 100;
    final nilaBMI = beratBadan / (tinggiM * tinggiM);
    bmi.value = double.parse(nilaBMI.toStringAsFixed(1));
    _tentukanKategori(nilaBMI);
    // _generateRekomendasi() dipanggil di onInit setelah blok ini
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

  /// Generate daftar rekomendasi card UI berdasarkan kategori.
  /// Mendukung kategori dari SAW engine (Obesitas, Skinnyfat, Kurus, Normal)
  /// dan kategori lokal (Gemuk).
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
    } else if (kat == 'Skinnyfat') {
      rekomendasi.value = [
        {'warna': 0xFF9B59B6, 'teks': 'Latihan beban 3–4x/minggu dengan compound movements (squat, deadlift, bench press).'},
        {'warna': 0xFF4A90D9, 'teks': 'Tingkatkan asupan protein 1.6–2.2 g per kg berat badan.'},
        {'warna': 0xFF3BB88F, 'teks': 'Cardio ringan 2x/minggu untuk menjaga kesehatan kardiovaskular.'},
        {'warna': 0xFFE07B39, 'teks': 'Fokus body recomposition: tambah otot sambil kurangi lemak.'},
      ];
    } else if (kat == 'Gemuk') {
      rekomendasi.value = [
        {'warna': 0xFFE07B39, 'teks': 'Kurangi asupan kalori 300–500 kkal/hari dari kebutuhan maintenance.'},
        {'warna': 0xFF4A90D9, 'teks': 'Prioritaskan kardio intensitas sedang 4–5x per minggu.'},
        {'warna': 0xFF3BB88F, 'teks': 'Perbanyak konsumsi sayuran dan protein tanpa lemak.'},
        {'warna': 0xFF9B59B6, 'teks': 'Kurangi makanan olahan, gula tambahan, dan minuman manis.'},
      ];
    } else {
      // Obesitas (dari SAW engine) atau kategori tidak dikenal
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
        'lingkungan': lingkungan,   // 0=Rumah, 1=Gym, 2=Calisthenics
        'postur_label': posturLabel, // Teruskan ke WorkoutPlanController
      },
    );
  }

  void onLihatHasil() {
    Get.toNamed(AppRoutes.imagePreview, arguments: {'imageUrl': imageUrl});
  }
  void onUbahData() => Get.back();
  void onBack() => Get.back();
}
