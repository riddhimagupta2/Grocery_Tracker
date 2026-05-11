import 'package:get/get.dart';
import '../../../core/service/auth_service.dart';
import '../controllers/auth_cont.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FirebaseAuthService>(() => FirebaseAuthService(),fenix: true,);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
