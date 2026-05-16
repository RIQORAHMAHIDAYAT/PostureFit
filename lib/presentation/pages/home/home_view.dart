import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/activity_progress_bar.dart';
import '../../widgets/feature_button.dart';
import '../../controllers/home_controller.dart';
import '../../../routes/app_routes.dart';

// HomeBody: dipakai oleh MainView (IndexedStack) — tanpa bottom nav
class HomeBody extends GetView<HomeController> {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      body: Column(
        children: [
          _HomeAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLG),
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.paddingLG),
                  _GoalCard(),
                  const SizedBox(height: AppDimensions.paddingLG),
                  _SleepHydrationRow(),
                  const SizedBox(height: AppDimensions.paddingLG),
                  _ActivityScoreCard(),
                  const SizedBox(height: AppDimensions.paddingLG),
                  _FeatureGrid(),
                  const SizedBox(height: AppDimensions.paddingXXL + AppDimensions.navBarHeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// HomeView standalone (untuk navigasi langsung ke /home jika masih diperlukan)
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomeBody(),
    );
  }
}

class _HomeAppBar extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppDimensions.paddingMD,
        left: AppDimensions.paddingLG,
        right: AppDimensions.paddingLG,
        bottom: AppDimensions.paddingLG,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryAppBarGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: AppColors.primaryAppBarShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.greetingTime,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  Text(
                    controller.user.value.name,
                    style: AppTextStyles.headingLarge.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.notification),
            child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: AppDimensions.iconMD,
                ),
              ),
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5C5C),
                    shape: BoxShape.circle,
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

class _GoalCard extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      return AppCard(
        gradient: AppColors.cardGradient,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target saat ini', style: AppTextStyles.bodySmall.copyWith(color: AppColors.navInactive)),
            const SizedBox(height: 2),
            Text(user.goal, style: AppTextStyles.headingLarge.copyWith(color: AppColors.textWhite)),
            const SizedBox(height: AppDimensions.paddingMD),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                    child: const LinearProgressIndicator(
                      value: 0.62,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3DD6C8)),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('62% Tercapai', style: AppTextStyles.captionStyle.copyWith(color: Colors.white)),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            Row(
              children: [
                _miniStat('${user.height.toInt()}', 'cm', 'Height'),
                _miniStat('${user.weight.toInt()}', 'kg', 'Weight'),
                _miniStat(user.bmi.toStringAsFixed(1), '', 'BMI'),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            GestureDetector(
              onTap: controller.onLihatRekomendasiTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Text(
                  'Lihat Rekomendasi Saya',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _miniStat(String value, String unit, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$value $unit', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SleepHydrationRow extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final act = controller.activity.value;
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${act.sleepDuration} jam',
                            style: AppTextStyles.displayMedium.copyWith(
                                color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 32)),
                        const SizedBox(height: 4),
                        Text('Durasi tidur', style: AppTextStyles.bodySmall.copyWith(color: AppColors.navInactive)),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                      child: LinearProgressIndicator(
                        value: act.sleepDuration / 8,
                        backgroundColor: AppTheme.inputBg(context),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMD),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72, height: 72,
                      child: CircularProgressIndicator(
                        value: controller.hydrationPercentage,
                        strokeWidth: 8,
                        backgroundColor: AppTheme.inputBg(context),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Hidrasi hari ini', style: AppTextStyles.bodySmall.copyWith(color: AppColors.navInactive)),
                          const SizedBox(height: 4),
                          Text(
                            '${act.hydrationCurrent.toInt()} ml / ${act.hydrationTarget.toInt()} ml',
                            style: AppTextStyles.captionStyle.copyWith(color: AppColors.navInactive),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ActivityScoreCard extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final act = controller.activity.value;
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Skor aktivitas hari ini', style: AppTextStyles.headingSmall.copyWith(color: AppTheme.textPrimary(context))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD, vertical: AppDimensions.paddingXS),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                  ),
                  child: Text('${act.activityScore} / 100',
                      style: AppTextStyles.captionStyle.copyWith(color: AppColors.textWhite, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            ActivityProgressBar(label: 'Olahraga', value: act.olahraga, color: AppColors.primary),
            const SizedBox(height: AppDimensions.paddingMD),
            ActivityProgressBar(label: 'Nutrisi', value: act.nutrisi, color: AppColors.success),
            const SizedBox(height: AppDimensions.paddingMD),
            ActivityProgressBar(label: 'Tidur', value: act.tidur, color: AppColors.accent),
          ],
        ),
      );
    });
  }
}

class _FeatureGrid extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Akses lainnya', style: AppTextStyles.headingSmall),
        const SizedBox(height: AppDimensions.paddingMD),
        Row(
          children: [
            Expanded(child: FeatureButton(icon: Icons.fitness_center_rounded, label: 'Workout\nPlan', onTap: controller.onWorkoutPlanTap, iconColor: AppColors.primary)),
            const SizedBox(width: AppDimensions.paddingMD),
            Expanded(child: FeatureButton(icon: Icons.psychology_outlined, label: 'DSS\nAnalis', onTap: controller.onBmiAnalysisTap, iconColor: AppColors.success)),
            const SizedBox(width: AppDimensions.paddingMD),
            Expanded(child: FeatureButton(icon: Icons.edit_note_rounded, label: 'Log\nAktivitas', onTap: controller.onLogAktivitasTap, iconColor: AppColors.accent)),
            const SizedBox(width: AppDimensions.paddingMD),
            Expanded(child: FeatureButton(icon: Icons.trending_up_rounded, label: 'Laporan\nProgres', onTap: controller.onProgressTrackerTap, iconColor: AppColors.warning)),
          ],
        ),
      ],
    );
  }
}
