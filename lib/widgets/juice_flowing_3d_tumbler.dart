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
  late AnimationController _treeSwayController;
  late AnimationController _fruitDropController;
  late AnimationController _flowController;
  late AnimationController _fillController;
  late AnimationController _introController;
  late Animation<double> _fillAnimation;
  Timer? _advanceTimer;

  double _rotX = -0.04;
  double _rotY = 0.04;

  final List<_FallingFruit> _fruits = [];
  final List<_JuiceBubble> _bubbles = [];
  final List<_JuiceSplashParticle> _splashParticles = [];
  final List<_FloatingLeaf> _leaves = [];
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();

    // 1. Tree branches sway
    _treeSwayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    // 2. Fruit drop & physics controller
    _fruitDropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..forward();

    // 3. Juice flow stream continuous animation
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // 4. Intro fade/scale
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    // 5. Tumbler fill level (0% -> 100%)
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    _fillAnimation = CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeInOutCubic,
    );

    // Start filling slightly after first fruit drops
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _fillController.forward().then((_) {
          if (widget.autoAdvance && mounted) {
            _advanceTimer = Timer(const Duration(milliseconds: 900), () {
              if (mounted && widget.onComplete != null) {
                widget.onComplete!();
              }
            });
          }
        });
      }
    });

    _initFallingFruits();
    _initBubblesAndParticles();
  }

  void _initFallingFruits() {
    // 6 distinct realistic fruits that detach and drop from the tree
    _fruits.add(_FallingFruit(
      name: 'Mango',
      type: FruitType.mango,
      startXRatio: 0.32,
      startDelay: 0.05,
      size: 42,
      rotationSpeed: 3.2,
      color: const Color(0xFFFFB300),
    ));

    _fruits.add(_FallingFruit(
      name: 'Orange',
      type: FruitType.orange,
      startXRatio: 0.68,
      startDelay: 0.18,
      size: 38,
      rotationSpeed: -4.0,
      color: const Color(0xFFFF9800),
    ));

    _fruits.add(_FallingFruit(
      name: 'Apple',
      type: FruitType.apple,
      startXRatio: 0.48,
      startDelay: 0.32,
      size: 36,
      rotationSpeed: 2.5,
      color: const Color(0xFFE53935),
    ));

    _fruits.add(_FallingFruit(
      name: 'Strawberry',
      type: FruitType.strawberry,
      startXRatio: 0.22,
      startDelay: 0.44,
      size: 28,
      rotationSpeed: -3.5,
      color: const Color(0xFFD81B60),
    ));

    _fruits.add(_FallingFruit(
      name: 'Blueberry',
      type: FruitType.blueberry,
      startXRatio: 0.78,
      startDelay: 0.52,
      size: 22,
      rotationSpeed: 5.0,
      color: const Color(0xFF3949AB),
    ));

    _fruits.add(_FallingFruit(
      name: 'Orange2',
      type: FruitType.orange,
      startXRatio: 0.55,
      startDelay: 0.60,
      size: 34,
      rotationSpeed: -2.8,
      color: const Color(0xFFFB8C00),
    ));

    // Ambient floating tree leaves
    for (int i = 0; i < 12; i++) {
      _leaves.add(_FloatingLeaf(
        x: _rng.nextDouble(),
        y: _rng.nextDouble() * 0.4,
        size: 14 + _rng.nextDouble() * 12,
        speed: 0.3 + _rng.nextDouble() * 0.7,
        rotation: _rng.nextDouble() * math.pi * 2,
      ));
    }
  }

  void _initBubblesAndParticles() {
    for (int i = 0; i < 35; i++) {
      _bubbles.add(_JuiceBubble(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        radius: 1.8 + _rng.nextDouble() * 3.8,
        speed: 0.3 + _rng.nextDouble() * 0.8,
      ));
    }

    for (int i = 0; i < 24; i++) {
      _splashParticles.add(_JuiceSplashParticle(
        angle: _rng.nextDouble() * math.pi * 2,
        distance: 10 + _rng.nextDouble() * 32,
        radius: 1.5 + _rng.nextDouble() * 3.0,
        color: _rng.nextBool() ? const Color(0xFFFFA000) : const Color(0xFFFF5722),
      ));
    }
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _treeSwayController.dispose();
    _fruitDropController.dispose();
    _flowController.dispose();
    _fillController.dispose();
    _introController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _rotY += details.delta.dx * 0.005;
      _rotX -= details.delta.dy * 0.005;
      _rotX = _rotX.clamp(-0.25, 0.25);
      _rotY = _rotY.clamp(-0.35, 0.35);
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
          // 1. Realistic Orchard Backdrop (Canopy with Sunbeams)
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.28 : 0.40,
              child: Image.asset(
                'assets/images/orchard_canopy.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

          // 2. Ambient Gradient Vignette
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.1),
                radius: 1.2,
                colors: isDark
                    ? [
                        Colors.transparent,
                        const Color(0xFF0F172A).withOpacity(0.65),
                        const Color(0xFF020617).withOpacity(0.92),
                      ]
                    : [
                        Colors.transparent,
                        Colors.white.withOpacity(0.40),
                        const Color(0xFFF8FAFC).withOpacity(0.85),
                      ],
              ),
            ),
          ),

          // 3. Main Realistic 3D Canvas (Tree Canopy -> Falling Fruits -> Juicing Vortex -> Crystal Tumbler)
          AnimatedBuilder(
            animation: Listenable.merge([
              _treeSwayController,
              _fruitDropController,
              _flowController,
              _fillAnimation,
              _introController,
            ]),
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0014)
                  ..rotateX(_rotX)
                  ..rotateY(_rotY),
                alignment: Alignment.center,
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: CustomPaint(
                    painter: _RealisticFruitToJuiceTumblerPainter(
                      treeSway: _treeSwayController.value,
                      dropProgress: _fruitDropController.value,
                      flowPhase: _flowController.value * 2 * math.pi,
                      fillPercent: _fillAnimation.value,
                      introProgress: _introController.value,
                      fruits: _fruits,
                      leaves: _leaves,
                      bubbles: _bubbles,
                      splashParticles: _splashParticles,
                      isDark: isDark,
                    ),
                  ),
                ),
              );
            },
          ),

          // 4. Top Real-time Storyline Header Badge
          Positioned(
            top: 55,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(0.88),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFF9800).withOpacity(0.5),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9800).withOpacity(0.25),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.park_rounded, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'TREE-TO-TUMBLER COLD PRESSING',
                        style: TextStyle(
                          fontSize: 10.5,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedBuilder(
                  animation: _fillAnimation,
                  builder: (_, __) {
                    String phase = '1. Ripe Orchard Fruits Dropping...';
                    if (_fillAnimation.value > 0.15 && _fillAnimation.value < 0.65) {
                      phase = '2. Fresh Extraction & Vortex Juicing...';
                    } else if (_fillAnimation.value >= 0.65) {
                      phase = '3. Pure Nectar Filling Crystal Tumbler...';
                    }
                    return Text(
                      phase,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: const Color(0xFFFF9800),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 5. Live Production Metrics Overlay (Bottom Center)
          Positioned(
            bottom: 40,
            child: AnimatedBuilder(
              animation: _fillAnimation,
              builder: (context, _) {
                final currentMl = (_fillAnimation.value * 350).round();
                final currentBrix = (12.2 + _fillAnimation.value * 2.6).toStringAsFixed(1);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(0.92),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
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
                        color: const Color(0xFFFF9800),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      _metricPill(
                        icon: Icons.speed_rounded,
                        label: 'Brix Sweetness',
                        value: '$currentBrix° Bx',
                        color: const Color(0xFF4CAF50),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      _metricPill(
                        icon: Icons.water_drop_rounded,
                        label: 'Purity',
                        value: '100% Pure',
                        color: const Color(0xFF0288D1),
                      ),
                    ],
                  ),
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
              style: const TextStyle(fontSize: 8.5, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ],
    );
  }
}

enum FruitType { mango, orange, apple, strawberry, blueberry }

class _FallingFruit {
  final String name;
  final FruitType type;
  final double startXRatio;
  final double startDelay;
  final double size;
  final double rotationSpeed;
  final Color color;

  _FallingFruit({
    required this.name,
    required this.type,
    required this.startXRatio,
    required this.startDelay,
    required this.size,
    required this.rotationSpeed,
    required this.color,
  });
}

class _FloatingLeaf {
  double x;
  double y;
  final double size;
  final double speed;
  double rotation;

  _FloatingLeaf({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
  });
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

class _JuiceSplashParticle {
  final double angle;
  final double distance;
  final double radius;
  final Color color;

  _JuiceSplashParticle({
    required this.angle,
    required this.distance,
    required this.radius,
    required this.color,
  });
}

class _RealisticFruitToJuiceTumblerPainter extends CustomPainter {
  final double treeSway;
  final double dropProgress;
  final double flowPhase;
  final double fillPercent;
  final double introProgress;
  final List<_FallingFruit> fruits;
  final List<_FloatingLeaf> leaves;
  final List<_JuiceBubble> bubbles;
  final List<_JuiceSplashParticle> splashParticles;
  final bool isDark;

  _RealisticFruitToJuiceTumblerPainter({
    required this.treeSway,
    required this.dropProgress,
    required this.flowPhase,
    required this.fillPercent,
    required this.introProgress,
    required this.fruits,
    required this.leaves,
    required this.bubbles,
    required this.splashParticles,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final treeBranchY = size.height * 0.12;
    final juicingZoneY = size.height * 0.35;
    final tumblerTopY = size.height * 0.48;
    final tumblerBottomY = size.height * 0.77;
    final tumblerTopRadiusX = 76.0;
    final tumblerBottomRadiusX = 54.0;
    final tumblerHeight = tumblerBottomY - tumblerTopY;

    // 1. Draw Lush Orchard Tree Canopy & Branches at the Top
    _drawTreeCanopyAndBranches(canvas, size, treeBranchY);

    // 2. Draw Falling Fruits with physics & rotation dropping down to juicing zone
    _drawFallingFruitsAndLeaves(canvas, size, treeBranchY, juicingZoneY);

    // 3. Draw Juicing Extraction Zone (Vortex & Splash Burst)
    _drawJuicingExtractionZone(canvas, centerX, juicingZoneY);

    // 4. Draw Crystal Tumbler Back Wall
    _drawTumblerBack(
      canvas,
      centerX,
      tumblerTopY,
      tumblerBottomY,
      tumblerTopRadiusX,
      tumblerBottomRadiusX,
    );

    // 5. Draw Liquid Fill Inside Tumbler
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

    // 6. Draw Cascading Juice Stream Flowing from Extraction Zone to Tumbler
    _drawFlowingJuiceStream(canvas, centerX, juicingZoneY, tumblerTopY, tumblerBottomY, tumblerHeight);

    // 7. Draw Tumbler Front Glass Wall, Refraction Highlights, and Ice Cubes
    _drawTumblerFrontAndHighlights(
      canvas,
      centerX,
      tumblerTopY,
      tumblerBottomY,
      tumblerTopRadiusX,
      tumblerBottomRadiusX,
    );
  }

  void _drawTreeCanopyAndBranches(Canvas canvas, Size size, double branchY) {
    final swayOffset = math.sin(treeSway * math.pi) * 8.0;

    // Main organic woody branch
    final branchPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final branchPath = Path()
      ..moveTo(-20, branchY - 20)
      ..cubicTo(
        size.width * 0.25,
        branchY + swayOffset,
        size.width * 0.65,
        branchY - 15 - swayOffset,
        size.width + 20,
        branchY + 10,
      );
    canvas.drawPath(branchPath, branchPaint);

    // Smaller branch twigs
    final twigPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.32, branchY + swayOffset * 0.5),
      Offset(size.width * 0.32 + swayOffset * 0.8, branchY + 35),
      twigPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.68, branchY - 10),
      Offset(size.width * 0.68 + swayOffset, branchY + 30),
      twigPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.48, branchY - 5),
      Offset(size.width * 0.48, branchY + 28),
      twigPaint,
    );

    // Lush Emerald Leaves Foliage on Branches
    final leafPaint = Paint()..style = PaintingStyle.fill;
    final leafColors = [
      const Color(0xFF2E7D32),
      const Color(0xFF388E3C),
      const Color(0xFF43A047),
      const Color(0xFF66BB6A),
    ];

    for (int i = 0; i < 16; i++) {
      final x = (size.width * (i / 15)) + math.sin(i * 1.5 + treeSway) * 6;
      final y = branchY + (math.cos(i * 2.2) * 18);
      leafPaint.color = leafColors[i % leafColors.length];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((i * 0.4) + (swayOffset * 0.05));
      canvas.drawOval(const Rect.fromLTWH(-12, -7, 24, 14), leafPaint);
      canvas.restore();
    }
  }

  void _drawFallingFruitsAndLeaves(
    Canvas canvas,
    Size size,
    double branchY,
    double juicingZoneY,
  ) {
    // 1. Draw floating ambient leaves drifting
    final leafPaint = Paint()..color = const Color(0xFF4CAF50).withOpacity(0.75);
    for (final leaf in leaves) {
      final lx = (leaf.x * size.width);
      final ly = branchY + ((leaf.y + dropProgress * leaf.speed) % 0.85) * (juicingZoneY - branchY);
      canvas.save();
      canvas.translate(lx, ly);
      canvas.rotate(leaf.rotation + dropProgress * 2);
      canvas.drawOval(Rect.fromLTWH(-leaf.size / 2, -leaf.size / 4, leaf.size, leaf.size / 2), leafPaint);
      canvas.restore();
    }

    // 2. Draw Falling Fruits
    for (final fruit in fruits) {
      final localT = ((dropProgress - fruit.startDelay) / (1.0 - fruit.startDelay)).clamp(0.0, 1.0);

      // Fruit positions: from branch twig downwards into juicing center (centerX)
      final startX = size.width * fruit.startXRatio;
      final startY = branchY + 30;

      // Accelerated gravity drop
      final gravityT = math.pow(localT, 1.8).toDouble();
      final currentX = startX + (size.width / 2 - startX) * gravityT;
      final currentY = startY + (juicingZoneY - startY) * gravityT;

      // When fruit reaches extraction point (localT > 0.85), it squashes & bursts into juice
      if (localT < 0.95) {
        final scale = localT > 0.8 ? (1.0 - (localT - 0.8) / 0.15) : 1.0;
        final rotation = localT * fruit.rotationSpeed * math.pi;

        canvas.save();
        canvas.translate(currentX, currentY);
        canvas.rotate(rotation);
        canvas.scale(scale);

        _drawSpecificFruit(canvas, fruit);

        canvas.restore();
      }
    }
  }

  void _drawSpecificFruit(Canvas canvas, _FallingFruit fruit) {
    final paint = Paint()..isAntiAlias = true;
    final r = fruit.size / 2;

    switch (fruit.type) {
      case FruitType.mango:
        // Golden Alphonso Mango with leaf
        paint.shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD54F), Color(0xFFFFB300), Color(0xFFFF8F00), Color(0xFFE65100)],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));

        final mangoPath = Path()
          ..moveTo(0, -r)
          ..cubicTo(r * 1.3, -r * 0.7, r * 1.1, r * 0.8, 0, r * 1.1)
          ..cubicTo(-r * 1.2, r * 0.8, -r * 0.8, -r * 0.6, 0, -r)
          ..close();
        canvas.drawPath(mangoPath, paint);

        // Little green stem leaf
        final leafP = Paint()..color = const Color(0xFF2E7D32);
        canvas.drawOval(Rect.fromLTWH(-r * 0.3, -r * 1.25, r * 0.6, r * 0.4), leafP);
        break;

      case FruitType.orange:
        // Juicy Sunkist Orange with citrus segments
        paint.shader = const RadialGradient(
          colors: [Color(0xFFFFF176), Color(0xFFFF9800), Color(0xFFE65100)],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
        canvas.drawCircle(Offset.zero, r, paint);

        // Segment lines
        final lineP = Paint()
          ..color = Colors.white.withOpacity(0.55)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(Offset.zero, r * 0.85, lineP);
        for (int i = 0; i < 6; i++) {
          final ang = i * math.pi / 3;
          canvas.drawLine(
            Offset.zero,
            Offset(math.cos(ang) * r * 0.85, math.sin(ang) * r * 0.85),
            lineP,
          );
        }
        break;

      case FruitType.apple:
        // Crisp Red Apple
        paint.shader = const RadialGradient(
          center: Alignment(-0.2, -0.3),
          colors: [Color(0xFFFF8A80), Color(0xFFE53935), Color(0xFFB71C1C)],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
        canvas.drawCircle(Offset.zero, r, paint);

        // Top stem
        final stemP = Paint()
          ..color = const Color(0xFF5D4037)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(0, -r * 0.7), Offset(2, -r * 1.2), stemP);
        break;

      case FruitType.strawberry:
        // Ruby Strawberry
        paint.shader = const LinearGradient(
          colors: [Color(0xFFFF1744), Color(0xFFD50000)],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
        final sbPath = Path()
          ..moveTo(0, r)
          ..cubicTo(r * 1.2, r * 0.2, r * 0.9, -r * 0.7, 0, -r * 0.8)
          ..cubicTo(-r * 0.9, -r * 0.7, -r * 1.2, r * 0.2, 0, r)
          ..close();
        canvas.drawPath(sbPath, paint);
        break;

      case FruitType.blueberry:
        // Wild Blueberry
        paint.shader = const RadialGradient(
          colors: [Color(0xFF5C6BC0), Color(0xFF283593), Color(0xFF1A237E)],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
        canvas.drawCircle(Offset.zero, r, paint);
        break;
    }
  }

  void _drawJuicingExtractionZone(Canvas canvas, double cx, double cy) {
    // Glowing extraction vortex where fruits get transformed into fresh juice
    final vortexPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF9800).withOpacity(0.55),
          const Color(0xFFFF5722).withOpacity(0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 50));
    canvas.drawCircle(Offset(cx, cy), 50, vortexPaint);

    // Dynamic juice splash droplets bursting from juicing zone
    final splashPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < splashParticles.length; i++) {
      final p = splashParticles[i];
      final currentDist = p.distance + math.sin(flowPhase + i) * 8.0;
      final px = cx + math.cos(p.angle + flowPhase * 0.5) * currentDist;
      final py = cy + math.sin(p.angle + flowPhase * 0.5) * currentDist;
      splashPaint.color = p.color.withOpacity(0.75);
      canvas.drawCircle(Offset(px, py), p.radius, splashPaint);
    }
  }

  void _drawTumblerBack(
    Canvas canvas,
    double cx,
    double topY,
    double botY,
    double topRx,
    double botRx,
  ) {
    final backWallPath = Path()
      ..moveTo(cx - topRx, topY)
      ..lineTo(cx - botRx, botY)
      ..cubicTo(cx - botRx * 0.5, botY + 8, cx + botRx * 0.5, botY + 8, cx + botRx, botY)
      ..lineTo(cx + topRx, topY)
      ..cubicTo(cx + topRx * 0.5, topY - 12, cx - topRx * 0.5, topY - 12, cx - topRx, topY)
      ..close();

    final backPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isDark ? Colors.white : Colors.blueGrey).withOpacity(0.08),
          (isDark ? Colors.cyan : Colors.blue).withOpacity(0.04),
        ],
      ).createShader(Rect.fromLTRB(cx - topRx, topY, cx + topRx, botY));
    canvas.drawPath(backWallPath, backPaint);
  }

  void _drawLiquidFill(
    Canvas canvas,
    double cx,
    double topY,
    double botY,
    double topRx,
    double botRx,
    double height,
  ) {
    final currentLiquidTopY = botY - (height * fillPercent * 0.88);
    final widthFactor = (botY - currentLiquidTopY) / height;
    final liquidRx = botRx + (topRx - botRx) * widthFactor;

    final liquidPath = Path()
      ..moveTo(cx - liquidRx, currentLiquidTopY)
      ..lineTo(cx - botRx + 4, botY - 4);

    // Tumbler bottom rounded curve
    liquidPath.cubicTo(
      cx - botRx * 0.5,
      botY + 5,
      cx + botRx * 0.5,
      botY + 5,
      cx + botRx - 4,
      botY - 4,
    );

    liquidPath.lineTo(cx + liquidRx, currentLiquidTopY);

    // Liquid surface dynamic sine wave
    final waveAmplitude = (fillPercent < 0.98) ? 3.5 : 1.2;
    for (double x = cx + liquidRx; x >= cx - liquidRx; x -= 4.0) {
      final waveY = currentLiquidTopY + math.sin((x / 14.0) + flowPhase) * waveAmplitude;
      liquidPath.lineTo(x, waveY);
    }
    liquidPath.close();

    // Vibrant tropical juice gradient
    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFFFFD54F), // Bright mango golden top
          Color(0xFFFF9800), // Pure valencia orange body
          Color(0xFFF4511E), // Deep tropical nectar base
        ],
      ).createShader(Rect.fromLTRB(cx - liquidRx, currentLiquidTopY, cx + liquidRx, botY));
    canvas.drawPath(liquidPath, liquidPaint);

    // Effervescent rising bubbles
    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    for (final b in bubbles) {
      final bubbleY = botY - ((b.y + flowPhase * 0.2 * b.speed) % 1.0) * (botY - currentLiquidTopY);
      final bubbleWidth = liquidRx * 1.6;
      final bubbleX = cx - (liquidRx * 0.8) + (b.x * bubbleWidth);

      if (bubbleY > currentLiquidTopY + 4 && bubbleY < botY - 6) {
        canvas.drawCircle(Offset(bubbleX, bubbleY), b.radius, bubblePaint);
      }
    }

    // Floating Ice Cubes in the Tumbler
    if (fillPercent > 0.4) {
      final icePaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      final iceBorderPaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      final iceY = currentLiquidTopY + 8 + math.sin(flowPhase) * 2;
      canvas.save();
      canvas.translate(cx - 18, iceY);
      canvas.rotate(0.2);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-12, -12, 24, 24), const Radius.circular(6)), icePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-12, -12, 24, 24), const Radius.circular(6)), iceBorderPaint);
      canvas.restore();
    }
  }

  void _drawFlowingJuiceStream(
    Canvas canvas,
    double cx,
    double juicingZoneY,
    double topY,
    double botY,
    double height,
  ) {
    final streamBottomY = botY - (height * fillPercent * 0.88);
    if (streamBottomY <= juicingZoneY) return;

    final streamPath = Path();
    final streamWidth = 14.0;

    streamPath.moveTo(cx - streamWidth / 2, juicingZoneY);

    for (double y = juicingZoneY; y <= streamBottomY; y += 6.0) {
      final waveOffset = math.sin((y / 18.0) - flowPhase * 1.5) * 4.5;
      streamPath.lineTo(cx - streamWidth / 2 + waveOffset, y);
    }

    for (double y = streamBottomY; y >= juicingZoneY; y -= 6.0) {
      final waveOffset = math.sin((y / 18.0) - flowPhase * 1.5) * 4.5;
      streamPath.lineTo(cx + streamWidth / 2 + waveOffset, y);
    }
    streamPath.close();

    final streamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFFFFB300),
          Color(0xFFFF9800),
          Color(0xFFFF5722),
        ],
      ).createShader(Rect.fromLTRB(cx - streamWidth, juicingZoneY, cx + streamWidth, streamBottomY));
    canvas.drawPath(streamPath, streamPaint);

    // Glowing core stream line
    final corePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, juicingZoneY), Offset(cx, streamBottomY), corePaint);
  }

  void _drawTumblerFrontAndHighlights(
    Canvas canvas,
    double cx,
    double topY,
    double botY,
    double topRx,
    double botRx,
  ) {
    // 3D Glass Outline & Thick Base
    final glassPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.blueGrey).withOpacity(0.35)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke;

    final tumblerPath = Path()
      ..moveTo(cx - topRx, topY)
      ..lineTo(cx - botRx, botY)
      ..cubicTo(cx - botRx * 0.5, botY + 10, cx + botRx * 0.5, botY + 10, cx + botRx, botY)
      ..lineTo(cx + topRx, topY)
      ..cubicTo(cx + topRx * 0.5, topY - 10, cx - topRx * 0.5, topY - 10, cx - topRx, topY);
    canvas.drawPath(tumblerPath, glassPaint);

    // Tumbler Top Glass Rim Oval
    final rimPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, topY), width: topRx * 2, height: 16),
      rimPaint,
    );

    // Vertical Glass Curvature Reflection Highlight (Left)
    final highlightPath = Path()
      ..moveTo(cx - topRx + 6, topY + 10)
      ..lineTo(cx - botRx + 6, botY - 6);
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(highlightPath, highlightPaint);

    // Cold Condensation Water Droplets running down glass
    final dropPaint = Paint()..color = Colors.white.withOpacity(0.65);
    canvas.drawCircle(Offset(cx - topRx + 16, topY + 50 + math.sin(flowPhase) * 4), 2.5, dropPaint);
    canvas.drawCircle(Offset(cx + topRx - 20, topY + 80 + math.cos(flowPhase) * 5), 2.2, dropPaint);
    canvas.drawCircle(Offset(cx - botRx + 12, botY - 35), 3.0, dropPaint);
  }

  @override
  bool shouldRepaint(covariant _RealisticFruitToJuiceTumblerPainter oldDelegate) => true;
}
