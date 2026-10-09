import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class JuiceFlowing3dTumbler extends StatefulWidget {
  final VoidCallback? onComplete;
  final bool autoAdvance;

  const JuiceFlowing3dTumbler({
    super.key,
    this.onComplete,
    this.autoAdvance = true,
  });

  @override
  State<JuiceFlowing3dTumbler> createState() => _JuiceFlowing3dTumblerState();
}

class _JuiceFlowing3dTumblerState extends State<JuiceFlowing3dTumbler>
    with TickerProviderStateMixin {
  late AnimationController _flowController;
  late AnimationController _fillController;
  late AnimationController _introController;
  late Animation<double> _fillAnimation;
  Timer? _advanceTimer;

  double _rotX = -0.05;
  double _rotY = 0.05;

  final List<_JuiceBubble> _bubbles = [];
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();

    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _fillAnimation = CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeInOutCubic,
    );

    _fillController.forward().then((_) {
      if (widget.autoAdvance && mounted) {
        _advanceTimer = Timer(const Duration(milliseconds: 800), () {
          if (mounted && widget.onComplete != null) {
            widget.onComplete!();
          }
        });
      }
    });

    // Generate bubbles
    for (int i = 0; i < 28; i++) {
      _bubbles.add(_JuiceBubble(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        radius: 2 + _rng.nextDouble() * 3.5,
        speed: 0.3 + _rng.nextDouble() * 0.7,
      ));
    }
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _flowController.dispose();
    _fillController.dispose();
    _introController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _rotY += details.delta.dx * 0.005;
      _rotX -= details.delta.dy * 0.005;
      _rotX = _rotX.clamp(-0.35, 0.35);
      _rotY = _rotY.clamp(-0.45, 0.45);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onTap: () {
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ambient radial glow
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.1),
                radius: 1.1,
                colors: isDark
                    ? [
                        AppColors.secondary.withOpacity(0.18),
                        AppColors.primary.withOpacity(0.10),
                        Colors.transparent,
                      ]
                    : [
                        AppColors.secondary.withOpacity(0.25),
                        AppColors.accent.withOpacity(0.15),
                        Colors.transparent,
                      ],
              ),
            ),
          ),

          // Main 3D Canvas
          AnimatedBuilder(
            animation: Listenable.merge([_flowController, _fillAnimation, _introController]),
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateX(_rotX)
                  ..rotateY(_rotY),
                alignment: Alignment.center,
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: CustomPaint(
                    painter: _JuiceStreamAndTumblerPainter(
                      flowPhase: _flowController.value * 2 * math.pi,
                      fillPercent: _fillAnimation.value,
                      introProgress: _introController.value,
                      bubbles: _bubbles,
                      isDark: isDark,
                    ),
                  ),
                ),
              );
            },
          ),

          // Floating Top Fruit Source Header
          Positioned(
            top: 75,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black54 : Colors.white).withOpacity(0.75),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.2),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.eco_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '100% PURE COLD-PRESSED FLOW',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'JuiceFlow 3D Experience',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Live Metrics Overlay Card (Bottom Center)
          Positioned(
            bottom: 45,
            child: AnimatedBuilder(
              animation: _fillAnimation,
              builder: (context, _) {
                final currentMl = (_fillAnimation.value * 350).round();
                final currentBrix = (12.0 + _fillAnimation.value * 2.8).toStringAsFixed(1);
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF1E293B) : Colors.white)
                            .withOpacity(0.92),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _metricPill(
                            icon: Icons.local_drink_rounded,
                            label: 'Volume',
                            value: '$currentMl ml',
                            color: AppColors.secondary,
                          ),
                          Container(
                            height: 28,
                            width: 1,
                            color: Colors.grey.withOpacity(0.3),
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          _metricPill(
                            icon: Icons.science_rounded,
                            label: 'Refractometer',
                            value: '$currentBrix °Bx',
                            color: AppColors.accent,
                          ),
                          Container(
                            height: 28,
                            width: 1,
                            color: Colors.grey.withOpacity(0.3),
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          _metricPill(
                            icon: Icons.ac_unit_rounded,
                            label: 'Chilled',
                            value: '3.8°C',
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Drag in any direction to rotate 3D perspective • Tap to enter',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ],
    );
  }
}

class _JuiceBubble {
  double x;
  double y;
  final double radius;
  final double speed;

  _JuiceBubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
  });
}

class _JuiceStreamAndTumblerPainter extends CustomPainter {
  final double flowPhase;
  final double fillPercent;
  final double introProgress;
  final List<_JuiceBubble> bubbles;
  final bool isDark;

