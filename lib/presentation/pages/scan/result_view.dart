import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/result_controller.dart';

class ResultView extends GetView<ResultController> {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      body: Column(
        children: [
          _ResultAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LihatHasilButton(),
                  const SizedBox(height: 20),
                  _SectionLabel('FOKUS UTAMA'),
                  const SizedBox(height: 8),
                  _FokusSelector(),
                  const SizedBox(height: 20),
                  _SectionLabel('UMUR'),
                  const SizedBox(height: 8),
                  _SliderCard(valueObs: controller.umur, unit: 'thn', min: 18, max: 100, onChanged: controller.setUmur),
                  const SizedBox(height: 16),
                  _SectionLabel('TINGGI BADAN'),
                  const SizedBox(height: 8),
                  _SliderCard(valueObs: controller.tinggiBadan, unit: 'cm', min: 150, max: 200, onChanged: controller.setTinggi),
                  const SizedBox(height: 16),
                  _SectionLabel('BERAT BADAN'),
                  const SizedBox(height: 8),
                  _SliderCard(valueObs: controller.beratBadan, unit: 'kg', min: 40, max: 120, onChanged: controller.setBerat),
                  const SizedBox(height: 16),
                  _SectionLabel('LINGKAR PERUT'),
                  const SizedBox(height: 8),
                  _SliderCard(valueObs: controller.lingkarPerut, unit: 'cm', min: 40, max: 100, onChanged: controller.setLingkar),
                  const SizedBox(height: 20),
                  _SectionLabel('LINGKUNGAN LATIHAN'),
                  const SizedBox(height: 8),
                  _LingkunganCard(),
                  SizedBox(height: 100 + bottomSafe),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _AnalysisButton(),
    );
  }
}

class _ResultAppBar extends GetView<ResultController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16, right: 16, bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF0D2137),
            Color(0xFF1A3A5C),
            Color(0xFF2E6099),
            Color(0xFF5A9ED4),
            Color(0xFFAAD4F5),
          ],
          stops: [0.0, 0.2, 0.5, 0.75, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
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
          const SizedBox(height: 12),
          const Text(
            'Bangun profil vitalitas Anda.',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Data presisi untuk hasil optimal. Kami menyusun perjalanan postur Anda berdasarkan fondasi fisik Anda.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _LihatHasilButton extends GetView<ResultController> {
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
            Text('Lihat Hasil Gambar',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppTheme.textSecondary(context),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _FokusSelector extends GetView<ResultController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() => Row(
          children: List.generate(controller.fokusOptions.length, (i) {
            final selected = controller.selectedFokus.value == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.setFokus(i),
                child: Container(
                  margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF4A90D9)
                        : AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF4A90D9)
                          : (isDark ? const Color(0xFF243B55) : const Color(0xFFD0E4F5)),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    controller.fokusOptions[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF4A90D9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ));
  }
}

class _SliderCard extends StatelessWidget {
  final RxDouble valueObs;
  final String unit;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderCard({
    required this.valueObs,
    required this.unit,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    valueObs.value.toInt().toString(),
                    style: const TextStyle(color: Color(0xFF4A90D9), fontSize: 36, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(unit, style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 14)),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  activeTrackColor: const Color(0xFF4A90D9),
                  inactiveTrackColor: isDark ? const Color(0xFF243B55) : const Color(0xFFD0E4F5),
                  thumbColor: const Color(0xFF4A90D9),
                  overlayColor: const Color(0x224A90D9),
                ),
                child: Slider(value: valueObs.value, min: min, max: max, onChanged: onChanged),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(min.toInt().toString(), style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 11)),
                  Text(max.toInt().toString(), style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 11)),
                ],
              ),
            ],
          ),
        ));
  }
}

class _LingkunganCard extends GetView<ResultController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _LingkunganItem(
            index: 0,
            icon: Icons.home_outlined,
            iconColor: const Color(0xFF4A90D9),
            title: 'Latihan di Rumah',
            subtitle: 'Peralatan terbatas',
            isLast: false,
          ),
          _LingkunganItem(
            index: 1,
            icon: Icons.fitness_center_rounded,
            iconColor: const Color(0xFFE07B39),
            title: 'Sesi GYM',
            subtitle: 'Akses peralatan lengkap',
            isLast: false,
          ),
          _LingkunganItem(
            index: 2,
            icon: Icons.sports_gymnastics_rounded,
            iconColor: const Color(0xFF3BB88F),
            title: 'Calisthenics',
            subtitle: 'Latihan beban tubuh sendiri',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _LingkunganItem extends GetView<ResultController> {
  final int index;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isLast;

  const _LingkunganItem({
    required this.index,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final selected = controller.selectedLingkungan.value == index;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: AppTheme.textPrimary(context), fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(subtitle, style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 11)),
                    ],
                  ),
                ),
                Switch(
                  value: selected,
                  onChanged: (val) {
                    if (val) controller.setLingkungan(index);
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF4A90D9),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: isDark ? const Color(0xFF243B55) : const Color(0xFFD0E4F5),
                ),
              ],
            ),
          ),
          if (!isLast)
            Divider(height: 1, thickness: 1, color: AppTheme.dividerColor(context), indent: 16, endIndent: 16),
        ],
      );
    });
  }
}

class _AnalysisButton extends GetView<ResultController> {
  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    return Container(
      color: AppTheme.bgColor(context),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomSafe),
      child: GestureDetector(
        onTap: controller.onAnalysis,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6AAEE8), Color(0xFF3A7FC1)]),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(color: const Color(0xFF4A90D9).withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 5)),
            ],
          ),
          child: const Center(
            child: Text('Analysis', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}