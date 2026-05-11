import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../config/app_colour.dart';
import '../../../data/models/grocery_model.dart';
import '../controllers/dashboard_cont.dart';
import '../controllers/home_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DashboardController>();
    final hCtrl = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.card,
          onRefresh: ctrl.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _TopBar(ctrl: ctrl, hCtrl: hCtrl),
              ),

              SliverToBoxAdapter(
                child: Obx(
                  () => ctrl.expiringCount > 0
                      ? _AlertBanner(
                          count: ctrl.expiringCount,
                        ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2)
                      : const SizedBox.shrink(),
                ),
              ),

              SliverToBoxAdapter(
                child: _StatsRow(ctrl: ctrl).animate().fadeIn(delay: 150.ms),
              ),

              SliverToBoxAdapter(
                child: Obx(
                  () => ctrl.useFirstItems.isNotEmpty
                      ? _UseFirstSection(
                          ctrl: ctrl,
                        ).animate().fadeIn(delay: 200.ms)
                      : const SizedBox.shrink(),
                ),
              ),

              SliverToBoxAdapter(
                child: _ExpirySectionHeader().animate().fadeIn(delay: 250.ms),
              ),
              SliverToBoxAdapter(
                child: Obx(
                  () => ctrl.isLoading.value
                      ? _ShimmerRow()
                      : _ExpiryScrollRow(ctrl: ctrl),
                ).animate().fadeIn(delay: 300.ms),
              ),

              SliverToBoxAdapter(
                child: _StorageSectionHeader().animate().fadeIn(delay: 350.ms),
              ),
              SliverToBoxAdapter(
                child: _StorageGrid(ctrl: ctrl).animate().fadeIn(delay: 400.ms),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final DashboardController ctrl;
  final HomeController hCtrl;
  const _TopBar({required this.ctrl, required this.hCtrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ctrl.greetingText()}, ${hCtrl.displayName} 👋',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    '${ctrl.totalItems} items in your kitchen',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder, width: 0.5),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              Obx(
                () => ctrl.expiringCount > 0
                    ? Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.bgDark,
                              width: 1.5,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(width: 10),

          GestureDetector(
            onTap: () => Get.find<HomeController>().changeTab(3),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  hCtrl.avatarLetter,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final int count;
  const _AlertBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.danger.withOpacity(0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count item${count > 1 ? 's' : ''} expiring soon — check recipes!',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: Color(0xFFFF8080),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: Color(0xFFFF8080),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final DashboardController ctrl;
  const _StatsRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Obx(
        () => Row(
          children: [
            _StatCard(
              value: '${ctrl.freshCount}',
              label: 'Fresh',
              color: AppColors.success,
            ),
            const SizedBox(width: 10),
            _StatCard(
              value: '${ctrl.expiringCount}',
              label: 'Expiring',
              color: AppColors.warning,
            ),
            const SizedBox(width: 10),
            _StatCard(
              value: '${ctrl.expiredCount}',
              label: 'Expired',
              color: AppColors.danger,
            ),
            const SizedBox(width: 10),
            _StatCard(
              value: '${ctrl.totalItems}',
              label: 'Total',
              color: AppColors.info,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2), width: 0.8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UseFirstSection extends StatelessWidget {
  final DashboardController ctrl;
  const _UseFirstSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Use These First',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: ctrl.useFirstItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final item = ctrl.useFirstItems[i];
              return _UseFirstCard(item: item, rank: i + 1);
            },
          ),
        ),
      ],
    );
  }
}

class _UseFirstCard extends StatelessWidget {
  final GroceryItem item;
  final int rank;
  const _UseFirstCard({required this.item, required this.rank});

  @override
  Widget build(BuildContext context) {
    final days = item.daysLeft;
    final isExp = item.status == 'expired';
    final daysStr = isExp
        ? 'Expired'
        : days == 0
        ? 'Today!'
        : days == 1
        ? 'Tomorrow'
        : '$days days left';

    final statusColor = isExp
        ? AppColors.danger
        : days != null && days <= 1
        ? AppColors.danger
        : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withOpacity(0.15),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(item.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  item.storageZone.capitalizeFirst ?? '',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              daysStr,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpirySectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Expiry Tracker',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'See all',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryScrollRow extends StatelessWidget {
  final DashboardController ctrl;
  const _ExpiryScrollRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final items = ctrl.allItems.take(10).toList();
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder, width: 0.5),
          ),
          child: const Center(
            child: Text(
              'No items yet — tap + to add grocery',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _ExpiryCard(item: items[i]),
      ),
    );
  }
}

