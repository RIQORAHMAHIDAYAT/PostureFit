import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/auth_toggle.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.bgColor(context), AppTheme.bgSecondaryColor(context)],
                )
              : AppColors.backgroundGradient,
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
                    'Masuk dan lanjutkan perjalanan\nkebugaran Anda',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXXL),
                  AppCard(
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthToggle(
                            isLogin: true,
                            onLoginTap: () {},
                            onRegisterTap: controller.goToRegister,
                          ),
                          const SizedBox(height: AppDimensions.paddingXXL),
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
                          const SizedBox(height: AppDimensions.paddingSM),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Lupa Password?',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingXXL),
                          Obx(() => AppButton(
                                label: 'MASUK',
                                onTap: controller.login,
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
                    'HALAMAN MASUK',
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
        },
      ),
    );
  }
}