  _JuiceStreamAndTumblerPainter({
    required this.flowPhase,
    required this.fillPercent,
    required this.introProgress,
    required this.bubbles,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final fruitY = size.height * 0.22;
    final tumblerTopY = size.height * 0.44;
    final tumblerBottomY = size.height * 0.74;
    final tumblerTopRadiusX = 72.0;
    final tumblerBottomRadiusX = 52.0;
    final tumblerHeight = tumblerBottomY - tumblerTopY;

    // 1. Draw Fruit Source at the Top
    _draw3dFruitSource(canvas, centerX, fruitY);

    // 2. Draw 3D Glass Tumbler Back Wall
    _drawTumblerBack(
      canvas,
      centerX,
      tumblerTopY,
      tumblerBottomY,
      tumblerTopRadiusX,
      tumblerBottomRadiusX,
    );

    // 3. Draw Liquid Fill Inside Tumbler
    if (fillPercent > 0.01) {
      _drawLiquidFill(
        canvas,
        centerX,
        tumblerTopY,
        tumblerBottomY,
        tumblerTopRadiusX,
        tumblerBottomRadiusX,
        tumblerHeight,
      );
    }

    // 4. Draw Flowing Juice Stream Cascading Downwards
    _drawFlowingJuiceStream(canvas, centerX, fruitY, tumblerTopY, tumblerBottomY, tumblerHeight);

    // 5. Draw 3D Glass Tumbler Front Wall, Rim and Refraction Highlights
    _drawTumblerFrontAndHighlights(
      canvas,
      centerX,
      tumblerTopY,
      tumblerBottomY,
      tumblerTopRadiusX,
      tumblerBottomRadiusX,
    );
  }

  void _draw3dFruitSource(Canvas canvas, double cx, double cy) {
    final paint = Paint()..isAntiAlias = true;

    // Glowing aura behind fruits
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF9800).withOpacity(0.45 * introProgress),
          const Color(0xFFFFD54F).withOpacity(0.2 * introProgress),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 65));
    canvas.drawCircle(Offset(cx, cy), 65, auraPaint);

    // Left Mango Half (Golden Mango)
    final mangoPath = Path()
      ..moveTo(cx - 50, cy - 15)
      ..cubicTo(cx - 65, cy - 35, cx - 25, cy - 45, cx - 10, cy - 35)
      ..cubicTo(cx + 10, cy - 25, cx - 10, cy + 15, cx - 35, cy + 10)
      ..close();

    paint.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFB300), Color(0xFFFF8F00), Color(0xFFE65100)],
    ).createShader(Rect.fromLTWH(cx - 65, cy - 45, 60, 60));
    canvas.drawPath(mangoPath, paint);

    // Right Citrus Orange Slice (Vibrant Orange)
    paint.shader = const RadialGradient(
      colors: [Color(0xFFFFF176), Color(0xFFFF9800), Color(0xFFF57C00)],
    ).createShader(Rect.fromCircle(center: Offset(cx + 32, cy - 18), radius: 32));
    canvas.drawCircle(Offset(cx + 32, cy - 18), 30, paint);

    // Orange segments
    final segmentPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    for (int i = 0; i < 8; i++) {
      final angle = i * (math.pi / 4);
      canvas.drawLine(
        Offset(cx + 32, cy - 18),
        Offset(cx + 32 + math.cos(angle) * 26, cy - 18 + math.sin(angle) * 26),
        segmentPaint,
      );
    }

    // Fresh Green Mint Leaf at Top Right
    final leafPath = Path()
      ..moveTo(cx + 12, cy - 44)
      ..quadraticBezierTo(cx + 28, cy - 65, cx + 50, cy - 50)
      ..quadraticBezierTo(cx + 40, cy - 36, cx + 12, cy - 44);
    paint.shader = const LinearGradient(
      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
    ).createShader(Rect.fromLTWH(cx + 12, cy - 65, 40, 30));
    canvas.drawPath(leafPath, paint);
  }

  void _drawTumblerBack(
    Canvas canvas,
    double cx,
    double topY,
    double bottomY,
    double topR,
    double bottomR,
  ) {
    // Glass back outline
    final path = Path()
      ..moveTo(cx - topR, topY)
      ..lineTo(cx - bottomR, bottomY)
      ..quadraticBezierTo(cx, bottomY + 14, cx + bottomR, bottomY)
      ..lineTo(cx + topR, topY)
      ..quadraticBezierTo(cx, topY - 12, cx - topR, topY);

    final glassPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.blueGrey).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, glassPaint);
  }

  void _drawLiquidFill(
    Canvas canvas,
    double cx,
    double topY,
    double bottomY,
    double topR,
    double bottomR,
    double totalH,
  ) {
    final currentH = totalH * fillPercent;
    final surfaceY = bottomY - currentH;

    // Radius at current surface height
    final surfaceR = bottomR + (topR - bottomR) * fillPercent;

    final liquidPath = Path();
    liquidPath.moveTo(cx - surfaceR, surfaceY);

    // Dynamic wave surface
    const waveCount = 20;
    final waveWidth = (surfaceR * 2) / waveCount;
    for (int i = 0; i <= waveCount; i++) {
      final x = (cx - surfaceR) + i * waveWidth;
      final waveOffset = math.sin(flowPhase + i * 0.7) * 4.5;
      liquidPath.lineTo(x, surfaceY + waveOffset);
    }

    // Walls down to base
    liquidPath.lineTo(cx + bottomR, bottomY);
    liquidPath.quadraticBezierTo(cx, bottomY + 12, cx - bottomR, bottomY);
    liquidPath.close();

    // Vibrant Juice Liquid Gradient
    final liquidPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFD54F), // Golden froth top
          Color(0xFFFFA000), // Rich Mango Citrus
          Color(0xFFFB8C00), // Vibrant Tangerine
          Color(0xFFE65100), // Deep pure fruit body
        ],
        stops: [0.0, 0.25, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(cx - topR, surfaceY - 5, topR * 2, currentH + 15));

    canvas.drawPath(liquidPath, liquidPaint);

    // Effervescent Rising Bubbles inside liquid
    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.fill;

    for (final b in bubbles) {
      final bx = (cx - surfaceR * 0.85) + b.x * (surfaceR * 1.7);
      // animate upward
      final animatedY = (b.y - (flowPhase / (2 * math.pi)) * b.speed) % 1.0;
      final by = bottomY - (animatedY * currentH);

      if (by >= surfaceY && by <= bottomY) {
        canvas.drawCircle(Offset(bx, by), b.radius, bubblePaint);
      }
    }
  }

  void _drawFlowingJuiceStream(
    Canvas canvas,
    double cx,
    double fruitY,
    double tumblerTopY,
    double tumblerBottomY,
    double totalH,
  ) {
    final streamStart = Offset(cx, fruitY + 12);
    final currentH = totalH * fillPercent;
    final targetY = fillPercent > 0.05 ? (tumblerBottomY - currentH) : (tumblerTopY + 30);

    // Dynamic waving control points
    final cp1 = Offset(cx - 28 + math.sin(flowPhase) * 12, fruitY + 60);
    final cp2 = Offset(cx + 24 + math.cos(flowPhase * 1.3) * 14, tumblerTopY - 10);
    final streamEnd = Offset(cx, targetY);

    // Thick juice stream path
    final streamPath = Path()..moveTo(streamStart.dx - 12, streamStart.dy);
    streamPath.cubicTo(
      cp1.dx - 10,
      cp1.dy,
      cp2.dx - 8,
      cp2.dy,
      streamEnd.dx - 6,
      streamEnd.dy,
    );
    streamPath.lineTo(streamEnd.dx + 6, streamEnd.dy);
    streamPath.cubicTo(
      cp2.dx + 8,
      cp2.dy,
      cp1.dx + 10,
      cp1.dy,
      streamStart.dx + 12,
      streamStart.dy,
    );
    streamPath.close();

    final streamPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFCA28),
          Color(0xFFFFA000),
          Color(0xFFF57C00),
          Color(0xFFFFD54F),
        ],
      ).createShader(Rect.fromLTWH(cx - 30, fruitY, 60, targetY - fruitY));

    canvas.drawPath(streamPath, streamPaint);

    // Inner glossy stream highlight
    final highlightPath = Path()..moveTo(streamStart.dx - 2, streamStart.dy + 10);
    highlightPath.cubicTo(
      cp1.dx - 2,
      cp1.dy,
      cp2.dx - 1,
      cp2.dy,
      streamEnd.dx - 2,
      streamEnd.dy,
    );

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(highlightPath, highlightPaint);

    // Splash impact rings and flying droplets at contact point
    final splashPaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(0.85)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final splashAngle = (i * (math.pi / 3)) + (flowPhase * 2);
      final splashDist = 12 + math.sin(flowPhase * 3 + i) * 8;
      final splashX = streamEnd.dx + math.cos(splashAngle) * splashDist;
      final splashY = streamEnd.dy + math.sin(splashAngle) * (splashDist * 0.4) - 4;
      canvas.drawCircle(Offset(splashX, splashY), 2.8, splashPaint);
    }
  }

  void _drawTumblerFrontAndHighlights(
    Canvas canvas,
    double cx,
    double topY,
    double bottomY,
    double topR,
    double bottomR,
  ) {
    // 3D Glass Rim (Top Oval Ellipse)
    final rimRect = Rect.fromCenter(
      center: Offset(cx, topY),
      width: topR * 2,
      height: 18,
    );

    final rimPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawOval(rimRect, rimPaint);

    // Side Glass Edges
    final edgePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Left Edge
    canvas.drawLine(Offset(cx - topR, topY), Offset(cx - bottomR, bottomY), edgePaint);
    // Right Edge
    canvas.drawLine(Offset(cx + topR, topY), Offset(cx + bottomR, bottomY), edgePaint);

    // Glass Base (Thick heavy crystal base)
    final baseRect = Rect.fromCenter(
      center: Offset(cx, bottomY + 3),
      width: bottomR * 2,
      height: 14,
    );
    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawOval(baseRect, basePaint);

    // Vertical Curved Specular Light Reflection (gives 3D glass curved shine)
    final shinePath = Path()
      ..moveTo(cx - topR + 14, topY + 8)
      ..quadraticBezierTo(
        cx - (topR + bottomR) / 2 + 12,
        (topY + bottomY) / 2,
        cx - bottomR + 10,
        bottomY - 8,
      );

    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(shinePath, shinePaint);
  }

  @override
  bool shouldRepaint(covariant _JuiceStreamAndTumblerPainter oldDelegate) => true;
}
