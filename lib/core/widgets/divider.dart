import 'package:flutter/material.dart';
import '../../config/app_colour.dart';

class OrDivider extends StatelessWidget {
  final String label;

  const OrDivider({super.key, this.label = 'or continue with'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.cardBorder, thickness: 0.5),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.02,
            ),
          ),
        ),

        const Expanded(
          child: Divider(color: AppColors.cardBorder, thickness: 0.5),
        ),
      ],
    );
  }
}
