import 'package:cloud_firestore/cloud_firestore.dart';

class KitchenItem {
  final String id;
  final String name;
  final String emoji;
  final String storageZone;
  final DateTime? expiryDate;
  final String status;
  final String brand;
  final double quantity;
  final String unit;
  final int? caloriesPer100g;
  final List<String> allergens;
  final String storageTip;

  KitchenItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.storageZone,
    this.expiryDate,
    required this.status,
    this.brand = '',
    this.quantity = 1,
    this.unit = 'pcs',
    this.caloriesPer100g,
    this.allergens = const [],
    this.storageTip = '',
  });

  int? get daysLeft {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  factory KitchenItem.fromFirestore(Map<String, dynamic> d, String id) {
    final expiry = d['expiry_date'] != null
        ? (d['expiry_date'] as Timestamp).toDate()
        : null;
    final days = expiry?.difference(DateTime.now()).inDays;
    String status = 'fresh';
    if (days != null) {
      if (days < 0)
        status = 'expired';
      else if (days <= 3)
        status = 'expiring';
    }
    return KitchenItem(
      id: id,
      name: d['name'] ?? '',
      emoji: d['emoji'] ?? '📦',
      storageZone: d['storage_zone'] ?? 'pantry',
      expiryDate: expiry,
      status: status,
      brand: d['brand'] ?? '',
      quantity: (d['quantity'] ?? 1).toDouble(),
      unit: d['unit'] ?? 'pcs',
      caloriesPer100g: d['calories_per_100g'],
      allergens: List<String>.from(d['allergens'] ?? []),
      storageTip: d['storage_notes'] ?? '',
    );
  }
}

class KitchenZone {
  final String id;
  final String label;
  final String emoji;
  final List<KitchenItem> items;

  KitchenZone({
    required this.id,
    required this.label,
    required this.emoji,
    required this.items,
  });

  int get itemCount => items.length;
  int get expiringCount => items
      .where((i) => i.status == 'expiring' || i.status == 'expired')
      .length;
}