class _ExpiryCard extends StatelessWidget {
  final GroceryItem item;
  const _ExpiryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final days = item.daysLeft;
    final isExp = item.status == 'expired';
    final isWarn = item.status == 'expiring';

    final Color borderColor = isExp
        ? AppColors.danger.withOpacity(0.4)
        : isWarn
        ? AppColors.warning.withOpacity(0.4)
        : AppColors.success.withOpacity(0.25);

    final Color bgColor = isExp
        ? AppColors.danger.withOpacity(0.06)
        : isWarn
        ? AppColors.warning.withOpacity(0.06)
        : AppColors.success.withOpacity(0.04);

    final Color textColor = isExp
        ? AppColors.danger
        : isWarn
        ? AppColors.warning
        : AppColors.success;

    final String daysText = isExp
        ? 'Expired!'
        : days == 0
        ? 'Today!'
        : days == 1
        ? '1 day'
        : '$days days';

    double fill = 1.0;
    if (!isExp && days != null) fill = (days / 30.0).clamp(0.0, 1.0);

    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            daysText,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: fill,
              minHeight: 3,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation(textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageSectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Text(
        'Storage Zones',
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _StorageGrid extends StatelessWidget {
  final DashboardController ctrl;
  const _StorageGrid({required this.ctrl});

  static const _zones = [
    _ZoneData(
      'fridge',
      '❄️',
      'Refrigerator',
      Color(0xFF4A9EFF),
      Color(0xFF0D2535),
    ),
    _ZoneData('pantry', '🗄️', 'Pantry', Color(0xFFF5A623), Color(0xFF251A0D)),
    _ZoneData(
      'counter',
      '🍽️',
      'Countertop',
      Color(0xFFD4D445),
      Color(0xFF1A1A0D),
    ),
    _ZoneData(
      'basket',
      '🧺',
      'Root Basket',
      Color(0xFF1DB868),
      Color(0xFF0D2010),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.45,
        ),
        itemCount: _zones.length,
        itemBuilder: (_, i) => Obx(
          () => _ZoneCard(
            zone: _zones[i],
            count: ctrl.countByZone(_zones[i].key),
            items: ctrl.itemsByZone(_zones[i].key).take(3).toList(),
          ),
        ),
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final _ZoneData zone;
  final int count;
  final List<GroceryItem> items;
  const _ZoneCard({
    required this.zone,
    required this.count,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: zone.bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: zone.accent.withOpacity(0.25), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: zone.accent.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: zone.accent.withOpacity(0.15),
                  ),
                  child: Center(
                    child: Text(
                      zone.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: zone.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: zone.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              zone.label,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            if (items.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: items
                    .map(
                      (i) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: zone.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${i.emoji} ${i.name}',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: zone.accent,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            else
              Text(
                'Empty',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  color: zone.accent.withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ZoneData {
  final String key, emoji, label;
  final Color accent, bg;
  const _ZoneData(this.key, this.emoji, this.label, this.accent, this.bg);
}

class _ShimmerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, __) => _ShimmerCard(),
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ac, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 110,
        height: 120,
        decoration: BoxDecoration(
          color: Color.lerp(AppColors.card, AppColors.surface, _anim.value),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
      ),
    );
  }
}
