import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/analysis_result_controller.dart';

class AnalysisResultView extends GetView<AnalysisResultController> {
  const AnalysisResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      body: Column(
        children: [
          _AnalysisHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LihatHasilButton(),
                  const SizedBox(height: 16),
                  _InfoGrid(),
                  const SizedBox(height: 16),
                  _BMIDistribusiCard(),
                  const SizedBox(height: 16),
                  _PosturCard(),
                  const SizedBox(height: 16),
                  _RekomendasiCard(),
                  const SizedBox(height: 24),
                  _ActionButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header (gradient + BMI score di dalam) ───────────────────────────────────

class _AnalysisHeader extends GetView<AnalysisResultController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final katColor = Color(controller.kategoriColor);
      return Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          bottom: 28,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryAppBarGradient,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
          boxShadow: AppColors.primaryAppBarShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: controller.onBack,
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Hasil Analisis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: controller.bmi.value.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Indeks Massa Tubuh (BMI)',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                decoration: BoxDecoration(
                  color: katColor.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: katColor.withValues(alpha: 0.5), width: 1),
                ),
                child: Text(
                  controller.kategoriBadgeText,
                  style: TextStyle(
                    color: katColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Foto Hasil Scan + Skeleton Anotasi ──────────────────────────────────────

class _LihatHasilButton extends GetView<AnalysisResultController> {
  @override
  Widget build(BuildContext context) {
    final annotatedUrl = controller.annotatedImageUrl;
    final originalUrl  = controller.imageUrl;
    // Gunakan annotated jika ada, fallback ke original
    final displayUrl = (annotatedUrl != null && annotatedUrl.isNotEmpty)
        ? annotatedUrl
        : originalUrl;

    if (displayUrl == null || displayUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    // Buat full URL
    final fullUrl = displayUrl.startsWith('http')
        ? displayUrl
        : '${AppConstants.baseUrl}$displayUrl';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HASIL SCAN POSTUR',
          style: TextStyle(
            color: Color(0xFF4A90D9),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.network(
                fullUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 220,
                    color: const Color(0xFF1E2D40),
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4A90D9)),
                    ),
                  );
                },
                errorBuilder: (context, _, __) => Container(
                  height: 180,
                  color: const Color(0xFF1E2D40),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined, color: Colors.white38, size: 40),
                        SizedBox(height: 8),
                        Text('Gambar tidak tersedia',
                            style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              // Badge overlay: "Skeleton Overlay"
              if (annotatedUrl != null && annotatedUrl.isNotEmpty)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.accessibility_new_rounded, color: Color(0xFF00E676), size: 14),
                        SizedBox(width: 5),
                        Text(
                          'Skeleton Overlay',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Info Grid 2x2 ────────────────────────────────────────────────────────────

class _InfoGrid extends GetView<AnalysisResultController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoGridItem(
                value: controller.tinggiBadan.toStringAsFixed(0),
                unit: 'cm',
                label: 'Tinggi Badan',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoGridItem(
                value: controller.beratBadan.toStringAsFixed(0),
                unit: 'kg',
                label: 'Berat Badan',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoGridItem(
                value: controller.umur.toStringAsFixed(0),
                unit: 'thn',
                label: 'Umur',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoGridItem(
                value: controller.lingkarPerut.toStringAsFixed(0),
                unit: 'cm',
                label: 'Lingkar Perut',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoGridItem extends StatelessWidget {
  final String value;
  final String unit;
  final String label;

  const _InfoGridItem({
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90D9).withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Distribusi BMI (per-kategori progress bar) ───────────────────────────────

class _BMIDistribusiCard extends GetView<AnalysisResultController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF243B55) : const Color(0xFFD0E4F5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90D9).withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DISTRIBUSI BMI',
            style: TextStyle(
              color: Color(0xFF4A90D9),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Obx(() => Column(
                children: [
                  _BMIBarRow(
                    label: 'Kurus (<18.5)',
                    color: const Color(0xFF4A90D9),
                    progress: controller.kururProgress,
                  ),
                  const SizedBox(height: 10),
                  _BMIBarRow(
                    label: 'Normal (<18.5 - 24.9)',
                    color: const Color(0xFF3BB88F),
                    progress: controller.normalProgress,
                  ),
                  const SizedBox(height: 10),
                  _BMIBarRow(
                    label: 'Gemuk (25 - 29.9)',
                    color: const Color(0xFFE07B39),
                    progress: controller.gemukProgress,
                  ),
                  const SizedBox(height: 10),
                  _BMIBarRow(
                    label: 'Obesitas (≥30)',
                    color: const Color(0xFFE05252),
                    progress: controller.obesitasProgress,
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class _BMIBarRow extends StatelessWidget {
  final String label;
  final Color color;
  final double progress;

  const _BMIBarRow({
    required this.label,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toStringAsFixed(0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 11),
            ),
            Text(
              '$pct%',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                color: AppTheme.inputBg(context),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Hasil Deteksi Postur ─────────────────────────────────────────────────────

class _PosturCard extends GetView<AnalysisResultController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final posturColor = Color(controller.posturColor);
    final isBermasalah = controller.isPosturBermasalah;

    // Icon per postur
    IconData posturIcon;
    switch (controller.posturLabel.toLowerCase()) {
      case 'standing':
        posturIcon = Icons.accessibility_new_rounded;
        break;
      case 'bending':
        posturIcon = Icons.warning_amber_rounded;
        break;
      case 'sitting':
        posturIcon = Icons.chair_alt_rounded;
        break;
      case 'squatting':
        posturIcon = Icons.sports_gymnastics_rounded;
        break;
      case 'lying':
        posturIcon = Icons.airline_seat_flat_rounded;
        break;
      default:
        posturIcon = Icons.accessibility_new_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: posturColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: posturColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Text(
            'HASIL DETEKSI POSTUR',
            style: TextStyle(
              color: posturColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          // ── Row: icon + label + badge ─────────────────────────────────────
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: posturColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(posturIcon, color: posturColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.posturDisplayName,
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Model AI: YOLOv8 Classifier',
                      style: TextStyle(
                        color: AppTheme.textSecondary(context),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge status postur
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: posturColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: posturColor.withValues(alpha: 0.4), width: 1),
                ),
                child: Text(
                  isBermasalah ? 'Perlu Koreksi' : 'Normal',
                  style: TextStyle(
                    color: posturColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Confidence Score YOLOv8 ──────────────────────────────────────
          Row(
            children: [
              Text(
                'Confidence Model:',
                style: TextStyle(
                  color: AppTheme.textSecondary(context),
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: controller.posturConfidence.clamp(0.0, 1.0),
                    backgroundColor: posturColor.withValues(alpha: 0.12),
                    color: posturColor,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(controller.posturConfidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: posturColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Catatan postur ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: posturColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isBermasalah
                      ? Icons.info_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  color: posturColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.posturCatatan,
                    style: TextStyle(
                      color: isDark
                          ? posturColor.withValues(alpha: 0.9)
                          : posturColor.withValues(alpha: 0.85),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Rekomendasi ──────────────────────────────────────────────────────────────

class _RekomendasiCard extends GetView<AnalysisResultController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 12),
          child: Text(
            'REKOMENDASI PROGRAM',
            style: TextStyle(
              color: Color(0xFF4A90D9),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
        // ── Dasar Pengambilan Keputusan ─────────────────────────────────────
        Obx(() {
          final kategori  = controller.kategori.value;
          final bmiVal    = controller.bmi.value.toStringAsFixed(1);
          final postur    = controller.posturDisplayName;
          final isNormal  = !controller.isPosturBermasalah;
          final posturColor = Color(controller.posturColor);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4A90D9).withValues(alpha: 0.08),
                  const Color(0xFF4A90D9).withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4A90D9).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        color: Color(0xFF4A90D9), size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'Dasar Pengambilan Keputusan',
                      style: TextStyle(
                        color: const Color(0xFF4A90D9),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Baris BMI
                _DecisionRow(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Kategori BMI',
                  value: '$kategori (BMI $bmiVal)',
                  color: Color(controller.kategoriColor),
                ),
                const SizedBox(height: 6),
                // Baris Postur
                _DecisionRow(
                  icon: Icons.accessibility_new_rounded,
                  label: 'Postur Terdeteksi',
                  value: postur,
                  color: posturColor,
                ),
                const SizedBox(height: 6),
                // Baris Model AI
                _DecisionRow(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Metode Scoring',
                  value: 'SAW (5 kriteria: BMI 30% + WHtR 25% + LP 15% + Umur 10% + Visual 20%)',
                  color: const Color(0xFF3BB88F),
                ),
                const SizedBox(height: 10),
                // Kalimat kesimpulan
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isNormal
                        ? 'Program dirancang khusus untuk tubuh $kategori dengan postur $postur yang baik.'
                        : 'Program menggabungkan latihan untuk tubuh $kategori + latihan koreksi postur $postur.',
                    style: const TextStyle(
                      color: Color(0xFF4A90D9),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        // ── Daftar Rekomendasi ───────────────────────────────────────────────
        Obx(() => Column(
              children: List.generate(controller.rekomendasi.length, (i) {
                final item = controller.rekomendasi[i];
                final color = Color(item['warna'] as int);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A90D9).withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item['teks'] as String,
                          style: TextStyle(
                            color: AppTheme.textPrimary(context),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            )),
      ],
    );
  }
}

// Helper widget satu baris keputusan
class _DecisionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DecisionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppTheme.textSecondary(context),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary(context),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}


// ─── Action Buttons (vertikal) ────────────────────────────────────────────────

class _ActionButtons extends GetView<AnalysisResultController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        GestureDetector(
          onTap: controller.onSimpan,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6AAEE8), Color(0xFF3A7FC1)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A90D9).withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Simpan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: controller.onUbahData,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2E4A) : const Color(0xFFD8E6F3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                'Ubah Data',
                style: TextStyle(
                  color: isDark ? const Color(0xFF6AAEE8) : const Color(0xFF4A7AAF),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
