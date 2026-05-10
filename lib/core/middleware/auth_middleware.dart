import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/auth_provider.dart';
import '../../config/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<FirebaseAuthService>();

    if (!authService.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}