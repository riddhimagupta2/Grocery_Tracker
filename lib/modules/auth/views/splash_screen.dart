import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_size.dart';
import '../../../config/app_colour.dart';
import '../controllers/auth_cont.dart';

class SplashView extends GetView<AuthController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.checkInitialRoute(),
    );

    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            ..._buildParticles(screenW, screenH),

            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: screenH,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    const _Logo(),

                    SizedBox(height: screenH * 0.03),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Fresh',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: R.fs(34),
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'Track',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: R.fs(34),
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenH * 0.01),

                    Text(
                      'Smart Grocery Intelligence',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: R.fs(13),
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const Spacer(flex: 2),

                    const _LoadingDots(),

                    SizedBox(height: screenH * 0.02),

                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: R.fs(11),
                        color: AppColors.textHint,
                      ),
                    ),

                    SizedBox(height: screenH * 0.04),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles(double screenW, double screenH) {
    final positions = [
      [0.15, 0.20],
      [0.75, 0.15],
      [0.85, 0.55],
      [0.10, 0.70],
      [0.55, 0.80],
      [0.30, 0.40],
      [0.65, 0.88],
    ];
    return positions.asMap().entries.map((e) {
      return Positioned(
        left: screenW * e.value[0],
        top: screenH * e.value[1],
        child: _Particle(delay: Duration(milliseconds: e.key * 300)),
      );
    }).toList();
  }
}

class _Logo extends StatefulWidget {
  const _Logo();

  @override
  State<_Logo> createState() => _LogoState();
}

class _LogoState extends State<_Logo> with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _rotate;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _rotate = Tween<double>(
      begin: -0.12,
      end: 0.12,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeInOut));
    _pulse = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = R.w(100).clamp(80.0, 130.0);

    return SizedBox(
      width: s + 40,
      height: s + 40,
      child: AnimatedBuilder(
        animation: _ac,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _pulse.value,
              child: Container(
                width: s + 36,
                height: s + 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                    width: 1,
                  ),
                ),
              ),
            ),

            Transform.scale(
              scale: _pulse.value * 0.88,
              child: Container(
                width: s + 16,
                height: s + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.25),
                    width: 1,
                  ),
                ),
              ),
            ),

            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_rotate.value)
                ..rotateX(-_rotate.value * 0.5),
              child: Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(s * 0.27),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D3D20), Color(0xFF041A0C)],
                  ),
                  border: Border.all(
                    color: const Color(0xFF1A4A28),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 32,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.10),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: s * 0.04,
                      child: Container(
                        width: s * 0.09,
                        height: s,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.white.withOpacity(0.08),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    Center(
                      child: Text('🌿', style: TextStyle(fontSize: s * 0.40)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = (_ac.value - i * 0.15).clamp(0.0, 1.0);
          final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.2, 1.0);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(opacity),
            ),
          );
        }),
      ),
    );
  }
}

class _Particle extends StatefulWidget {
  final Duration delay;
  const _Particle({required this.delay});

  @override
  State<_Particle> createState() => _ParticleState();
}

class _ParticleState extends State<_Particle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
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
      builder: (_, __) => Transform.translate(
        offset: Offset(0, -12 * _anim.value),
        child: Opacity(
          opacity: 0.15 + 0.3 * _anim.value,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
