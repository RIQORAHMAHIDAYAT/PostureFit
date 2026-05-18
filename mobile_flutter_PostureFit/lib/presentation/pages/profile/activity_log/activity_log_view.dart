import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../controllers/activity_log_controller.dart';

class ActivityLogView extends GetView<ActivityLogController> {
  const ActivityLogView({super.key});

  IconData _getIcon(String type) {
    switch (type) {
      case 'login': return Icons.login_rounded;
      case 'edit': return Icons.edit_rounded;
      case 'fitness_center': return Icons.fitness_center_rounded;
      case 'lock': return Icons.lock_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'login': return AppColors.primary;
      case 'edit': return AppColors.warning;
      case 'fitness_center': return AppColors.success;
      case 'lock': return AppColors.error;
      default: return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      body: Column(
        children: [
          _ActivityLogAppBar(),
          Expanded(
            child: Obx(() {
        if (controller.logs.isEmpty) {
          return Center(
            child: Text(
              'Belum ada aktivitas',
              style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textSecondary(context)),
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          itemCount: controller.logs.length,
          itemBuilder: (context, index) {
            final log = controller.logs[index];
            final icon = _getIcon(log['icon']);
            final iconColor = _getIconColor(log['icon']);

            return Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              decoration: BoxDecoration(
                color: AppTheme.cardColor(context),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: AppDimensions.paddingMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log['title'],
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log['desc'],
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          log['time'],
                          style: AppTextStyles.captionStyle.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
            }),
          ),
        ],
      ),
    );
  }
}

class _ActivityLogAppBar extends StatelessWidget {
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
          GestureDetector(
            onTap: () => Get.back(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingXS),
          Expanded(
            child: Text(
              'Aktivitas Akun Pengguna',
              style: AppTextStyles.headingLarge.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
