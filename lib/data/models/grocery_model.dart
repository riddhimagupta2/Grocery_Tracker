import 'package:cloud_firestore/cloud_firestore.dart';


class GroceryItem {
  final String id;
  final String name;
  final String emoji;
  final String storageZone;
  final DateTime? expiryDate;
  final String status;

  GroceryItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.storageZone,
    this.expiryDate,
    required this.status,
  });

  int? get daysLeft {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  factory GroceryItem.fromFirestore(Map<String, dynamic> d, String id) {
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
    return GroceryItem(
      id: id,
      name: d['name'] ?? '',
      emoji: d['emoji'] ?? '📦',
      storageZone: d['storage_zone'] ?? 'pantry',
      expiryDate: expiry,
      status: status,
    );
  }
}
