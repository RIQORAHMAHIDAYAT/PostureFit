import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../controllers/activity_log_controller.dart';

class ActivityLogView extends GetView<ActivityLogController> {
  const ActivityLogView({super.key});

  // ── Icon & Color mapping ──────────────────────────────────────────────────

  IconData _getIcon(String type) {
    switch (type) {
      case 'login':
        return Icons.login_rounded;
      case 'edit':
        return Icons.edit_rounded;
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'lock':
        return Icons.lock_rounded;
      case 'register':
        return Icons.person_add_rounded;
      case 'logout':
        return Icons.logout_rounded;
      case 'scan':
        return Icons.camera_alt_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'login':
        return const Color(0xFF4A90D9);
      case 'edit':
        return const Color(0xFFF5A623);
      case 'fitness_center':
        return const Color(0xFF4CAF82);
      case 'lock':
        return const Color(0xFFE05C5C);
      case 'register':
        return const Color(0xFF9B59B6);
      case 'logout':
        return const Color(0xFFE05C5C);
      case 'scan':
        return const Color(0xFF3DD6C8);
      default:
        return const Color(0xFF5BB8F5);
    }
  }

  String _getBadgeLabel(String type) {
    switch (type) {
      case 'login':
        return 'Masuk';
      case 'edit':
        return 'Edit';
      case 'fitness_center':
        return 'Analisis';
      case 'lock':
        return 'Keamanan';
      case 'register':
        return 'Daftar';
      case 'logout':
        return 'Keluar';
      case 'scan':
        return 'Scan';
      default:
        return 'Aktivitas';
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
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Memuat riwayat aktivitas...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.logs.isEmpty) {
                return _EmptyState();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.fetchLogs,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ── Summary Stats ──────────────────────────────────────
                    SliverToBoxAdapter(
                      child: _SummaryStatsCard(logs: controller.logs),
                    ),

                    // ── Timeline Header ────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.paddingLG,
                          AppDimensions.paddingLG,
                          AppDimensions.paddingLG,
                          AppDimensions.paddingSM,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 18,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Riwayat Aktivitas',
                              style: AppTextStyles.headingSmall.copyWith(
                                color: AppTheme.textPrimary(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${controller.logs.length} entri',
                                style: AppTextStyles.captionStyle.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Timeline List ──────────────────────────────────────
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.paddingLG,
                        0,
                        AppDimensions.paddingLG,
                        AppDimensions.paddingXXL + AppDimensions.navBarHeight,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final log = controller.logs[index];
                            final isLast =
                                index == controller.logs.length - 1;
                            return _TimelineItem(
                              log: log,
                              isLast: isLast,
                              index: index,
                              icon: _getIcon(log['icon'] as String? ?? ''),
                              iconColor: _getIconColor(
                                  log['icon'] as String? ?? ''),
                              badgeLabel: _getBadgeLabel(
                                  log['icon'] as String? ?? ''),
                            );
                          },
                          childCount: controller.logs.length,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Summary Stats Card ────────────────────────────────────────────────────────

class _SummaryStatsCard extends StatelessWidget {
  final List<Map<String, dynamic>> logs;

  const _SummaryStatsCard({required this.logs});

  @override
  Widget build(BuildContext context) {
    final loginCount =
        logs.where((l) => l['icon'] == 'login').length;
    final editCount =
        logs.where((l) => l['icon'] == 'edit').length;
    final analysisCount =
        logs.where((l) => l['icon'] == 'fitness_center').length;

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingLG),
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF183B6B), Color(0xFF4A90D9)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF183B6B).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Aktivitas',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Pantau keamanan akun Anda',
                    style: AppTextStyles.captionStyle.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLG),
          Row(
            children: [
              _StatBubble(
                  icon: Icons.login_rounded,
                  label: 'Login',
                  count: loginCount,
                  color: Colors.white),
              const SizedBox(width: AppDimensions.paddingMD),
              _StatBubble(
                  icon: Icons.edit_rounded,
                  label: 'Edit Profil',
                  count: editCount,
                  color: const Color(0xFFFFC78A)),
              const SizedBox(width: AppDimensions.paddingMD),
              _StatBubble(
                  icon: Icons.fitness_center_rounded,
                  label: 'Analisis',
                  count: analysisCount,
                  color: const Color(0xFF7EECD2)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatBubble({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: AppTextStyles.headingMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.captionStyle.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Timeline Item ─────────────────────────────────────────────────────────────

class _TimelineItem extends StatelessWidget {
  final Map<String, dynamic> log;
  final bool isLast;
  final int index;
  final IconData icon;
  final Color iconColor;
  final String badgeLabel;

  const _TimelineItem({
    required this.log,
    required this.isLast,
    required this.index,
    required this.icon,
    required this.iconColor,
    required this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 350 + (index * 60).clamp(0, 500)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Timeline rail ──────────────────────────────────────────────
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  // Dot
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(icon, color: iconColor, size: 16),
                  ),
                  // Vertical line
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.only(top: 4, bottom: 0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              iconColor.withValues(alpha: 0.30),
                              iconColor.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Content card ───────────────────────────────────────────────
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: AppDimensions.paddingSM,
                  bottom: isLast ? 0 : AppDimensions.paddingMD,
                ),
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            log['title'] as String? ?? '',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary(context),
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge tipe aktivitas
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badgeLabel,
                            style: AppTextStyles.captionStyle.copyWith(
                              color: iconColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      log['desc'] as String? ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textSecondary(context),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: iconColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          log['time'] as String? ?? '',
                          style: AppTextStyles.captionStyle.copyWith(
                            color: iconColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.accent.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_toggle_off_rounded,
                size: 52,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            Text(
              'Belum Ada Aktivitas',
              style: AppTextStyles.headingLarge.copyWith(
                color: AppTheme.textPrimary(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            Text(
              'Setiap tindakan penting pada akun Anda\nakan tercatat di sini secara otomatis.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textSecondary(context),
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.primary.withValues(alpha: 0.7)),
                  const SizedBox(width: 8),
                  Text(
                    'Login, edit profil, dan analisis postur\nakan muncul di sini.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.captionStyle.copyWith(
                      color: AppColors.primary.withValues(alpha: 0.8),
                      height: 1.5,
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

// ── App Bar ───────────────────────────────────────────────────────────────────

class _ActivityLogAppBar extends GetView<ActivityLogController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.of(context).padding.top,
        16,
        AppDimensions.paddingLG,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryAppBarGradient,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(32)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aktivitas Akun',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Riwayat keamanan & aktivitas',
                  style: AppTextStyles.captionStyle.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.logs.isEmpty) {
              return const SizedBox(width: 40, height: 40);
            }
            return GestureDetector(
              onTap: controller.clearAllLogs,
              child: Tooltip(
                message: 'Hapus semua riwayat',
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.white,
                    size: 20,
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
