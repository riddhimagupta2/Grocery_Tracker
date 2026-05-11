import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../config/app_colour.dart';
import '../../../config/app_routes.dart';
import '../../profile/view/profile_view.dart';
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
            _KitchenPlaceholder(),
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Get.toNamed(AppRoutes.scan);
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: AppColors.white,
          size: 26,
        ),
      ),
    );
  }
}

class _KitchenPlaceholder extends StatelessWidget {
  const _KitchenPlaceholder();
  @override
  Widget build(BuildContext context) => const _ComingSoon(
    emoji: '🏪',
    title: 'Kitchen',
    subtitle: 'Storage zones coming soon',
  );
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
