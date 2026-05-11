import 'package:flutter/material.dart';
import '../../config/app_colour.dart';

enum SocialType { google, apple }

class SocialButton extends StatelessWidget {
  final SocialType type;

  final String label;

  final VoidCallback onPressed;

  final bool isLoading;

  const SocialButton({
    super.key,
    required this.type,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.cardBorder, width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textSecondary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialLogo(type: type),
                  const SizedBox(width: 12),

                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SocialLogo extends StatelessWidget {
  final SocialType type;
  const _SocialLogo({required this.type});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      type == SocialType.google
          ? 'assets/icons/google_logo.png'
          : 'assets/icons/apple_logo.png',
      width: 20,
      height: 20,
      errorBuilder: (_, __, ___) => _FallbackIcon(type: type),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  final SocialType type;
  const _FallbackIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == SocialType.google) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'G',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEA4335),
            ),
          ),
        ),
      );
    }

    return const Icon(Icons.apple, size: 22, color: AppColors.textPrimary);
  }
}
