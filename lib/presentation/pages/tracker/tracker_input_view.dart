import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/home_controller.dart';

/// ============================================================
/// TrackerInputView — Halaman khusus catat tidur & hidrasi
/// Dipanggil ketika user tap kartu Durasi Tidur / Hidrasi
/// di Home. UI mirip ResultView (slider-card).
/// ============================================================
class TrackerInputView extends StatefulWidget {
  const TrackerInputView({super.key});

  @override
  State<TrackerInputView> createState() => _TrackerInputViewState();
}

class _TrackerInputViewState extends State<TrackerInputView> {
  late HomeController _ctrl;

  // ── nilai sementara (belum disimpan) ──────────────────────────
  late double _sleepHours;
  late double _hydrationMl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<HomeController>();
    final act = _ctrl.activity.value;
    _sleepHours   = act.sleepDuration.clamp(0.0, 12.0);
    _hydrationMl  = act.hydrationCurrent.clamp(0, 5000).toDouble();
  }

  // ── Simpan kedua nilai sekaligus ─────────────────────────────
  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final success = await _ctrl.updateSleepAndHydration(
        _sleepHours,
        _hydrationMl.toInt(),
      );
      if (success) {
        Get.back();
        Get.snackbar(
          'Tersimpan!',
          'Data tidur & hidrasi berhasil diperbarui.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4A90D9),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        Get.snackbar(
          'Gagal Menyimpan',
          'Periksa koneksi internet Anda dan coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Terjadi Kesalahan',
        'Gagal menyimpan data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      body: Column(
        children: [
          // ── AppBar ───────────────────────────────────────────
          _AppBar(),

          // ── Konten Slider ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── TIDUR ────────────────────────────────────
                  _SectionLabel(
                    icon: Icons.bedtime_rounded,
                    iconColor: AppColors.primary,
                    label: 'DURASI TIDUR',
                  ),
                  const SizedBox(height: 8),
                  _SliderCard(
                    value: _sleepHours,
                    unit: 'jam',
                    min: 0,
                    max: 12,
                    divisions: 48,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _sleepHours = v),
                    hint: 'Idealnya 7–9 jam per malam untuk pemulihan optimal.',
                  ),

                  const SizedBox(height: 28),

                  // ── HIDRASI ──────────────────────────────────
                  _SectionLabel(
                    icon: Icons.water_drop_rounded,
                    iconColor: AppColors.accent,
                    label: 'HIDRASI HARI INI',
                  ),
                  const SizedBox(height: 8),
                  _HydrationCard(
                    valueMl: _hydrationMl,
                    onChanged: (v) => setState(() => _hydrationMl = v),
                    onStep: (delta) {
                      final next = (_hydrationMl + delta).clamp(0.0, 5000.0);
                      setState(() => _hydrationMl = next);
                    },
                  ),

                  SizedBox(height: 80 + bottomSafe),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Tombol Simpan ──────────────────────────────────────
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomSafe),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// AppBar
// ──────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 24,
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
            onTap: Get.back,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Catat Aktivitas Harian',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pantau durasi tidur dan kecukupan cairan Anda hari ini.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Label bagian (ikon + teks)
// ──────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _SectionLabel({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.captionStyle.copyWith(
            color: AppTheme.textSecondary(context),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Slider Card — mirip _SliderCard di result_view.dart
// ──────────────────────────────────────────────────────────────────
class _SliderCard extends StatelessWidget {
  final double value;
  final String unit;
  final double min;
  final double max;
  final int divisions;
  final Color activeColor;
  final ValueChanged<double> onChanged;
  final String hint;

  const _SliderCard({
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.divisions,
    required this.activeColor,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  color: activeColor,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: activeColor,
              inactiveTrackColor: isDark
                  ? const Color(0xFF243B55)
                  : activeColor.withValues(alpha: 0.15),
              thumbColor: activeColor,
              overlayColor: activeColor.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                min.toStringAsFixed(0),
                style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 11),
              ),
              Text(
                max.toStringAsFixed(0),
                style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Hydration Card — slider + tombol +250/-250 ml
// ──────────────────────────────────────────────────────────────────
class _HydrationCard extends StatelessWidget {
  final double valueMl;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onStep;

  const _HydrationCard({
    required this.valueMl,
    required this.onChanged,
    required this.onStep,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = AppColors.accent;
    const targetMl = 2000.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nilai ml
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valueMl.toInt().toString(),
                style: const TextStyle(
                  color: accent,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'ml',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '/ ${targetMl.toInt()} ml',
                style: TextStyle(
                  color: AppTheme.textSecondary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: accent,
              inactiveTrackColor: isDark
                  ? const Color(0xFF243B55)
                  : accent.withValues(alpha: 0.15),
              thumbColor: accent,
              overlayColor: accent.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: valueMl,
              min: 0,
              max: 5000,
              divisions: 200,
              onChanged: onChanged,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 ml',
                  style: TextStyle(
                      color: AppTheme.textSecondary(context), fontSize: 11)),
              Text('5000 ml',
                  style: TextStyle(
                      color: AppTheme.textSecondary(context), fontSize: 11)),
            ],
          ),

          const SizedBox(height: 16),

          // Tombol cepat +/- 250 ml
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepButton(
                label: '−250 ml',
                color: accent,
                onTap: () => onStep(-250),
              ),
              const SizedBox(width: 16),
              _StepButton(
                label: '+250 ml',
                color: accent,
                filled: true,
                onTap: () => onStep(250),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            'Kebutuhan harian umumnya ±2000 ml. Sesuaikan dengan aktivitas Anda.',
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _StepButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Colors.white : color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
