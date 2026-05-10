import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/app_theme.dart';
import '../controllers/auth_cont.dart';

class SplashView extends GetView<AuthController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.checkInitialRoute();
    });

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _GlowBackground(),

          ..._buildParticles(),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Logo3D(),

              const SizedBox(height: 20),

              Text(
                    'FreshTrack',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 8),

              Text(
                'Smart Grocery Intelligence',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.4,
                ),
              ).animate().fadeIn(delay: 900.ms, duration: 500.ms),

              const SizedBox(height: 56),

              _LoaderDots().animate().fadeIn(delay: 1200.ms, duration: 400.ms),
            ],
          ),

          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Text(
              'v1.0.0',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textHint),
            ).animate().fadeIn(delay: 1400.ms),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles() {
    const particles = [
      _ParticleData(left: 0.12, top: 0.18, size: 5, delay: 0),
      _ParticleData(left: 0.78, top: 0.12, size: 4, delay: 300),
      _ParticleData(left: 0.88, top: 0.55, size: 6, delay: 600),
      _ParticleData(left: 0.08, top: 0.68, size: 3, delay: 200),
      _ParticleData(left: 0.55, top: 0.82, size: 4, delay: 900),
      _ParticleData(left: 0.32, top: 0.38, size: 3, delay: 100),
      _ParticleData(left: 0.65, top: 0.25, size: 5, delay: 700),
    ];
    return particles.map((p) => _Particle(data: p)).toList();
  }
}

class _GlowBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [Color(0xFF0D2B1A), Color(0xFF050C07), Color(0xFF030805)],
        ),
      ),
    );
  }
}

class _Logo3D extends StatefulWidget {
  @override
  State<_Logo3D> createState() => _Logo3DState();
}

class _Logo3DState extends State<_Logo3D> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotate;
  late Animation<double> _tilt;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _rotate = Tween<double>(
      begin: -0.18,
      end: 0.18,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _tilt = Tween<double>(
      begin: 0.1,
      end: -0.06,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_rotate.value)
              ..rotateX(_tilt.value),
            child: child,
          ),
          child: _buildLogoBox(),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 700.ms)
        .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1));
  }

  Widget _buildLogoBox() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(44),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.12),
                  width: 1,
                ),
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 0.95, end: 1.05, duration: 2000.ms)
            .fadeIn(delay: 1000.ms),

        Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(38),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.22),
                  width: 1,
                ),
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 1.0, end: 1.04, duration: 2400.ms),

        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D3D20), Color(0xFF041A0C)],
            ),
            border: Border.all(color: const Color(0xFF1A4A28), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 32,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppColors.primary.withOpacity(0.12),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Center(
            child: Text('🌿', style: TextStyle(fontSize: 44)),
          ),
        ),

        Positioned(
          top: 18,
          left: 28,
          child: Container(
            width: 10,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoaderDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            )
            .animate(onPlay: (c) => c.repeat())
            .fadeOut(
              delay: Duration(milliseconds: i * 200),
              duration: 600.ms,
            )
            .then()
            .fadeIn(duration: 600.ms)
            .scaleXY(begin: 0.7, end: 1.2, duration: 600.ms);
      }),
    );
  }
}

class _ParticleData {
  final double left, top, size;
  final int delay;
  const _ParticleData({
    required this.left,
    required this.top,
    required this.size,
    required this.delay,
  });
}

class _Particle extends StatelessWidget {
  final _ParticleData data;
  const _Particle({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Positioned(
        left: constraints.maxWidth * data.left,
        top: constraints.maxHeight * data.top,
        child:
            Container(
                  width: data.size,
                  height: data.size,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn(
                  delay: Duration(milliseconds: data.delay),
                  duration: 800.ms,
                )
                .moveY(begin: 0, end: -16, duration: 2000.ms)
                .then()
                .moveY(begin: -16, end: 0, duration: 2000.ms),
      ),
    );
  }
}
