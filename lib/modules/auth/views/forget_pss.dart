import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../controllers/auth_cont.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Obx(
            () => controller.forgotEmailSent.value
                ? _SuccessState(email: controller.forgotEmailController.text)
                : _FormState(),
          ),
        ),
      ),
    );
  }
}

class _FormState extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        _BackButton(),

        const SizedBox(height: 32),

        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: const Center(
            child: Text('🔑', style: TextStyle(fontSize: 26)),
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),

        const SizedBox(height: 24),

        Text(
          'Forgot password?',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 8),

        Text(
          'No worries. Enter your email and we\'ll send you a reset link.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ).animate().fadeIn(delay: 180.ms),

        const SizedBox(height: 32),

        Form(
          key: controller.forgotFormKey,
          child: AppTextField(
            label: 'Email address',
            hint: 'you@gmail.com',
            controller: controller.forgotEmailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: controller.validateEmail,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => controller.sendForgotPassword(),
          ),
        ),

        const SizedBox(height: 12),

        Obx(
          () => controller.errorMessage.value.isNotEmpty
              ? _ErrorBanner(message: controller.errorMessage.value)
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 20),

        Obx(
          () => AppButton(
            label: 'Send Reset Link',
            isLoading: controller.isLoading.value,
            onPressed: controller.sendForgotPassword,
          ),
        ),

        const SizedBox(height: 16),

        Center(
          child: GestureDetector(
            onTap: Get.back,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Back to sign in',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessState extends GetView<AuthController> {
  final String email;
  const _SuccessState({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _BackButton(),
        const SizedBox(height: 60),

        Center(
          child:
              Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text('📧', style: TextStyle(fontSize: 40)),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.5, 0.5))
                  .then()
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 1.0, end: 1.05, duration: 1800.ms),
        ),

        const SizedBox(height: 32),

        Text(
          'Check your email',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 12),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            children: [
              const TextSpan(text: 'We sent a password reset link to\n'),
              TextSpan(
                text: email,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 40),

        AppButton(
          label: 'Back to Sign In',
          onPressed: () {
            controller.resetForgotState();
            Get.back();
          },
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 16),

        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Didn't receive the email? ",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              GestureDetector(
                onTap: () => controller.sendForgotPassword(),
                child: Text(
                  'Resend',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().shakeX(amount: 4);
  }
}
