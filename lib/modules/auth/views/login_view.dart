import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/app_colour.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/divider.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/social_btn.dart';
import '../controllers/auth_cont.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  AuthController get controller => Get.find<AuthController>();

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
              const SizedBox(height: 32),


              _Header(),

              const SizedBox(height: 32),


              Form(
                key: loginFormKey,
                child: Column(
                  children: [
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

                    Obx(() => AppTextField(
                      label: 'Password',
                      hint: '••••••••••',
                      controller: controller.passwordController,
                      obscureText: !controller.isPasswordVisible.value,
                      prefixIcon: Icons.lock_outline,
                      validator: controller.validatePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => controller.login(loginFormKey),
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
                    )),

                    const SizedBox(height: 6),


                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.goToForgotPassword,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot password?',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),


                    Obx(() => controller.errorMessage.value.isNotEmpty
                        ? ErrorBanner(message: controller.errorMessage.value)
                        : const SizedBox.shrink()),

                    const SizedBox(height: 8),


                    Obx(() => AppButton(
                      label: 'Sign In',
                      isLoading: controller.isLoading.value,
                      onPressed: ()=> controller.login(loginFormKey),
                    )),

                    const SizedBox(height: 20),


                    const OrDivider(label: 'or continue with',),

                    const SizedBox(height: 16),


                    SocialButton(
                      label: 'Continue with Google',
                      type: SocialType.google,
                      onPressed: controller.loginWithGoogle,
                    ),

                    const SizedBox(height: 10),


                    SocialButton(
                      label: 'Continue with Apple',
                      type: SocialType.apple,
                      onPressed: () {},
                    ),

                    const SizedBox(height: 24),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: controller.goToSignup,
                          child: Text(
                            'Sign up',
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



class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D3D20), Color(0xFF041A0C)],
            ),
            border: Border.all(color: const Color(0xFF1A4A28)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Center(
            child: Text('🌿', style: TextStyle(fontSize: 24)),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.8, 0.8)),

        const SizedBox(height: 20),

        Text(
          'Welcome back',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1),

        const SizedBox(height: 6),

        Text(
          'Sign in to your FreshTrack account',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 250.ms),
      ],
    );
  }
}



