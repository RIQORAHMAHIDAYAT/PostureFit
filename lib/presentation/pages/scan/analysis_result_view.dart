import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
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

// ─── Lihat Hasil Gambar Button ────────────────────────────────────────────────

class _LihatHasilButton extends GetView<AnalysisResultController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.onLihatHasil,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF4A90D9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lihat Hasil Gambar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
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
