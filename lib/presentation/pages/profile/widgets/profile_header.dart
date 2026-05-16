import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../profile_controller.dart';

/// Gradient header with avatar, name, email, and edit-icon.
class ProfileHeader extends GetView<ProfileController> {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppDimensions.paddingLG,
        bottom: AppDimensions.paddingXXL,
        left: AppDimensions.paddingLG,
        right: AppDimensions.paddingLG,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryAppBarGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: AppColors.primaryAppBarShadow,
      ),
      child: Column(
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Circle avatar
              Obx(() => Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        controller.initials,
                        style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  )),
              // Camera badge
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: controller.onEditProfile,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingMD),

          // ── Name + edit icon ────────────────────────────────────────────
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.name.value,
                    style: AppTextStyles.headingLarge.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: controller.onEditProfile,
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ),
                ],
              )),

          const SizedBox(height: 4),

          // ── Email ───────────────────────────────────────────────────────
          Obx(() => Text(
                controller.email.value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              )),
        ],
      ),
    );
  }
}
