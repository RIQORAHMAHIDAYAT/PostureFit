import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import 'edit_profile_controller.dart';
import 'widgets/avatar_picker_widget.dart';
import 'widgets/edit_profile_field.dart';

/// Halaman Edit Profile — view utama.
/// Menggunakan [EditProfileController] (GetX) untuk state management.
class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cardAltColor(context),
      body: Column(
        children: [
          // ── App Bar ────────────────────────────────────────────────────────
          _EditProfileAppBar(),

          // ── Body ───────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    // ── Avatar Section ───────────────────────────────────
                    _AvatarSection(),

                    // ── Form Section ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingLG,
                        vertical: AppDimensions.paddingMD,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Personal Info ──────────────────────────────
                          _SectionLabel(
                            icon: Icons.person_rounded,
                            label: 'Informasi Pribadi',
                          ),
                          const SizedBox(height: AppDimensions.paddingMD),
                          EditProfileField(
                            controller: controller.nameCtrl,
                            label: 'Nama Lengkap',
                            icon: Icons.badge_rounded,
                            iconColor: AppColors.primary,
                            hintText: 'Masukkan nama lengkap',
                            validator: controller.validateName,
                          ),
                          const SizedBox(height: AppDimensions.paddingMD),
                          EditProfileField(
                            controller: controller.emailCtrl,
                            label: 'Alamat Email',
                            icon: Icons.email_rounded,
                            iconColor: const Color(0xFF9B59B6),
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'Masukkan email',
                            validator: controller.validateEmail,
                          ),
                          const SizedBox(height: AppDimensions.paddingMD),
                          EditProfileField(
                            controller: controller.ageCtrl,
                            label: 'Usia',
                            icon: Icons.cake_rounded,
                            iconColor: AppColors.secondary,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            suffixText: 'tahun',
                            hintText: 'Mis. 24',
                            validator: controller.validateAge,
                          ),

                          const SizedBox(height: AppDimensions.paddingXXL),

                          // ── Body Metrics ───────────────────────────────
                          _SectionLabel(
                            icon: Icons.monitor_heart_rounded,
                            label: 'Data Tubuh',
                          ),
                          const SizedBox(height: AppDimensions.paddingMD),
                          Row(
                            children: [
                              Expanded(
                                child: EditProfileField(
                                  controller: controller.heightCtrl,
                                  label: 'Tinggi',
                                  icon: Icons.height_rounded,
                                  iconColor: AppColors.success,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                                  ],
                                  suffixText: 'cm',
                                  hintText: 'Mis. 170',
                                  validator: controller.validateHeight,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingMD),
                              Expanded(
                                child: EditProfileField(
                                  controller: controller.weightCtrl,
                                  label: 'Berat',
                                  icon: Icons.monitor_weight_rounded,
                                  iconColor: AppColors.warning,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                                  ],
                                  suffixText: 'kg',
                                  hintText: 'Mis. 65',
                                  validator: controller.validateWeight,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.paddingXXL),

                          // ── Save Button ───────────────────────────────
                          _SaveButton(),
                          const SizedBox(height: AppDimensions.paddingXXL),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────

class _EditProfileAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: AppDimensions.paddingMD,
        left: 8,
        right: AppDimensions.paddingLG,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryAppBarGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: AppColors.primaryAppBarShadow,
      ),
      child: Row(
        children: [
          // Back button
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
                  'Edit Profil',
                  style: AppTextStyles.headingLarge.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Perbarui informasi akunmu',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
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

// ─────────────────────────────────────────────────────────────────────────────
// Avatar Section
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXXL),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: AvatarPickerWidget(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.headingMedium.copyWith(
            color: AppTheme.textPrimary(context),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Save Button
// ─────────────────────────────────────────────────────────────────────────────

class _SaveButton extends GetView<EditProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: AppDimensions.buttonHeight,
          decoration: BoxDecoration(
            gradient: controller.isSaving.value
                ? const LinearGradient(
                    colors: [Color(0xFF6B8BAE), Color(0xFF6B8BAE)],
                  )
                : const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF2E6099), Color(0xFF5A9ED4)],
                  ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              onTap: controller.isSaving.value ? null : controller.onSave,
              child: Center(
                child: controller.isSaving.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Simpan Perubahan',
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 15,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ));
  }
}
