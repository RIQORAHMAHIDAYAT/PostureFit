import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/dss_analysis_controller.dart';
import '../../widgets/app_card.dart';

class DssAnalysisView extends GetView<DssAnalysisController> {
  const DssAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor(context),
      body: Column(
        children: [
          _DssAppBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.hasError.value) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('Gagal memuat data', style: AppTextStyles.bodyLarge),
                        const SizedBox(height: 8),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(color: AppTheme.textSecondary(context)),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: controller.refreshAnalysis,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (!controller.hasData.value) {
                return _buildEmptyState(context);
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(context),
                    const SizedBox(height: AppDimensions.paddingXL),
                    if (controller.posturCatatan.value.isNotEmpty) ...[
                      _buildPosturAlert(context),
                      const SizedBox(height: AppDimensions.paddingLG),
                    ],
                    _buildSawScoresSection(context),
                    const SizedBox(height: AppDimensions.paddingXL),
                    Text('Riwayat Analisis DSS', style: AppTextStyles.headingSmall),
                    const SizedBox(height: AppDimensions.paddingMD),
                    _buildHistory(context),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text('Belum Ada Analisis', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text(
              'Lakukan scan postur tubuh terlebih dahulu untuk mendapatkan analisis DSS yang dipersonalisasi.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textSecondary(context)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/scan'),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Scan Postur Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return AppCard(
      gradient: AppColors.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skor Kesehatan Keseluruhan',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
            '${controller.skorKesehatan.value} / 100',
            style: AppTextStyles.displayLarge.copyWith(color: Colors.white, fontSize: 48),
          )),
          const SizedBox(height: 4),
          Obx(() => Text(
            'Kategori: ${controller.kategoriTerpilih.value}  •  BMI: ${controller.bmi.value.toStringAsFixed(1)} (${controller.kategoriBmi.value})',
            style: AppTextStyles.captionStyle.copyWith(color: Colors.white70),
          )),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Text(
                    controller.rekomendasi.value.isNotEmpty
                        ? controller.rekomendasi.value
                        : 'Tidak ada rekomendasi saat ini.',
                    style: AppTextStyles.captionStyle.copyWith(color: Colors.white),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosturAlert(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(() => Text(
              controller.posturCatatan.value,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.orange.shade900),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSawScoresSection(BuildContext context) {
    return Obx(() {
      if (controller.sawDetail.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skor SAW per Kategori', style: AppTextStyles.headingSmall),
          const SizedBox(height: 12),
          ...controller.sawDetail.map((item) {
            final isWinner = item['kategori'] == controller.kategoriTerpilih.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isWinner
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppTheme.cardColor(context),
                border: isWinner
                    ? Border.all(color: AppColors.primary, width: 1.5)
                    : Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  if (isWinner)
                    Icon(Icons.star_rounded, color: AppColors.primary, size: 18),
                  if (!isWinner)
                    const Icon(Icons.circle_outlined, color: Colors.grey, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item['kategori'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    '${item['persentase']}%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isWinner ? AppColors.primary : AppTheme.textSecondary(context),
                      fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: LinearProgressIndicator(
                      value: (item['persentase'] as int) / 100.0,
                      backgroundColor: Colors.grey.shade200,
                      color: isWinner ? AppColors.primary : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildHistory(BuildContext context) {
    return Obx(() {
      if (controller.analysisResults.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'Belum ada riwayat analisis.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textSecondary(context)),
            ),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.analysisResults.length,
        itemBuilder: (context, index) {
          final item = controller.analysisResults[index];
          return _buildHistoryItem(context, item);
        },
      );
    });
  }

  Widget _buildHistoryItem(BuildContext context, Map<String, dynamic> item) {
    final tanggal = item['tanggal_assessment'] ?? '-';
    final kategori = item['kategori_terpilih'] ?? '-';
    final skor = item['skor_kesehatan'] ?? 0;
    final rekom = item['rekomendasi'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kategori,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Skor: $skor',
                  style: AppTextStyles.captionStyle.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            tanggal,
            style: AppTextStyles.captionStyle.copyWith(color: AppTheme.textSecondary(context)),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(rekom, style: AppTextStyles.bodySmall),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DssAppBar extends StatelessWidget {
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
            'DSS Analisis Kesehatan',
            style: AppTextStyles.headingLarge.copyWith(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GetBuilder<DssAnalysisController>(
            builder: (c) => IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: c.refreshAnalysis,
            ),
          ),
        ],
      ),
    );
  }
}
