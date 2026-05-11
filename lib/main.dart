import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/app_routes.dart';
import 'config/app_pages.dart';
import 'config/app_theme.dart';
import 'core/service/auth_service.dart';
import 'data/providers/api_client.dart';
import 'data/repo/auth_repo.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  Get.put(UserRepository());
  Get.put<FirebaseAuthService>(FirebaseAuthService(), permanent: true);
  Get.put<ApiClient>(ApiClient(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return GetMaterialApp(
          title: 'FreshTrack',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),

          locale: const Locale('en', 'IN'),
          fallbackLocale: const Locale('en', 'US'),
        );
      },
    );
  }
}
