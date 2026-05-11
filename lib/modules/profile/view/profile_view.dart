import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../config/app_colour.dart';
import '../controller/profile_cont.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                ctrl: ctrl,
              ).animate().fadeIn(duration: 400.ms),
            ),

            SliverToBoxAdapter(
              child: _StatsRow(ctrl: ctrl).animate().fadeIn(delay: 100.ms),
            ),

            SliverToBoxAdapter(
              child: _SectionTitle(
                title: 'Diet Preferences',
              ).animate().fadeIn(delay: 150.ms),
            ),
            SliverToBoxAdapter(
              child: _DietSection(ctrl: ctrl).animate().fadeIn(delay: 200.ms),
            ),

            SliverToBoxAdapter(
              child: _SectionTitle(
                title: 'Notifications',
              ).animate().fadeIn(delay: 250.ms),
            ),
            SliverToBoxAdapter(
              child: _NotificationsSection(
                ctrl: ctrl,
              ).animate().fadeIn(delay: 300.ms),
            ),

            SliverToBoxAdapter(
              child: const _SectionTitle(
                title: 'Account',
              ).animate().fadeIn(delay: 350.ms),
            ),
            SliverToBoxAdapter(
              child: _AccountSection(
                ctrl: ctrl,
              ).animate().fadeIn(delay: 400.ms),
            ),

            SliverToBoxAdapter(
              child: _SignOutButton(ctrl: ctrl).animate().fadeIn(delay: 450.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProfileController ctrl;
  const _ProfileHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    ctrl.avatar,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ctrl.name,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ctrl.email,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.25),
                          width: 0.8,
                        ),
                      ),
                      child: const Text(
                        '🌿 FreshTrack Member',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ProfileController ctrl;
  const _StatsRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Obx(
        () => Row(
          children: [
            _Stat(value: '${ctrl.totalTracked.value}', label: 'Items Tracked'),
            _StatDivider(),
            _Stat(
              value: '${ctrl.savedFromWaste.value}',
              label: 'Saved from Waste',
            ),
            _StatDivider(),
            _Stat(
              value: '${ctrl.recipesCooked.value}',
              label: 'Recipes Cooked',
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 10,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 0.5, height: 36, color: AppColors.cardBorder);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.08,
        ),
      ),
    );
  }
}

class _DietSection extends StatelessWidget {
  final ProfileController ctrl;
  const _DietSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _Card(
      children: [
        Obx(
          () => _PickerTile(
            icon: '🥗',
            label: 'Diet Type',
            value: ctrl.dietType.value,
            options: ['Vegetarian', 'Non-Vegetarian', 'Vegan'],
            onSelect: (v) => ctrl.dietType.value = v,
          ),
        ),
        _Divider(),
        Obx(
          () => _PickerTile(
            icon: '🍛',
            label: 'Cuisine',
            value: ctrl.cuisine.value,
            options: [
              'North Indian',
              'South Indian',
              'Chinese',
              'Italian',
              'Continental',
            ],
            onSelect: (v) => ctrl.cuisine.value = v,
          ),
        ),
        _Divider(),
        Obx(
          () => _StepperTile(
            icon: '👨‍👩‍👧',
            label: 'Household Size',
            value: ctrl.householdSize.value,
            onDecrement: () {
              if (ctrl.householdSize.value > 1) ctrl.householdSize.value--;
            },
            onIncrement: () {
              if (ctrl.householdSize.value < 10) ctrl.householdSize.value++;
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationsSection extends StatelessWidget {
  final ProfileController ctrl;
  const _NotificationsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _Card(
      children: [
        Obx(
          () => _ToggleTile(
            icon: '⏰',
            label: '3 days before expiry',
            value: ctrl.notify3Days.value,
            onToggle: ctrl.toggleNotify3Days,
          ),
        ),
        _Divider(),
        Obx(
          () => _ToggleTile(
            icon: '🚨',
            label: '1 day before expiry',
            value: ctrl.notify1Day.value,
            onToggle: ctrl.toggleNotify1Day,
          ),
        ),
        _Divider(),
        Obx(
          () => _ToggleTile(
            icon: '👨‍🍳',
            label: 'Daily recipe suggestion',
            value: ctrl.notifyDailyRecipe.value,
            onToggle: ctrl.toggleNotifyDailyRecipe,
          ),
        ),
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  final ProfileController ctrl;
  const _AccountSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _Card(
      children: [
        _LinkTile(icon: '🔒', label: 'Privacy Policy', onTap: () {}),
        _Divider(),
        _LinkTile(icon: '📄', label: 'Terms of Service', onTap: () {}),
        _Divider(),
        _LinkTile(
          icon: 'ℹ️',
          label: 'App Version',
          trailing: const Text(
            'v1.0.0',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          onTap: () {},
        ),
      ],
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final ProfileController ctrl;
  const _SignOutButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: ctrl.isLoading.value
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    _showSignOutDialog(context, ctrl);
                  },
            icon: ctrl.isLoading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: AppColors.danger,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.logout_rounded,
                    color: AppColors.danger,
                    size: 18,
                  ),
            label: Text(
              ctrl.isLoading.value ? 'Signing out...' : 'Sign Out',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.danger,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppColors.danger.withOpacity(
                  ctrl.isLoading.value ? 0.3 : 0.6,
                ),
                width: 0.8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext ctx, ProfileController ctrl) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              ctrl.signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 52),
      child: Divider(height: 0, thickness: 0.5, color: AppColors.cardBorder),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String icon, label;
  final bool value;
  final VoidCallback onToggle;
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Text(icon, style: const TextStyle(fontSize: 20)),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onToggle();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: value ? AppColors.primary : AppColors.cardBorder,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(2),
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String icon, label, value;
  final List<String> options;
  final ValueChanged<String> onSelect;
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Text(icon, style: const TextStyle(fontSize: 20)),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: GestureDetector(
        onTap: () => _showPicker(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...options.map(
            (o) => ListTile(
              title: Text(
                o,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  color: o == value ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: o == value ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: o == value
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: 18,
                    )
                  : null,
              onTap: () {
                onSelect(o);
                Get.back();
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StepperTile extends StatelessWidget {
  final String icon, label;
  final int value;
  final VoidCallback onDecrement, onIncrement;
  const _StepperTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Text(icon, style: const TextStyle(fontSize: 20)),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(icon: Icons.remove, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$value',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _StepBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Icon(icon, size: 14, color: AppColors.textPrimary),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String icon, label;
  final Widget? trailing;
  final VoidCallback onTap;
  const _LinkTile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Text(icon, style: const TextStyle(fontSize: 20)),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing:
          trailing ??
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: AppColors.textHint,
          ),
      onTap: onTap,
    );
  }
}
