import 'package:get/get.dart';
import 'package:grocery_track/modules/home/views/dashboard.dart';
import 'package:grocery_track/modules/home/views/home_view.dart';
import 'package:grocery_track/modules/kitchen/views/kitchen_views.dart';
import 'package:grocery_track/modules/profile/view/profile_view.dart';
import 'package:grocery_track/modules/scan/view/scan_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/forget_pss.dart';
import '../modules/auth/views/onbording_screen.dart';
import '../modules/auth/views/splash_screen.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../modules/auth/views/verify_view.dart';
import '../modules/home/bindings/home_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () =>  LoginView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () =>  SignupView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 350),
    ),

    GetPage(
      name:    AppRoutes.forgotPassword,
      page:    () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name:    AppRoutes.verifyEmail,
      page:    () => const VerifyEmailView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

   GetPage(
      name: AppRoutes.kitchen,
      page: () => const KitchenView(),
      binding: HomeBinding(),
    ),GetPage(
      name: AppRoutes.scan,
      page: () => const ScanView(),
      binding: HomeBinding(),
    ),GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: HomeBinding(),
    ),
  ];
}