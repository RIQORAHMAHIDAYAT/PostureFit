import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../controllers/main_controller.dart';
import '../home/home_view.dart';
import '../workout_plan/workout_plan_view.dart';
import '../education/education_view.dart';
import '../profile/profile_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: [
              const HomeBody(),           // index 0
              const SizedBox.shrink(),    // index 1 = Scan
              const WorkoutPlanBody(),    // index 2
              const EducationBody(),      // index 3 = Edukasi
              const ProfileBody(),        // index 4 = Profile
            ],
          )),
      bottomNavigationBar: _MainBottomNav(),
    );
  }
}

class _MainBottomNav extends GetView<MainController> {
  const _MainBottomNav();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          height:
              AppDimensions.navBarHeight + MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                asset: 'assets/icons/logo_home.png',
                index: 0,
                size: AppDimensions.iconLG * 1.4,
                selectedIndex: controller.selectedIndex.value,
                onTap: () => controller.changeTab(0),
              ),
              _NavItem(
                asset: 'assets/icons/logo_aperture.png',
                index: 1,
                selectedIndex: controller.selectedIndex.value,
                onTap: () => controller.changeTab(1),
              ),
              _NavItem(
                asset: 'assets/icons/logo_stats.png',
                index: 2,
                selectedIndex: controller.selectedIndex.value,
                onTap: () => controller.changeTab(2),
              ),
              _NavItem(
                asset: 'assets/icons/logo_edukasi.png',
                index: 3,
                selectedIndex: controller.selectedIndex.value,
                onTap: () => controller.changeTab(3),
              ),
              _NavItem(
                asset: 'assets/icons/logo_profile.png',
                index: 4,
                selectedIndex: controller.selectedIndex.value,
                onTap: () => controller.changeTab(4),
              ),
            ],
          ),
        ));
  }
}

class _NavItem extends StatelessWidget {
  final String asset;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;
  final double size;

  const _NavItem({
    required this.asset,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    this.size = AppDimensions.iconLG,
  });

  bool get isSelected => index == selectedIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(AppDimensions.paddingSM),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : null,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Opacity(
                opacity: isSelected ? 1.0 : 0.5,
                child: Image.asset(
                  asset,
                  width: size,
                  height: size,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
