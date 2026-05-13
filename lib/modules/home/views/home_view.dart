import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:grocery_track/modules/kitchen/views/kitchen_views.dart';
import '../../../config/app_colour.dart';
import '../../../config/app_size.dart';
import '../../profile/view/profile_view.dart';
import '../../scan/view/scan_view.dart';
import '../controllers/home_controller.dart';
import 'dashboard.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Obx(
        () => IndexedStack(
          index: ctrl.currentIndex.value,
          children: const [
            DashboardView(),
            KitchenView(),
            _RecipesPlaceholder(),
            ProfileView(),
          ],
        ),
      ),
      floatingActionButton: _ScanFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(
          top: BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                ctrl: ctrl,
              ),
              _NavItem(
                index: 1,
                icon: Icons.kitchen_outlined,
                activeIcon: Icons.kitchen_rounded,
                label: 'Kitchen',
                ctrl: ctrl,
              ),

              const SizedBox(width: 72),
              _NavItem(
                index: 2,
                icon: Icons.restaurant_menu_outlined,
                activeIcon: Icons.restaurant_menu_rounded,
                label: 'Recipes',
                ctrl: ctrl,
              ),
              _NavItem(
                index: 3,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                ctrl: ctrl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final HomeController ctrl;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final active = ctrl.currentIndex.value == index;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ctrl.changeTab(index);
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    active ? activeIcon : icon,
                    key: ValueKey(active),
                    color: active ? AppColors.primary : AppColors.textHint,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? AppColors.primary : AppColors.textHint,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ScanFAB extends StatelessWidget {
  const _ScanFAB();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _openScanSheet(context);
      },
      child: Container(
        width: R.w(56),
        height: R.w(56),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          Icons.qr_code_scanner_rounded,
          color: AppColors.white,
          size: R.sp(26),
        ),
      ),
    );
  }

  void _openScanSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      useSafeArea: true,
      builder: (_) => const _ScanSheet(),
    );
  }
}

class _ScanSheet extends StatelessWidget {
  const _ScanSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.5, 0.95],
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
            border: Border.all(color: AppColors.cardBorder, width: 0.5),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: R.h(12), bottom: R.h(4)),
                child: Container(
                  width: R.w(40),
                  height: R.h(4),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(R.r(2)),
                  ),
                ),
              ),

              const Expanded(child: ScanView()),
            ],
          ),
        );
      },
    );
  }
}

class _RecipesPlaceholder extends StatelessWidget {
  const _RecipesPlaceholder();
  @override
  Widget build(BuildContext context) => const _ComingSoon(
    emoji: '👨‍🍳',
    title: 'Recipes',
    subtitle: 'AI recipes coming soon',
  );
}

class _ComingSoon extends StatelessWidget {
  final String emoji, title, subtitle;
  const _ComingSoon({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
