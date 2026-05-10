import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/app_routes.dart';
import '../../../core/service/auth_service.dart';

class AuthController extends GetxController {
  final _authService = Get.find<FirebaseAuthService>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final forgotEmailController = TextEditingController();

  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();
  final forgotFormKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmVisible = false.obs;
  final errorMessage = ''.obs;
  final currentOnboardPage = 0.obs;
  final forgotEmailSent = false.obs;
  final isVerificationSent = false.obs;
  final verificationCountdown = 0.obs;

  Timer? _verifyTimer;
  Timer? _countdownTimer;
  final pageController = PageController();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    forgotEmailController.dispose();
    pageController.dispose();
    _verifyTimer?.cancel();
    _countdownTimer?.cancel();
    super.onClose();
  }

  Future<void> checkInitialRoute() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    final prefs = await SharedPreferences.getInstance();
    final onboardDone = prefs.getBool('onboarding_complete') ?? false;

    if (_authService.isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else if (!onboardDone) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void nextOnboardPage() {
    if (currentOnboardPage.value < 2) {
      currentOnboardPage.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      finishOnboarding();
    }
  }

  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    _clearError();
    isLoading.value = true;
    try {
      await _authService.signInWithEmail(
        email: emailController.text,
        password: passwordController.text,
      );
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    _clearError();
    isLoading.value = true;
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null) Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup() async {
    if (!signupFormKey.currentState!.validate()) return;
    _clearError();
    isLoading.value = true;
    try {
      await _authService.signUpWithEmail(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
      );
      Get.offAllNamed(AppRoutes.verifyEmail);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void startVerificationPolling() {
    isVerificationSent.value = true;
    _verifyTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      final verified = await _authService.reloadAndCheckVerified();
      if (verified) {
        _verifyTimer?.cancel();
        _countdownTimer?.cancel();
        Get.offAllNamed(AppRoutes.home);
      }
    });
  }

  Future<void> resendVerificationEmail() async {
    if (verificationCountdown.value > 0) return;
    try {
      await _authService.resendVerificationEmail();
      _startResendCountdown();
      Get.snackbar(
        'Email sent',
        'Check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  void _startResendCountdown() {
    verificationCountdown.value = 60;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (verificationCountdown.value > 0) {
        verificationCountdown.value--;
      } else {
        t.cancel();
      }
    });
  }

  Future<void> sendForgotPassword() async {
    if (!forgotFormKey.currentState!.validate()) return;
    _clearError();
    isLoading.value = true;
    try {
      await _authService.sendPasswordReset(forgotEmailController.text);
      forgotEmailSent.value = true;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void resetForgotState() {
    forgotEmailSent.value = false;
    forgotEmailController.clear();
    _clearError();
  }

  String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _clearError() => errorMessage.value = '';
  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmVisibility() => isConfirmVisible.toggle();
  void goToLogin() => Get.offAllNamed(AppRoutes.login);
  void goToSignup() => Get.toNamed(AppRoutes.signup);
  void goToForgotPassword() => Get.toNamed(AppRoutes.forgotPassword);
}
