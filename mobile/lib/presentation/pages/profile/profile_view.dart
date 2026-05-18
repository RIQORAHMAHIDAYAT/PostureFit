import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import 'profile_controller.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stat_card.dart';
import 'widgets/profile_menu_item.dart';

class ProfileBody extends GetView<ProfileController> {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cardAltColor(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const ProfileHeader(),
            const SizedBox(height: AppDimensions.paddingLG),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLG),
              child: Obx(() => Row(
                    children: [
                      ProfileStatCard(
                        icon: Icons.people_rounded,
                        iconColor: const Color(0xFF9B59B6),
                        value: '${controller.age.value}',
                        unit: 'years',
                      ),
                      const SizedBox(width: AppDimensions.paddingMD),
                      ProfileStatCard(
                        icon: Icons.height_rounded,
                        iconColor: AppColors.secondary,
                        value: '${controller.height.value.toInt()}',
                        unit: 'cm',
                      ),
                      const SizedBox(width: AppDimensions.paddingMD),
                      ProfileStatCard(
                        icon: Icons.monitor_weight_rounded,
                        iconColor: AppColors.success,
                        value: '${controller.weight.value.toInt()}',
                        unit: 'kg',
                      ),
                    ],
                  )),
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLG),
              child: _BmiCard(),
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            _SettingsBlock(),
            SizedBox(height: AppDimensions.paddingXXL + AppDimensions.navBarHeight + 8),
          ],
        ),
      ),
    );
  }
}

/// Standalone ProfileView (for direct /profile route).
class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ProfileBody());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BMI Card
// ─────────────────────────────────────────────────────────────────────────────

class _BmiCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bmiValue  = controller.bmi.value;
      final bmiColor  = controller.bmiColor;
      final bmiStatus = controller.bmiStatus;
      final progress  = controller.bmiProgress;

      return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Body Mass Index', style: AppTextStyles.headingMedium.copyWith(color: AppTheme.textPrimary(context))),
            const SizedBox(height: AppDimensions.paddingMD),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 9,
                        backgroundColor: AppTheme.inputBg(context),
                        valueColor: AlwaysStoppedAnimation<Color>(bmiColor),
                        strokeCap: StrokeCap.round,
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              bmiValue.toStringAsFixed(1),
                              style: AppTextStyles.headingMedium.copyWith(
                                color: bmiColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'BMI',
                              style: AppTextStyles.captionStyle.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingXL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BmiLegendRow(label: '< 18.5 – Underweight', isActive: bmiStatus == 'Underweight', color: AppColors.primary),
                      const SizedBox(height: 6),
                      _BmiLegendRow(label: '18.5 – 24.9 – Normal', isActive: bmiStatus == 'Normal', color: AppColors.success),
                      const SizedBox(height: 6),
                      _BmiLegendRow(label: '25 – 29.9 – Overweight', isActive: bmiStatus == 'Overweight', color: AppColors.warning),
                      const SizedBox(height: 6),
                      _BmiLegendRow(label: '≥ 30 – Obese', isActive: bmiStatus == 'Obese', color: AppColors.error),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  bmiStatus,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: bmiColor,
                    fontWeight: FontWeight.w600,
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

class _BmiLegendRow extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;

  const _BmiLegendRow({required this.label, required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : AppColors.divider,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isActive ? color : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings Block
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsBlock extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLG),
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.07),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            child: Column(
              children: [
                ProfileMenuItem(
                  icon: Icons.dark_mode_rounded,
                  iconColor: const Color(0xFF9B59B6),
                  iconBg: const Color(0xFF9B59B6).withValues(alpha: 0.12),
                  title: 'Dark Mode',
                  hasSwitch: true,
                  switchValue: controller.isDarkMode.value,
                  onSwitchChanged: controller.toggleDarkMode,
                ),
                ProfileMenuItem(
                  icon: Icons.hotel_rounded,
                  iconColor: AppColors.secondary,
                  iconBg: AppColors.secondary.withValues(alpha: 0.12),
                  title: 'Mode Tidur',
                  hasSwitch: true,
                  switchValue: controller.isSleepMode.value,
                  onSwitchChanged: controller.toggleSleepMode,
                ),
                ProfileMenuItem(
                  icon: Icons.history_rounded,
                  iconColor: AppColors.primary,
                  iconBg: AppColors.primary.withValues(alpha: 0.12),
                  title: 'Aktivitas Akun',
                  hasArrow: true,
                  onTap: controller.onActivityLog,
                ),
                ProfileMenuItem(
                  icon: Icons.shield_outlined,
                  iconColor: AppColors.success,
                  iconBg: AppColors.success.withValues(alpha: 0.12),
                  title: 'Privacy Policy',
                  hasArrow: true,
                  onTap: controller.onPrivacyPolicy,
                ),
                ProfileMenuItem(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.warning,
                  iconBg: AppColors.warning.withValues(alpha: 0.12),
                  title: 'App Version',
                  subtitle: '1.0.0',
                ),
                ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.error,
                  iconBg: AppColors.error.withValues(alpha: 0.12),
                  title: 'Logout',
                  isDestructive: true,
                  onTap: controller.onLogout,
                ),
              ],
            ),
          ),
        ));
  }
}
