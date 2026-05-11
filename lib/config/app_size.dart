import 'package:flutter/material.dart';
import 'package:get/get.dart';

class R {
  static double get _w => Get.width;
  static double get _h => Get.height;

  static const double _baseW = 390.0;
  static const double _baseH = 844.0;

  static double w(double v) => v * (_w / _baseW);
  static double h(double v) => v * (_h / _baseH);
  static double sp(double v) => v * (_w / _baseW);
  static double r(double v) => v * (_w / _baseW);

  static double fs(double v) => (v * (_w / _baseW)).clamp(v * 0.85, v * 1.2);

  static bool get isSmall => _w < 360;
  static bool get isMedium => _w >= 360 && _w < 414;
  static bool get isLarge => _w >= 414;
  static bool get isTablet => _w >= 600;

  static EdgeInsets get pagePadding => EdgeInsets.symmetric(horizontal: w(24));
  static EdgeInsets get cardPadding => EdgeInsets.all(r(16));
}
