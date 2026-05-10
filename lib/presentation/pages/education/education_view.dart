import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import 'education_controller.dart';
import 'widgets/education_card.dart';

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
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingLG,
                  AppDimensions.paddingLG,
                  AppDimensions.paddingLG,
                  AppDimensions.paddingXXL + AppDimensions.navBarHeight,
                ),
                itemCount: controller.educationList.length,
                itemBuilder: (context, index) {
                  final item = controller.educationList[index];
                  return EducationCard(
                    title: item.title,
                    subtitle: item.subtitle,
                    category: item.category,
                    duration: item.duration,
                    onTap: () {
                      // TODO: Navigate to detail view
                    },
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
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Education',
              style: AppTextStyles.headingLarge.copyWith(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Stack(
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
        ],
      ),
    );
  }
}
