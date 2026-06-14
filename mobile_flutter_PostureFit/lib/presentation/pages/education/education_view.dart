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
          _CategoryFilterBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (controller.errorMessage.value.isNotEmpty &&
                  controller.educationList.isEmpty) {
                return _ErrorState(
                  message: controller.errorMessage.value,
                  onRetry: controller.fetchEducation,
                );
              }

              if (controller.educationList.isNotEmpty) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: controller.fetchEducation,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.paddingLG,
                      AppDimensions.paddingMD,
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
                  AppDimensions.paddingMD,
                  AppDimensions.paddingLG,
                  AppDimensions.paddingXXL + AppDimensions.navBarHeight,
                ),
                itemCount: 4,
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

// ── Filter Chip Bar ───────────────────────────────────────────────────────────

/// Daftar chip filter kategori yang ditampilkan di bawah AppBar.
class _CategoryFilterBar extends StatelessWidget {
  final EducationController controller;
  const _CategoryFilterBar({required this.controller});

  static const _categories = [
    {'label': 'Semua',    'value': ''},
    {'label': 'Postur',   'value': 'postur'},
    {'label': 'Kebugaran','value': 'kebugaran'},
    {'label': 'Olahraga', 'value': 'olahraga'},
    {'label': 'Nutrisi',  'value': 'nutrisi'},
    {'label': 'Kesehatan','value': 'kesehatan'},
    {'label': 'Tidur',    'value': 'tidur'},
    {'label': 'Hidrasi',  'value': 'hidrasi'},
    {'label': 'Ergonomi', 'value': 'ergonomi'},
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedCategory.value;
      return Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLG),
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final cat   = _categories[index];
            final label = cat['label']!;
            final value = cat['value']!;
            final isActive = selected == value;

            return GestureDetector(
              onTap: () {
                if (value.isEmpty) {
                  controller.clearFilter();
                } else {
                  controller.filterByCategory(value);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isActive ? AppColors.primaryGradient : null,
                  color: isActive ? null : AppTheme.inputBg(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isActive
                        ? Colors.transparent
                        : AppTheme.borderColor(context),
                    width: 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isActive ? Colors.white : AppTheme.textSecondary(context),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: AppTheme.textSecondary(context).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat artikel',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppTheme.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppTheme.textSecondary(context).withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
