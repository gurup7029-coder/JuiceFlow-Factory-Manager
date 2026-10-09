import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class JuiceflowBrandHeader extends StatelessWidget {
  final double logoSize;
  final bool showTagline;
  final bool isTamil;
  final VoidCallback? onTap;

  const JuiceflowBrandHeader({
    super.key,
    this.logoSize = 110,
    this.showTagline = true,
    this.isTamil = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Luxury 3D Logo Emblem with Ambient Glow & Glass Bevel
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(logoSize * 0.28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFA000),
                  Color(0xFFFF5722),
                  Color(0xFFE91E63),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5722).withOpacity(0.42),
                  blurRadius: 28,
                  spreadRadius: 4,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFFFFA000).withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(3.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(logoSize * 0.26),
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(logoSize * 0.26),
                child: Image.asset(
                  'assets/images/logo_3d.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primary,
                    child: Icon(
                      Icons.local_drink_rounded,
                      size: logoSize * 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Ultra-Designful JUICEFLOW Stylized Typography
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'JUICE',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.18),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFFF7043),
                        Color(0xFFFFA000),
                        Color(0xFFFFD54F),
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'FLOW',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // 3. Futuristic Subtitle Pill Badge: FACTORY MANAGER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1E293B),
                        const Color(0xFF334155),
                      ]
                    : [
                        const Color(0xFFFFF3E0),
                        const Color(0xFFFFE0B2),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFF9800).withOpacity(0.55),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'FACTORY MANAGER OS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.2,
                    color: isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
                  ),
                ),
              ],
            ),
          ),

          // 4. Bilingual Tagline Badge
          if (showTagline) ...[
            const SizedBox(height: 10),
            Text(
              isTamil ? AppConstants.appTaglineTa : AppConstants.appTaglineEn,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
