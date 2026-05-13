import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/app_colour.dart';
import '../controllers/auth_cont.dart';

class OnboardingView extends GetView<AuthController> {
  const OnboardingView({super.key});

  static const _pages = [
    _OnboardData(
      emoji: '🥦',
      floaters: ['🍎', '🥕', '🧅', '🫑'],
      title: 'Never waste\ngrocery again',
      description:
          'Track everything in your kitchen. Know exactly what you have, where it is, and when it expires.',
      gradientColors: [Color(0xFF0A2318), Color(0xFF040E08)],
      glowColor: Color(0xFF1DB868),
    ),
    _OnboardData(
      emoji: '❄️',
      floaters: ['🍎', '🥛', '🧀', '🥦'],
      title: 'Smart storage\nguidance',
      description:
          'AI tells you exactly where each item belongs — fridge, pantry, countertop — to maximise shelf life.',
      gradientColors: [Color(0xFF0A1A2A), Color(0xFF040A10)],
      glowColor: Color(0xFF4A9EFF),
    ),
    _OnboardData(
      emoji: '🍛',
      floaters: ['🫘', '🧅', '🍅', '🌿'],
      title: 'Recipes from\nwhat you have',
      description:
          'AI suggests recipes from your leftover grocery — with calories, allergens, and cuisine preferences.',
      gradientColors: [Color(0xFF1A0D08), Color(0xFF0A0604)],
      glowColor: Color(0xFFF5A623),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: (i) => controller.currentOnboardPage.value = i,
              itemCount: _pages.length,
              itemBuilder: (_, i) => _OnboardPage(data: _pages[i]),
            ),
          ),

          Obx(
            () => _BottomCard(
              pages: _pages,
              currentIndex: controller.currentOnboardPage.value,
              pageController: controller.pageController,
              onNext: controller.nextOnboardPage,
              onSkip: controller.finishOnboarding,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final _OnboardData data;
  const _OnboardPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: data.gradientColors,
            ),
          ),
        ),

        Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [data.glowColor.withOpacity(0.18), Colors.transparent],
              ),
            ),
          ),
        ),

        ..._buildFloaters(context),

        Center(
          child: Text(data.emoji, style: const TextStyle(fontSize: 96))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
                begin: 0,
                end: -14,
                duration: 2200.ms,
                curve: Curves.easeInOut,
              ),
        ),
      ],
    );
  }

  List<Widget> _buildFloaters(BuildContext context) {
    final positions = [
      const Offset(0.12, 0.18),
      const Offset(0.80, 0.14),
      const Offset(0.10, 0.72),
      const Offset(0.78, 0.68),
    ];
    return List.generate(data.floaters.length, (i) {
      return LayoutBuilder(
        builder: (ctx, box) => Positioned(
          left: box.maxWidth * positions[i].dx,
          top: box.maxHeight * positions[i].dy,
          child: Opacity(
            opacity: 0.45,
            child: Text(data.floaters[i], style: const TextStyle(fontSize: 28))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: 0,
                  end: -10,
                  duration: Duration(milliseconds: 2000 + i * 400),
                  curve: Curves.easeInOut,
                ),
          ),
        ),
      );
    });
  }
}

class _BottomCard extends StatelessWidget {
  final List<_OnboardData> pages;
  final int currentIndex;
  final PageController pageController;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _BottomCard({
    required this.pages,
    required this.currentIndex,
    required this.pageController,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentIndex == pages.length - 1;
    final data = pages[currentIndex];

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 28,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SmoothPageIndicator(
              controller: pageController,
              count: pages.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: AppColors.primary,
                dotColor: AppColors.cardBorder,
                dotHeight: 4,
                dotWidth: 8,
                expansionFactor: 3,
                spacing: 6,
              ),
            ),
          ),

          const SizedBox(height: 20),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              data.title,
              key: ValueKey(currentIndex),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                height: 1.15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 10),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              data.description,
              key: ValueKey('desc_$currentIndex'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 28),

          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isLast ? 'Get Started' : 'Continue',
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 10),

          if (!isLast)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onSkip,
                child: Text(
                  'Skip intro',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardData {
  final String emoji;
  final List<String> floaters;
  final String title;
  final String description;
  final List<Color> gradientColors;
  final Color glowColor;

  const _OnboardData({
    required this.emoji,
    required this.floaters,
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.glowColor,
  });
}
