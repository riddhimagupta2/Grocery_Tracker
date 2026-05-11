import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF1DB868);
  static const primaryDark = Color(0xFF0FA050);
  static const primaryDeep = Color(0xFF0A6E38);

  static const bgDark = Color(0xFF0A0F0D);
  static const surface = Color(0xFF111A14);
  static const card = Color(0xFF162019);
  static const cardBorder = Color(0xFF1E3024);

  static const textPrimary = Color(0xFFF0F7F2);
  static const textSecondary = Color(0xFF6B8F74);
  static const textHint = Color(0xFF3A5030);

  static const success = Color(0xFF1DB868);
  static const warning = Color(0xFFF5A623);
  static const danger = Color(0xFFE84545);
  static const info = Color(0xFF4A9EFF);

  static const divider = Color(0xFF1E3024);
  static const overlay = Color(0x99000000);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1DB868), Color(0xFF0FA050)],
  );
  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0F0D), Color(0xFF0A0F0D)],
  );

  static const splashGradient = RadialGradient(
    center: Alignment(0, -0.3),
    radius: 1.2,
    colors: [Color(0xFF0D2B1A), Color(0xFF050C07), Color(0xFF030805)],
  );
}