import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_colour.dart';

class AppLogoSmall extends StatelessWidget {
  final double size;
  final bool showGlow;

  const AppLogoSmall({super.key, this.size = 52, this.showGlow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.3),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D3D20), Color(0xFF041A0C)],
            ),
            border: Border.all(color: const Color(0xFF1A4A28), width: 1),
            boxShadow: showGlow
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.28),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text('🌿', style: TextStyle(fontSize: size * 0.46)),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.75, 0.75),
          end: const Offset(1, 1),
          duration: 450.ms,
          curve: Curves.easeOutBack,
        );
  }
}
