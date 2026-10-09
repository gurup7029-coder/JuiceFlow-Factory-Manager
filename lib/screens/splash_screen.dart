import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_state_provider.dart';
import '../widgets/juice_flowing_3d_tumbler.dart';
import '../widgets/juiceflow_brand_header.dart';
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
                  child: JuiceflowBrandHeader(
                    logoSize: 135,
                    isTamil: appState.locale.languageCode == 'ta',
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
