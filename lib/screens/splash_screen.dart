import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_state_provider.dart';
import '../widgets/juiceflow_brand_header.dart';
import 'auth/login_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _floatController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _progressAnimation;

  Timer? _navigationTimer;
  bool _navigated = false;
  String _statusMessage = 'Starting Factory Engine...';

  final List<_FloatingFruitParticle> _particles = [
    _FloatingFruitParticle('🥭', 0.15, 0.75, 28, 1.2),
    _FloatingFruitParticle('🍊', 0.82, 0.70, 26, -0.9),
    _FloatingFruitParticle('🍎', 0.25, 0.35, 24, 0.8),
    _FloatingFruitParticle('🍍', 0.78, 0.30, 30, -1.1),
    _FloatingFruitParticle('🍋', 0.48, 0.85, 22, 0.6),
  ];

  @override
  void initState() {
    super.initState();

    // 1. Smooth entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _progressAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 1.0, curve: Curves.easeInOutCubic),
    );

    // 2. Gentle levitation / floating loop
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // 3. Subtle aura pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _entranceController.forward();

    // Staggered status updates
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _statusMessage = 'Calibrating Production Sensors...');
    });
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted) setState(() => _statusMessage = 'Connecting Plant Database...');
    });
    Future.delayed(const Duration(milliseconds: 1350), () {
      if (mounted) setState(() => _statusMessage = 'Factory Ready!');
    });

    // Auto-advance after 1.8 seconds (instant & responsive)
    _navigationTimer = Timer(const Duration(milliseconds: 1850), _navigateToNextScreen);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    if (_navigated || !mounted) return;
    _navigated = true;

    final appState = Provider.of<AppStateProvider>(context, listen: false);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) =>
            appState.isLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
        transitionsBuilder: (context, animation, secAnim, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = Provider.of<AppStateProvider>(context);
    final isTa = appState.locale.languageCode == 'ta';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF080E1A) : const Color(0xFFF6F8FB),
      body: GestureDetector(
        onTap: _navigateToNextScreen, // Quick tap to bypass instantly
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Ambient Orchard Depth Backdrop
            Opacity(
              opacity: isDark ? 0.22 : 0.14,
              child: Image.asset(
                'assets/images/orchard_canopy.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),

            // 2. High-Tech Radial Glow
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return Center(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.neonMango.withOpacity(0.18 + _pulseController.value * 0.08),
                          AppTheme.neonLime.withOpacity(0.08 + _pulseController.value * 0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // 3. Floating Ambient Fruit Particles
            ..._particles.map((p) => _buildFruitParticle(p)),

            // 4. Center 3D Brand Badge & Typography
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_entranceController, _floatController]),
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value + _floatAnimation.value),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            JuiceflowBrandHeader(
                              logoSize: 120,
                              isTamil: isTa,
                              showTagline: true,
                            ),
                            const SizedBox(height: 28),

                            // Liquid Progress Wave Bar
                            Container(
                              width: 200,
                              height: 6,
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 5. Bottom Loading Indicator & Status
            Positioned(
              bottom: 42,
              left: 24,
              right: 24,
              child: AnimatedBuilder(
                animation: _entranceController,
                builder: (context, _) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Progress Bar
                        Container(
                          width: 180,
                          height: 5,
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 180 * _progressAnimation.value,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.neonMango, AppTheme.neonLime],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.neonMango.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 6. Top Instant Skip Button
            Positioned(
              top: 48,
              right: 18,
              child: TextButton.icon(
                onPressed: _navigateToNextScreen,
                style: TextButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                icon: const Icon(Icons.fast_forward_rounded, size: 16),
                label: Text(
                  isTa ? 'தவிர்' : 'Skip',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFruitParticle(_FloatingFruitParticle p) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final yOffset = math.sin((_floatController.value + p.xRatio) * math.pi * 2) * 12 * p.speed;

        return Positioned(
          left: screenWidth * p.xRatio,
          top: (screenHeight * p.yRatio) + yOffset,
          child: OpvedParticle(
            emoji: p.emoji,
            size: p.size,
            fadeAnim: _fadeAnimation,
          ),
        );
      },
    );
  }
}

class _FloatingFruitParticle {
  final String emoji;
  final double xRatio;
  final double yRatio;
  final double size;
  final double speed;

  _FloatingFruitParticle(this.emoji, this.xRatio, this.yRatio, this.size, this.speed);
}

class OpvedParticle extends StatelessWidget {
  final String emoji;
  final double size;
  final Animation<double> fadeAnim;

  const OpvedParticle({
    super.key,
    required this.emoji,
    required this.size,
    required this.fadeAnim,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: Opacity(
        opacity: 0.75,
        child: Text(
          emoji,
          style: TextStyle(fontSize: size),
        ),
      ),
    );
  }
}
