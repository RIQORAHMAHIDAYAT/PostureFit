import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import 'education_controller.dart';
import 'widgets/education_card.dart';
import '../../../routes/app_routes.dart';

/// EducationBody: dipakai oleh MainView (IndexedStack) — tanpa bottom nav
class EducationBody extends GetView<EducationController> {
  const EducationBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      body: Column(
        children: [
          _EducationAppBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              // Jika sudah ada data dari server, tampilkan list sesungguhnya
              if (controller.educationList.isNotEmpty) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: controller.fetchEducation,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.paddingLG,
                      AppDimensions.paddingLG,
                      AppDimensions.paddingLG,
                      AppDimensions.paddingXXL + AppDimensions.navBarHeight,
                    ),
                    itemCount: controller.educationList.length,
                    itemBuilder: (context, index) {
                      return EducationCard(
                        item: controller.educationList[index],
                        onTap: () {
                          // TODO: Navigate to detail view
                        },
                      );
                    },
                  ),
                );
              }

              // Belum ada data → tampilkan card-card kosong sebagai placeholder
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingLG,
                  AppDimensions.paddingLG,
                  AppDimensions.paddingLG,
                  AppDimensions.paddingXXL + AppDimensions.navBarHeight,
                ),
                itemCount: 4, // Tampilkan 4 card kosong
                itemBuilder: (context, _) => const EducationCard(),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// EducationView: standalone (untuk navigasi langsung ke /education)
class EducationView extends GetView<EducationController> {
  const EducationView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EducationBody(),
    );
  }
}

// ── App Bar ──────────────────────────────────────────────────────────────────

class _EducationAppBar extends StatelessWidget {
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
        children: [
          Expanded(
            child: Text(
              'Edukasi',
              style: AppTextStyles.headingLarge.copyWith(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
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

