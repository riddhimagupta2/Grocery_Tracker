import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_theme.dart';

class BackBtn extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;

  const BackBtn({super.key, this.onTap, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: onTap ?? Get.back,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(size * 0.3),
              border: Border.all(color: AppColors.cardBorder, width: 0.5),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: size * 0.38,
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.2, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}
