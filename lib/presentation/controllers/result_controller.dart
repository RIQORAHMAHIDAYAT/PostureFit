import 'profile_controller.dart';
import 'scan_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../data/services/assessment_service.dart';
import '../../data/services/activity_log_service.dart';

class ResultController extends GetxController {
  final _assessmentService = AssessmentService();
  final _activityLogService = ActivityLogService();

  // ── State ─────────────────────────────────────────────────────────────────
  final RxInt    selectedFokus     = 0.obs;
  final RxDouble umur              = 25.0.obs;
  final RxDouble tinggiBadan       = 170.0.obs;
  final RxDouble beratBadan        = 65.0.obs;
  final RxDouble lingkarPerut      = 75.0.obs;
  final RxInt    selectedLingkungan = (-1).obs;
  final RxBool   isLoading         = false.obs;

  final List<String> fokusOptions = [
    'Defisit Kalori',
    'Surplus Kalori',
    'Pertahankan',
  ];

  // ── Setters ───────────────────────────────────────────────────────────────
  void setFokus(int index)     => selectedFokus.value = index;
  void setUmur(double v)       => umur.value = v;
  void setTinggi(double v)     => tinggiBadan.value = v;
  void setBerat(double v)      => beratBadan.value = v;
  void setLingkar(double v)    => lingkarPerut.value = v;

  /// Pilih lingkungan latihan (radio — hanya satu yang aktif)
  void setLingkungan(int index) => selectedLingkungan.value = index;

  // ── Actions ───────────────────────────────────────────────────────────────

  void onLihatHasil() {
    Get.toNamed(AppRoutes.imagePreview);
  }

  /// Kirim data ke backend → navigasi ke halaman hasil dengan data dari server.
  Future<void> onAnalysis() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      String imagePath = '';
      List<int>? imageBytes;

      // Ambil berkas scan dari ScanController yang aktif
      if (Get.isRegistered<ScanController>()) {
        final scanCtrl = Get.find<ScanController>();
        imagePath = scanCtrl.capturedPath.value;
        imageBytes = scanCtrl.capturedBytes.value;
      }

      final result = await _assessmentService.generateAssessment(
        tinggi:        tinggiBadan.value,
        berat:         beratBadan.value,
        umur:          umur.value.toInt(),
        lingkar:       lingkarPerut.value,
        imagePath:     imagePath,
        imageBytes:    imageBytes,
        fokusPilihan:  fokusOptions[selectedFokus.value],
      );

      // Catat aktivitas analisis postur berhasil dengan email aktif (jika ada)
      final kategori = result['kategori_tubuh'] ?? '-';
      String? activeEmail;
      try {
        if (Get.isRegistered<ProfileController>()) {
          activeEmail = Get.find<ProfileController>().email.value;
        }
      } catch (_) {}

      await _activityLogService.saveLog(
        icon: 'fitness_center',
        title: 'Analisis Postur',
        desc: 'Melakukan analisis postur tubuh dengan hasil kategori: $kategori.',
        email: activeEmail,
      );

      // Navigasi ke halaman hasil dengan data dari server
      Get.toNamed(
        '/analysis-result',
        arguments: {
          'tinggi':        tinggiBadan.value,
          'berat':         beratBadan.value,
          'umur':          umur.value,
          'lingkar':       lingkarPerut.value,
          'lingkungan':    selectedLingkungan.value < 0 ? 0 : selectedLingkungan.value,
          // Data dari server (SAW engine)
          'bmi':           result['bmi'],
          'kategori':      result['kategori_tubuh'],
          'kategori_tubuh': result['kategori_tubuh'],
          'rekomendasi':   result['rekomendasi'],
          'saw_scores':    result['saw_scores'],
          'image_url':     result['image_url'],

          // Hasil deteksi postur dari model YOLOv8
          'postur_label':       result['postur_label'] ?? 'standing',
          'postur_confidence':  result['postur_confidence'] ?? 0.0,
          'annotated_image_url': result['annotated_image_url'],
        },
      );
    } catch (e) {
      Get.snackbar(
        'Analisis Gagal',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE05252),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onBack() => Get.back();
}

