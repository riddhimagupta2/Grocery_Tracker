import '../../data/models/grocery_model.dart';

class AISearchService {
  /// Parses natural language search queries and filters list of groceries
  static List<GroceryModel> filter(List<GroceryModel> items, String query) {
    if (query.trim().isEmpty) return items;

    final normalized = query.toLowerCase().trim();

    // Break query into logical match tokens
    final isDairy = normalized.contains('dairy') || normalized.contains('milk') || normalized.contains('cheese');
    final isFruit = normalized.contains('fruit') || normalized.contains('apple') || normalized.contains('banana');
    final isVegetable = normalized.contains('vegetable') || normalized.contains('veg') || normalized.contains('tomato') || normalized.contains('potato');
    final isMeat = normalized.contains('meat') || normalized.contains('chicken') || normalized.contains('fish');
    final isSpice = normalized.contains('spice') || normalized.contains('pepper') || normalized.contains('salt');
    
    final isExpiringTomorrow = normalized.contains('expiring tomorrow') || normalized.contains('expire tomorrow');
    final isExpiringSoon = normalized.contains('expiring soon') || normalized.contains('expiring') || normalized.contains('expire soon');
    final isExpired = normalized.contains('expired');
    final isFresh = normalized.contains('fresh') || normalized.contains('good');

    final isOpened = normalized.contains('opened') || normalized.contains('open');
    final isUnopened = normalized.contains('unopened');

    final isFridge = normalized.contains('fridge') || normalized.contains('refrigerator');
    final isPantry = normalized.contains('pantry');
    final isFreezer = normalized.contains('freezer');

    final isOverripe = normalized.contains('overripe');
    final isRipe = normalized.contains('ripe') && !isOverripe;
    final isUnripe = normalized.contains('unripe');

    return items.where((item) {
      final name = item.name.toLowerCase();
      final category = item.category.toLowerCase();
      final zone = item.storageZone.toLowerCase();
      final status = item.status.toLowerCase();

      // Check Category tokens
      if (isDairy && !category.contains('dairy') && !name.contains('milk') && !name.contains('cheese') && !name.contains('butter') && !name.contains('yogurt')) return false;
      if (isFruit && !category.contains('fruit') && !name.contains('apple') && !name.contains('banana') && !name.contains('orange') && !name.contains('mango')) return false;
      if (isVegetable && !category.contains('veg') && !name.contains('tomato') && !name.contains('potato') && !name.contains('onion') && !name.contains('carrot')) return false;
      if (isMeat && !category.contains('meat') && !category.contains('fish') && !name.contains('chicken') && !name.contains('fish') && !name.contains('pork') && !name.contains('beef')) return false;
      if (isSpice && !category.contains('spice') && !name.contains('pepper') && !name.contains('salt') && !name.contains('chili') && !name.contains('garlic')) return false;

      // Check Expiry / Freshness tokens
      if (isExpiringTomorrow) {
        if (item.expiryDate == null) return false;
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final diff = item.expiryDate!.difference(DateTime.now()).inDays;
        if (diff != 1 && (item.expiryDate!.year != tomorrow.year || item.expiryDate!.month != tomorrow.month || item.expiryDate!.day != tomorrow.day)) {
          return false;
        }
      } else if (isExpiringSoon) {
        if (status != 'expiring' && (item.expiryDate == null || item.expiryDate!.difference(DateTime.now()).inDays > 3)) return false;
      } else if (isExpired) {
        if (status != 'expired') return false;
      } else if (isFresh) {
        if (status != 'fresh') return false;
      }

      // Check Packaging state
      if (isUnopened && item.isOpened) return false;
      if (isOpened && !isUnopened && !item.isOpened) return false;

      // Check Storage location
      if (isFridge && zone != 'fridge') return false;
      if (isPantry && zone != 'pantry') return false;
      if (isFreezer && zone != 'freezer') return false;

      // Check Ripeness
      if (isOverripe && item.ripeness != 'overripe') return false;
      if (isRipe && item.ripeness != 'ripe') return false;
      if (isUnripe && item.ripeness != 'unripe') return false;

      // Simple keyword fallback matching if no structured token matched
      if (!isDairy && !isFruit && !isVegetable && !isMeat && !isSpice && 
          !isExpiringTomorrow && !isExpiringSoon && !isExpired && !isFresh && 
          !isOpened && !isUnopened && !isFridge && !isPantry && !isFreezer && 
          !isOverripe && !isRipe && !isUnripe) {
        return name.contains(normalized) || category.contains(normalized) || zone.contains(normalized);
      }

      return true;
    }).toList();
  }
}
