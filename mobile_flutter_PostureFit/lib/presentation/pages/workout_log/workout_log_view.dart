import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/workout_log_controller.dart';
import '../../widgets/app_card.dart';

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
            child: Obx(() {
              if (controller.isLoading.value && controller.workoutLogs.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: controller.fetchLogs,
                child: ListView(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  children: [
                    _buildActiveWorkoutCard(context),
                    if (controller.workoutLogs.isEmpty)
                      _buildEmptyState(context)
                    else
                      ...controller.workoutLogs.map((log) => _buildLogCard(context, log)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat',
            style: AppTextStyles.headingSmall.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai latihan dari menu Workout Plan\nuntuk mencatat riwayat pertama Anda.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWorkoutCard(BuildContext context) {
    if (!controller.isWorkoutActive.value) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingLG),
      child: AppCard(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sesi Aktif Berjalan',
                        style: AppTextStyles.captionStyle.copyWith(color: Colors.white70),
                      ),
                      Text(
                        controller.activeWorkoutName.value,
                        style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              controller.formattedTimer,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.cancelWorkout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.finishWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, Map<String, dynamic> log) {
    // Backend mengembalikan date sebagai string "Sat, 01 Jan 2023 12:00:00 GMT" (HTTP format datetime normal)
    // Atau tergantung format. Kita tampilkan date langsung atau format ulang
    final dateStr = log['date'] ?? '-';
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), 
            blurRadius: 15, 
            offset: const Offset(0, 5)
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
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
                      Text(
                        log['title'] ?? 'Latihan', 
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        log['category'] ?? '-', 
                        style: AppTextStyles.captionStyle.copyWith(color: AppColors.primary)
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1), 
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(
                    'Selesai', 
                    style: AppTextStyles.captionStyle.copyWith(
                      color: AppColors.success, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoItem(Icons.calendar_today_outlined, dateStr.length >= 16 ? dateStr.substring(0, 16) : dateStr),
                Row(
                  children: [
                    _infoItem(Icons.timer_outlined, log['duration'] ?? '-'),
                    const SizedBox(width: 12),
                    _infoItem(Icons.local_fire_department_outlined, log['calories'] ?? '-'),
                  ],
                ),
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
        Icon(icon, size: 14, color: AppColors.navInactive),
        const SizedBox(width: 4),
        Text(value, style: AppTextStyles.captionStyle.copyWith(color: AppColors.navInactive)),
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
            'Log Latihan',
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
