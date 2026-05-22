import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/resep_data.dart'; // ← tambahan

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _taglineController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;

  // Animations
  late Animation<double> _bgScale;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _dotOpacity;
  late Animation<double> _shimmer;

  static const _brown = Color(0xFF4A2B20);
  static const _terracotta = Color(0xFFC6572F);
  static const _gold = Color(0xFFD9AE23);
  static const _darkBrown = Color(0xFF2C1A10);

  @override
  void initState() {
    super.initState();

    // Full-screen immersive
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Background slow zoom
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _bgScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );

    // Logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Tagline
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    // Shimmer on logo text
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Particle/dots loading
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dotOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    // Start sequence
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    _bgController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    await _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _taglineController.forward();
    _shimmerController.repeat();

    // ── Load database bersamaan dengan animasi berjalan ──────────────
    // Jalankan keduanya paralel: tunggu animasi (2400ms) DAN load DB
    // Mana yang lebih lama, itu yang ditunggu — user tidak nunggu blank
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2400)),
      loadResepFromDatabase(),
    ]);

    if (mounted) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _taglineController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBrown,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Animated Background ──────────────────────────────────────
          AnimatedBuilder(
            animation: _bgScale,
            builder: (_, child) => Transform.scale(
              scale: _bgScale.value,
              child: child,
            ),
            child: Image.network(
              'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: _brown),
            ),
          ),

          // ── Layered Gradient Overlay ─────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _darkBrown.withValues(alpha: 0.55),
                  _darkBrown.withValues(alpha: 0.80),
                  _darkBrown.withValues(alpha: 0.97),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Decorative Spice Pattern (top right) ────────────────────
          Positioned(
            top: -40,
            right: -40,
            child: Opacity(
              opacity: 0.08,
              child: Icon(
                Icons.spa_rounded,
                size: 220,
                color: _gold,
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -30,
            child: Opacity(
              opacity: 0.06,
              child: Icon(
                Icons.eco_rounded,
                size: 180,
                color: _gold,
              ),
            ),
          ),

          // ── Floating Particles ───────────────────────────────────────
          ..._buildParticles(),

          // ── Main Content ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo plate
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (_, child) => Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: child,
                    ),
                  ),
                  child: _buildLogoPlate(),
                ),

                const SizedBox(height: 28),

                // Tagline
                SlideTransition(
                  position: _taglineSlide,
                  child: FadeTransition(
                    opacity: _taglineOpacity,
                    child: Column(
                      children: [
                        // Decorative divider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _goldDot(),
                            Container(
                              width: 60,
                              height: 1,
                              color: _gold.withValues(alpha: 0.5),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            _goldDot(),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Rasa Warisan Budaya',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Jelajahi kekayaan kuliner Nusantara\ndari Sabang sampai Merauke',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 13,
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Loading dots
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: _buildLoadingDots(),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPlate() {
    return Column(
      children: [
        // Ornamental ring
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                Border.all(color: _gold.withValues(alpha: 0.35), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _terracotta.withValues(alpha: 0.25),
                    _brown.withValues(alpha: 0.10),
                  ],
                ),
                border: Border.all(
                    color: _gold.withValues(alpha: 0.6), width: 1.5),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: _gold,
                size: 46,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // KaryaRasa shimmer text
        AnimatedBuilder(
          animation: _shimmer,
          builder: (_, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [
                    Colors.white,
                    _gold,
                    Colors.white,
                  ],
                  stops: [
                    (_shimmer.value - 0.5).clamp(0.0, 1.0),
                    _shimmer.value.clamp(0.0, 1.0),
                    (_shimmer.value + 0.5).clamp(0.0, 1.0),
                  ],
                ).createShader(bounds);
              },
              child: child!,
            );
          },
          child: const Text(
            'KaryaRasa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _goldDot() {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: _gold,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final phase =
                ((_particleController.value * 3) - i).clamp(0.0, 1.0);
            final opacity =
                (math.sin(phase * math.pi)).abs().clamp(0.3, 1.0);
            return Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _terracotta.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  List<Widget> _buildParticles() {
    final rng = math.Random(42);
    return List.generate(12, (i) {
      final dx = rng.nextDouble();
      final dy = rng.nextDouble();
      final size = 3.0 + rng.nextDouble() * 4;
      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, _) {
          final t = (_particleController.value + i * 0.083) % 1.0;
          final opacity = (math.sin(t * math.pi)).abs() * 0.25;
          return Positioned(
            left: dx * MediaQuery.of(context).size.width,
            top: dy * MediaQuery.of(context).size.height,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: i.isEven ? _gold : _terracotta,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      );
    });
  }
}