import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/workout_log_controller.dart';

class WorkoutLogView extends GetView<WorkoutLogController> {
  const WorkoutLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      body: Column(
        children: [
          _WorkoutLogAppBar(),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  itemCount: controller.workoutLogs.length,
                  itemBuilder: (context, index) {
                    final log = controller.workoutLogs[index];
                    return _buildLogCard(context, log);
                  },
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.fitness_center_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log['title'], style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(log['category'], style: AppTextStyles.captionStyle.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(log['date'], style: AppTextStyles.captionStyle),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('Selesai', style: AppTextStyles.captionStyle.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoItem(Icons.timer_outlined, log['duration']),
                _infoItem(Icons.local_fire_department_outlined, log['calories']),
                _infoItem(Icons.star_outline_rounded, 'XP +50'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.navInactive),
        const SizedBox(width: 4),
        Text(value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.navInactive)),
      ],
    );
  }
}

class _WorkoutLogAppBar extends StatelessWidget {
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
            'Log Latihan Saya',
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
