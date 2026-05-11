import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../data/models/grocery_model.dart';

class DashboardController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  final isLoading = true.obs;
  final allItems = <GroceryItem>[].obs;
  final errorMsg = ''.obs;

  int get totalItems => allItems.where((i) => i.status != 'consumed').length;
  int get expiringCount => allItems.where((i) => i.status == 'expiring').length;
  int get expiredCount => allItems.where((i) => i.status == 'expired').length;
  int get freshCount => allItems.where((i) => i.status == 'fresh').length;

  List<GroceryItem> get expiringItems =>
      allItems
          .where((i) => i.status == 'expiring' || i.status == 'expired')
          .toList()
        ..sort((a, b) => (a.daysLeft ?? 999).compareTo(b.daysLeft ?? 999));

  List<GroceryItem> get useFirstItems => expiringItems.take(5).toList();

  List<GroceryItem> itemsByZone(String zone) =>
      allItems.where((i) => i.storageZone == zone).toList();

  int countByZone(String zone) => itemsByZone(zone).length;

  @override
  void onInit() {
    super.onInit();
    _listenToItems();
  }

  void _listenToItems() {
    if (_uid.isEmpty) {
      isLoading.value = false;
      return;
    }

    _db
        .collection('users')
        .doc(_uid)
        .collection('grocery_items')
        .snapshots()
        .listen(
          (snap) {
            allItems.value = snap.docs
                .map((d) => GroceryItem.fromFirestore(d.data(), d.id))
                .toList();
            isLoading.value = false;
          },
          onError: (e) {
            errorMsg.value = 'Failed to load items.';
            isLoading.value = false;
          },
        );
  }

  Future<void> refresh() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    isLoading.value = false;
  }

  String greetingText() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
