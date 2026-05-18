import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/workout_plan_controller.dart';

// WorkoutPlanBody: dipakai oleh MainPage (IndexedStack) — tanpa bottom nav
class WorkoutPlanBody extends GetView<WorkoutPlanController> {
  const WorkoutPlanBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      body: Column(
        children: [
          _WorkoutHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NoAnalysisBanner(),
                  _StatRow(),
                  const SizedBox(height: 20),
                  _TabBar(),
                  const SizedBox(height: 16),
                  _WorkoutUtamaCard(),
                  const SizedBox(height: 20),
                  _WorkoutTambahanSection(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// WorkoutPlanView: digunakan saat navigasi dari AnalysisResultView (Get.offAllNamed)
class WorkoutPlanView extends GetView<WorkoutPlanController> {
  const WorkoutPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: WorkoutPlanBody(),
    );
  }
}


// ─── Banner: belum ada data analisis ─────────────────────────────────────────

class _NoAnalysisBanner extends GetView<WorkoutPlanController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      if (controller.hasAnalysisData.value) return const SizedBox.shrink();
      return GestureDetector(
        onTap: () => Get.toNamed('/scan'),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2000) : const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF6B5000) : const Color(0xFFFFD966),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: isDark ? const Color(0xFFFFD966) : const Color(0xFFB08000), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Belum ada data analisis. Lakukan analisis BMI terlebih dahulu untuk mendapatkan rencana latihan yang personal.',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFFFD966) : const Color(0xFF7A5800),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE07B39),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Mulai',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _WorkoutHeader extends GetView<WorkoutPlanController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryAppBarGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: AppColors.primaryAppBarShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Workout Plan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Obx(() => Text(
                '${controller.tanggal}  –  Fokus: ${controller.hasAnalysisData.value ? controller.fokusLatihan : "Umum"}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.5,
                ),
              )),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Obx(() {
              final pct = (controller.progress.value * 100).toStringAsFixed(0);
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress hari ini',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$pct% Selesai',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: controller.progress.value,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Row ─────────────────────────────────────────────────────────────────

class _StatRow extends GetView<WorkoutPlanController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '${controller.tugasSelesai.value} / ${controller.tugasTotal.value}',
                label: 'Tugas Selesai',
                valueColor: const Color(0xFF4A90D9),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                value: '${controller.kalori.value} kkal',
                label: 'Terbakar',
                valueColor: const Color(0xFF3BB88F),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                value: '${controller.durasi.value} mnt',
                label: 'Durasi',
                valueColor: const Color(0xFFE07B39),
              ),
            ),
          ],
        ));
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90D9).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Tab Bar ──────────────────────────────────────────────────────────────────

class _TabBar extends GetView<WorkoutPlanController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: List.generate(controller.tabs.length, (i) {
            final selected = controller.selectedTab.value == i;
            return GestureDetector(
              onTap: () => controller.setTab(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF2E6099)
                      : AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    if (selected)
                      BoxShadow(
                        color: const Color(0xFF2E6099).withValues(alpha: 0.30),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Text(
                  controller.tabs[i],
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF4A90D9),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }),
        ));
  }
}

// ─── Workout Utama Card ───────────────────────────────────────────────────────

class _WorkoutUtamaCard extends GetView<WorkoutPlanController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() => Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A90D9).withValues(alpha: 0.09),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF243B55) : const Color(0xFFEAF3FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.directions_run_rounded,
                  color: Color(0xFF4A90D9),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tugas saat ini',
                      style: TextStyle(
                        color: AppTheme.textSecondary(context),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.workoutUtamaNama.value,
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E6099),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  controller.workoutUtamaSet.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// ─── Workout Tambahan Section ─────────────────────────────────────────────────

class _WorkoutTambahanSection extends GetView<WorkoutPlanController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Latihan Lainnya',
          style: TextStyle(
            color: Color(0xFF4A90D9),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Obx(() => Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A90D9).withValues(alpha: 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.workoutTambahan.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: AppTheme.dividerColor(context),
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (_, i) {
                  final item = controller.workoutTambahan[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: item.iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon,
                              color: item.iconColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nama,
                                style: TextStyle(
                                  color: AppTheme.textPrimary(context),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Target: ${item.target}',
                                style: TextStyle(
                                  color: AppTheme.textSecondary(context),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )),
      ],
    );
  }
}
