import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/auth_toggle.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingXL,
                vertical: AppDimensions.paddingXXL,
              ),
              child: Column(
                children: [
                  const AppLogo(),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(
                    'Buat akun dan mulai perjalanan\nkebugaran Anda',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.paddingXXL),
                  AppCard(
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthToggle(
                            isLogin: false,
                            onLoginTap: controller.goToLogin,
                            onRegisterTap: () {},
                          ),
                          const SizedBox(height: AppDimensions.paddingXXL),
                          AppInputField(
                            label: 'Nama Lengkap',
                            hint: 'Nama lengkap Anda',
                            controller: controller.nameController,
                            keyboardType: TextInputType.name,
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.textLight,
                              size: AppDimensions.iconMD,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Nama wajib diisi';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingLG),
                          AppInputField(
                            label: 'Email',
                            hint: 'nama@email.com',
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              color: AppColors.textLight,
                              size: AppDimensions.iconMD,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Email wajib diisi';
                              if (!v.contains('@')) return 'Format email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingLG),
                          AppInputField(
                            label: 'Password',
                            hint: '••••••••',
                            controller: controller.passwordController,
                            isPassword: true,
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.textLight,
                              size: AppDimensions.iconMD,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password wajib diisi';
                              if (v.length < 6) return 'Password minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingLG),
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
                              if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                              if (v != controller.passwordController.text) {
                                return 'Password tidak sama';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingXXL),
                          Obx(() => AppButton(
                                label: 'BUAT AKUN',
                                onTap: controller.register,
                                isLoading: controller.isLoading.value,
                              )),
                          const SizedBox(height: AppDimensions.paddingLG),
                          Row(
                            children: [
                              const Expanded(child: Divider(color: AppColors.divider)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.paddingMD),
                                child: Text(
                                  'atau masuk dengan',
                                  style: AppTextStyles.captionStyle,
                                ),
                              ),
                              const Expanded(child: Divider(color: AppColors.divider)),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.paddingLG),
                          GoogleSignInButton(onTap: controller.signInWithGoogle),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),
                  Text(
                    'HALAMAN DAFTAR',
                    style: AppTextStyles.captionStyle.copyWith(
                      letterSpacing: 1.5,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
