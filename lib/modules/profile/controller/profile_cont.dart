import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../config/app_routes.dart';
import '../../../core/service/auth_service.dart';

class ProfileController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final notify3Days = true.obs;
  final notify1Day = true.obs;
  final notifyDailyRecipe = false.obs;
  final dietType = 'Vegetarian'.obs;
  final cuisine = 'North Indian'.obs;
  final householdSize = 1.obs;

  User? get user => _auth.currentUser;
  String get name => user?.displayName ?? 'User';
  String get email => user?.email ?? '';
  String get avatar => name.isNotEmpty ? name[0].toUpperCase() : 'U';

  final totalTracked = 27.obs;
  final savedFromWaste = 8.obs;
  final recipesCooked = 14.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final uid = user?.uid;
    if (uid == null) return;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final d = doc.data()!;
        notify3Days.value = d['notify_3_days'] ?? true;
        notify1Day.value = d['notify_1_day'] ?? true;
        notifyDailyRecipe.value = d['notify_daily_recipe'] ?? false;
        dietType.value = d['diet_type'] ?? 'Vegetarian';
        cuisine.value = d['cuisine_pref'] ?? 'North Indian';
        householdSize.value = d['household_size'] ?? 1;
        totalTracked.value = d['total_tracked'] ?? 0;
        savedFromWaste.value = d['saved_from_waste'] ?? 0;
        recipesCooked.value = d['recipes_cooked'] ?? 0;
      }
    } catch (_) {}
  }

  Future<void> savePrefs() async {
    final uid = user?.uid;
    if (uid == null) return;
    isLoading.value = true;
    try {
      await _db.collection('users').doc(uid).set({
        'notify_3_days': notify3Days.value,
        'notify_1_day': notify1Day.value,
        'notify_daily_recipe': notifyDailyRecipe.value,
        'diet_type': dietType.value,
        'cuisine_pref': cuisine.value,
        'household_size': householdSize.value,
      }, SetOptions(merge: true));
      Get.snackbar(
        '✅ Saved',
        'Preferences updated.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not save preferences.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await Get.find<FirebaseAuthService>().signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  void toggleNotify3Days() => notify3Days.toggle();
  void toggleNotify1Day() => notify1Day.toggle();
  void toggleNotifyDailyRecipe() => notifyDailyRecipe.toggle();
}
