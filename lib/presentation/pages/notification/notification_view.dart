import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      body: Column(
        children: [
          _NotificationAppBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (controller.notifications.isEmpty) {
                return _EmptyNotification();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => controller.onInit(),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLG,
                    vertical: AppDimensions.paddingMD,
                  ),
                  itemCount: controller.notifications.length,
                  itemBuilder: (context, index) {
                    final item = controller.notifications[index];
                    return _NotificationItem(
                      item: item,
                      onTap: () => controller.markAsRead(item.id),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _NotificationAppBar extends GetView<NotificationController> {
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
          // Tombol kembali — sama seperti ScanView
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
          // Judul
          Expanded(
            child: Text(
              'Notifikasi',
              style: AppTextStyles.headingLarge.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Tombol tandai semua dibaca
          Obx(() {
            final hasUnread = controller.unreadCount > 0;
            if (!hasUnread) return const SizedBox.shrink();
            return GestureDetector(
              onTap: controller.markAllAsRead,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMD,
                  vertical: AppDimensions.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Tandai semua',
                  style: AppTextStyles.captionStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Item Notifikasi ───────────────────────────────────────────────────────────

class _NotificationItem extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationItem({required this.item, required this.onTap});

  Color _typeColor() {
    switch (item.type) {
      case NotificationType.posture:
        return AppColors.primary;
      case NotificationType.workout:
        return AppColors.success;
      case NotificationType.education:
        return AppColors.accent;
      case NotificationType.system:
        return AppColors.warning;
    }
  }

  IconData _typeIcon() {
    switch (item.type) {
      case NotificationType.posture:
        return Icons.accessibility_new_rounded;
      case NotificationType.workout:
        return Icons.fitness_center_rounded;
      case NotificationType.education:
        return Icons.menu_book_rounded;
      case NotificationType.system:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: item.isRead
              ? AppTheme.cardColor(context)
              : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: item.isRead
                ? AppTheme.borderColor(context)
                : color.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: item.isRead
                  ? Colors.black.withValues(alpha: 0.03)
                  : color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon kategori
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Icon(_typeIcon(), color: color, size: AppDimensions.iconMD),
            ),
            const SizedBox(width: AppDimensions.paddingMD),
            // Konten
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.headingSmall.copyWith(
                            color: AppTheme.textPrimary(context),
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Dot merah jika belum dibaca
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5C5C),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textSecondary(context),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.time,
                    style: AppTextStyles.captionStyle.copyWith(
                      color: item.isRead
                          ? AppTheme.textSecondary(context)
                          : color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyNotification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          Text(
            'Belum Ada Notifikasi',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppTheme.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          Text(
            'Notifikasi terbaru Anda\nakan muncul di sini.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textSecondary(context),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
