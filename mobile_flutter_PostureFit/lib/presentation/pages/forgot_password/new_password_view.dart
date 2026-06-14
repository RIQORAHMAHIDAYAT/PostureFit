// new_password_view.dart — Halaman Reset Password Baru.
//
// Langkah 3: Setelah OTP terverifikasi, user memasukkan password baru.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/forgot_password_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_logo.dart';

class NewPasswordView extends GetView<ForgotPasswordController> {
  const NewPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.bgColor(context),
                    AppTheme.bgSecondaryColor(context),
                  ],
                )
              : AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingXL,
              vertical: AppDimensions.paddingXXL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Back button ─────────────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: controller.goBackToOtp,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLG),

                // ── Logo ────────────────────────────────────────────────────
                const AppLogo(),
                const SizedBox(height: AppDimensions.paddingMD),

                // ── Card utama ──────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingXXL),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Form(
                    key: controller.newPasswordFormKey,
                    child: Column(
                      children: [
                        // ── Icon kunci baru ───────────────────────────────────
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF00BCD4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.key_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingLG),

                        Text(
                          'Password Baru',
                          style: AppTextStyles.headingMedium.copyWith(
                            color: AppTheme.textPrimary(context),
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.paddingSM),

                        Text(
                          'Buat password baru yang kuat\nuntuk akun Anda.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppTheme.textSecondary(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.paddingXXL),

                        // ── Input Password Baru ───────────────────────────────
                        AppInputField(
                          label: 'Password Baru',
                          hint: '••••••••',
                          controller: controller.newPasswordController,
                          isPassword: true,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.textLight,
                            size: AppDimensions.iconMD,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password baru wajib diisi';
                            }
                            if (v.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppDimensions.paddingLG),

                        // ── Input Konfirmasi Password ─────────────────────────
                        AppInputField(
                          label: 'Konfirmasi Password',
                          hint: '••••••••',
                          controller: controller.confirmPasswordController,
                          isPassword: true,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.textLight,
                            size: AppDimensions.iconMD,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Konfirmasi password wajib diisi';
                            }
                            if (v != controller.newPasswordController.text) {
                              return 'Password tidak cocok';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppDimensions.paddingMD),

                        // ── Indikator kekuatan password ───────────────────────
                        Obx(() {
                          final strength = controller.passwordStrength.value;
                          if (strength == 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Kekuatan Password',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppTheme.textSecondary(context),
                                      ),
                                    ),
                                    Text(
                                      strength <= 2
                                          ? 'Lemah'
                                          : strength <= 3
                                              ? 'Sedang'
                                              : 'Kuat',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: strength <= 2
                                            ? Colors.red
                                            : strength <= 3
                                                ? Colors.orange
                                                : Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: strength / 4,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      strength <= 2
                                          ? Colors.red
                                          : strength <= 3
                                              ? Colors.orange
                                              : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // ── Error message ─────────────────────────────────────
                        Obx(() {
                          if (controller.resetErrorMessage.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppDimensions.paddingMD),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.shade300),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller.resetErrorMessage.value,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        // ── Tombol Reset Password ─────────────────────────────
                        Obx(() => AppButton(
                              label: 'SIMPAN PASSWORD BARU',
                              onTap: controller.resetPassword,
                              isLoading: controller.isResetLoading.value,
                            )),

                        // ── Tips keamanan ─────────────────────────────────────
                        const SizedBox(height: AppDimensions.paddingXL),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.tips_and_updates_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tips: Gunakan kombinasi huruf besar, huruf kecil, angka, dan simbol untuk password yang kuat.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingXL),
                Text(
                  'RESET PASSWORD',
                  style: AppTextStyles.captionStyle.copyWith(
                    letterSpacing: 1.5,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
