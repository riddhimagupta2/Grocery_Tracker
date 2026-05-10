import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/social_btn.dart';
import '../controllers/auth_cont.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary,
                    size: 16,
                  ),
                ),
              ).animate().fadeIn(),

              const SizedBox(height: 24),

              Text(
                'Create account',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

              const SizedBox(height: 6),

              Text(
                'Join FreshTrack — it\'s completely free',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 28),

              Form(
                key: controller.signupFormKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Full Name',
                      hint: 'Rahul Sharma',
                      controller: controller.nameController,
                      keyboardType: TextInputType.name,
                      prefixIcon: Icons.person_outline,
                      validator: controller.validateName,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 14),

                    AppTextField(
                      label: 'Email address',
                      hint: 'you@gmail.com',
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: controller.validateEmail,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 14),

                    Obx(
                      () => AppTextField(
                        label: 'Password',
                        hint: '••••••••••',
                        controller: controller.passwordController,
                        obscureText: !controller.isPasswordVisible.value,
                        prefixIcon: Icons.lock_outline,
                        validator: controller.validatePassword,
                        textInputAction: TextInputAction.next,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Obx(
                      () => AppTextField(
                        label: 'Confirm Password',
                        hint: '••••••••••',
                        controller: controller.confirmController,
                        obscureText: !controller.isConfirmVisible.value,
                        prefixIcon: Icons.lock_outline,
                        validator: controller.validateConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => controller.signup(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmVisible.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: controller.toggleConfirmVisibility,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textHint,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Obx(
                      () => controller.errorMessage.value.isNotEmpty
                          ? ErrorBanner(message: controller.errorMessage.value)
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 8),

                    Obx(
                      () => AppButton(
                        label: 'Create Account',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.signup,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppColors.cardBorder),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: AppColors.cardBorder),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SocialButton(
                      label: 'Sign up with Google',
                      type: SocialType.google,
                      onPressed: controller.loginWithGoogle,
                    ),

                    const SizedBox(height: 10),

                    SocialButton(
                      label: 'Sign up with Apple',
                      type: SocialType.apple,
                      onPressed: () {},
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: controller.goToLogin,
                          child: Text(
                            'Sign in',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

