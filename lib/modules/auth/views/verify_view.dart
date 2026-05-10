import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/service/auth_service.dart';
import '../../../config/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/auth_cont.dart';


class VerifyEmailView extends GetView<AuthController> {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<FirebaseAuthService>();
    final email = authService.currentUser?.email ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.startVerificationPolling();
    });

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              _AnimatedEmailIcon(),

              const SizedBox(height: 32),

              Text(
                'Verify your email',
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
                    const TextSpan(text: 'We sent a verification link to\n'),
                    TextSpan(
                      text: email,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '\n\nClick the link in the email to verify your account.',
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 32),

              _WaitingIndicator(),

              const SizedBox(height: 40),

              Obx(() {
                final secs = controller.verificationCountdown.value;
                return AppButton(
                  label: secs > 0
                      ? 'Resend in ${secs}s'
                      : 'Resend Verification Email',
                  onPressed: secs > 0
                      ? () {}
                      : controller.resendVerificationEmail,
                  color: secs > 0 ? AppColors.cardBorder : AppColors.primary,
                );
              }).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Get.find<FirebaseAuthService>().signOut(),
                child: Text(
                  'Use a different account',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),

              Obx(
                () => controller.errorMessage.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          controller.errorMessage.value,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.danger),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedEmailIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                  width: 1,
                ),
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 0.95, end: 1.05, duration: 2000.ms),

        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.08),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1.5,
            ),
          ),
        ),

        const Text('📧', style: TextStyle(fontSize: 44))
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.5, 0.5))
            .then()
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -6, duration: 2000.ms),
      ],
    );
  }
}

class _WaitingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Waiting for verification…',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}
