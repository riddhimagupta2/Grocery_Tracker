import 'package:get/get.dart';
import 'package:grocery_track/modules/kitchen/controller/kitchen_contr.dart';
import '../../profile/controller/profile_cont.dart';
import '../../scan/controller/scan_cont.dart';
import '../controllers/dashboard_cont.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<KitchenController>(() => KitchenController());
    Get.lazyPut<ScanController>(() => ScanController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}