import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_state_provider.dart';
import '../widgets/juice_flowing_3d_tumbler.dart';
import 'auth/login_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool _showLogoTransition = false;
  late AnimationController _logoAnimController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  Timer? _transitionTimer;

  @override
  void initState() {
    super.initState();
    _logoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = CurvedAnimation(
      parent: _logoAnimController,
      curve: Curves.easeOutBack,
    );
    _logoFade = CurvedAnimation(
      parent: _logoAnimController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    _logoAnimController.dispose();
    super.dispose();
  }

  void _onPourCompleted() {
    if (!mounted) return;
    setState(() {
      _showLogoTransition = true;
    });
    _logoAnimController.forward();

    _transitionTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      if (appState.isLoggedIn) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, anim, secAnim) => const MainNavigationScreen(),
            transitionsBuilder: (context, animation, secAnim, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, anim, secAnim) => const LoginScreen(),
            transitionsBuilder: (context, animation, secAnim, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. Interactive 3D Flowing & Tumbler Filling Animation
          if (!_showLogoTransition)
            JuiceFlowing3dTumbler(
              onComplete: _onPourCompleted,
              autoAdvance: true,
            ),

          // 2. Grand 3D Logo Reveal after tumbler fills up
          if (_showLogoTransition)
            Center(
              child: FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Modern 3D Logo Container with Glow
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.4),
                              blurRadius: 36,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(70),
                          child: Image.asset(
                            'assets/images/logo_3d.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, err, stack) => Container(
                              color: AppColors.primary,
                              child: const Icon(
                                Icons.local_drink_rounded,
                                size: 68,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SMART JUICE FACTORY OS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        appState.locale.languageCode == 'ta'
                            ? AppConstants.appTaglineTa
                            : AppConstants.appTaglineEn,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Top Skip Button
          Positioned(
            top: 48,
            right: 20,
            child: TextButton.icon(
              onPressed: _onPourCompleted,
              style: TextButton.styleFrom(
                backgroundColor: (isDark ? Colors.black45 : Colors.white60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.fast_forward_rounded, size: 16),
              label: Text(
                appState.locale.languageCode == 'ta' ? 'தவிர்' : 'Skip',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
