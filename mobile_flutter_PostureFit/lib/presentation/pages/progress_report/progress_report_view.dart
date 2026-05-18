import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/progress_report_controller.dart';
import '../../widgets/app_card.dart';

class ProgressReportView extends GetView<ProgressReportController> {
  const ProgressReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      body: Column(
        children: [
          _ProgressAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: AppDimensions.paddingLG),
                  _buildMainChart(context),
                  const SizedBox(height: AppDimensions.paddingXL),
                  Text('Statistik Latihan', style: AppTextStyles.headingSmall),
                  const SizedBox(height: AppDimensions.paddingMD),
                  _buildStatsGrid(context),
                  const SizedBox(height: AppDimensions.paddingXL),
                  Text('Pencapaian Terbaru', style: AppTextStyles.headingSmall),
                  const SizedBox(height: AppDimensions.paddingMD),
                  _buildAchievementList(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Obx(() => Row(
            children: controller.periods.map((period) {
              final isSelected = controller.selectedPeriod.value == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.changePeriod(period),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    child: Text(
                      period,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }

  Widget _buildMainChart(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Performa Latihan', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              Icon(Icons.trending_up, color: AppColors.success),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Obx(() => Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: controller.chartData.map((val) {
                    return Container(
                      width: 20,
                      height: val * 2,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }).toList(),
                )),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'].map((d) => Text(d, style: AppTextStyles.captionStyle)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _statItem(context, 'Total Kalori', '12,450', 'kcal', Icons.local_fire_department, AppColors.error),
        _statItem(context, 'Waktu Latih', '45.5', 'jam', Icons.timer, AppColors.primary),
        _statItem(context, 'Sesi Selesai', '32', 'sesi', Icons.check_circle, AppColors.success),
        _statItem(context, 'Berat Badan', '68.5', 'kg', Icons.monitor_weight, AppColors.accent),
      ],
    );
  }

  Widget _statItem(BuildContext context, String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(label, style: AppTextStyles.captionStyle),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: AppTextStyles.headingSmall.copyWith(color: AppTheme.textPrimary(context), fontWeight: FontWeight.bold)),
                TextSpan(text: ' $unit', style: AppTextStyles.captionStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementList(BuildContext context) {
    return Column(
      children: [
        _achievementRow(context, 'Prajurit Konsisten', 'Latihan 7 hari berturut-turut', Icons.workspace_premium),
        const SizedBox(height: 12),
        _achievementRow(context, 'Penjelajah Kalori', 'Membakar 5000 kcal dalam seminggu', Icons.stars),
      ],
    );
  }

  Widget _achievementRow(BuildContext context, String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.warning, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                Text(desc, style: AppTextStyles.bodySmall.copyWith(color: AppTheme.textSecondary(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.of(context).padding.top,
        AppDimensions.paddingLG,
        AppDimensions.paddingLG,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryAppBarGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: AppColors.primaryAppBarShadow,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: AppDimensions.paddingXS),
          Text(
            'Laporan Progres Latihan',
            style: AppTextStyles.headingLarge.copyWith(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
