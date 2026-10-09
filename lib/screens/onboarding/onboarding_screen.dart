import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Smart Juice Factory Management',
      'desc': 'Complete end-to-end control from fresh orchard fruits to warehouse distribution.',
      'icon': Icons.factory_outlined,
      'color': AppColors.primary,
    },
    {
      'title': 'Real-Time Batch Tracking & QR',
      'desc': 'Monitor blending, bottling, pH & Brix testing, and generate batch QR codes.',
      'icon': Icons.precision_manufacturing_outlined,
      'color': AppColors.secondary,
    },
    {
      'title': 'Traceable Raw Material Stock',
      'desc': 'Manage fruit pulp, sugar, PET bottles, and get proactive low-stock alerts.',
      'icon': Icons.inventory_2_outlined,
      'color': AppColors.accent,
    },
    {
      'title': 'Sales Orders & Invoicing',
      'desc': 'Take customer orders, track payments, and generate GST tax invoices in seconds.',
      'icon': Icons.point_of_sale_outlined,
      'color': AppColors.primaryLight,
    },
    {
      'title': 'Smart Factory Analytics',
      'desc': 'Visual reports on production efficiency, wastage percentages, and sales growth.',
      'icon': Icons.insights_outlined,
      'color': AppColors.primary,
    },
  ];

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, index) {
                  final p = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: (p['color'] as Color).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            p['icon'] as IconData,
                            size: 56,
                            color: p['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          p['title'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p['desc'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == i ? AppColors.primary : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      _finish();
                    }
                  },
                  child: Text(_currentIndex == _pages.length - 1 ? 'Get Started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
