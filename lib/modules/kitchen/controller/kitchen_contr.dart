import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/kitchen_item.dart';

class KitchenController extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  final isLoading = true.obs;
  final allItems = <KitchenItem>[].obs;
  final selectedZone = ''.obs;
  final selectedItem = Rx<KitchenItem?>(null);
  final errorMsg = ''.obs;

  static const _zoneConfig = [
    {'id': 'fridge', 'label': 'Refrigerator', 'emoji': '❄️'},
    {'id': 'pantry', 'label': 'Pantry Shelf', 'emoji': '🗄️'},
    {'id': 'spice', 'label': 'Spice Cabinet', 'emoji': '🧂'},
    {'id': 'counter', 'label': 'Countertop', 'emoji': '🍽️'},
    {'id': 'cabinet', 'label': 'Cabinet', 'emoji': '🚪'},
    {'id': 'basket', 'label': 'Root Basket', 'emoji': '🧺'},
  ];

  List<KitchenZone> get zones => _zoneConfig.map((cfg) {
    final zItems = allItems.where((i) => i.storageZone == cfg['id']).toList();
    return KitchenZone(
      id: cfg['id']!,
      label: cfg['label']!,
      emoji: cfg['emoji']!,
      items: zItems,
    );
  }).toList();

  KitchenZone zoneById(String id) {
    return zones.firstWhere(
      (z) => z.id == id,
      orElse: () => KitchenZone(id: id, label: id, emoji: '📦', items: []),
    );
  }

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
                .map((d) => KitchenItem.fromFirestore(d.data(), d.id))
                .toList();
            isLoading.value = false;
          },
          onError: (e) {
            errorMsg.value = 'Could not load kitchen data.';
            isLoading.value = false;
          },
        );
  }

  void openZone(String id) {
    selectedZone.value = id;
    Get.toNamed('/storage-zone');
  }

  void openItem(KitchenItem item) {
    selectedItem.value = item;
    Get.toNamed('/item-detail');
  }

  Future<void> deleteItem(String id) async {
    try {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('grocery_items')
          .doc(id)
          .delete();
      Get.back();
      Get.snackbar(
        '🗑️ Deleted',
        'Item removed from kitchen.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not delete item.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> markConsumed(String id) async {
    try {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('grocery_items')
          .doc(id)
          .update({'status': 'consumed'});
      Get.back();
      Get.snackbar(
        '✅ Done',
        'Marked as consumed!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {}
  }

  int get totalItems => allItems.length;
  int get expiringCount => allItems.where((i) => i.status == 'expiring').length;
  int get expiredCount => allItems.where((i) => i.status == 'expired').length;
}
