import 'dart:math';
import 'package:flutter/material.dart';
import '../themes/pro_themes.dart';

enum ProEffectType {
  none,
  fall_leaves,
  snowflake,
  stars,
  balloons,

  bubbles,
  confetti,
  hearts,
  // lanterns,
}

extension ProEffectTypeExtension on ProEffectType {
  String get displayName {
    switch (this) {
      case ProEffectType.none:
        return 'No Effects';
      case ProEffectType.balloons:
        return 'Floating Balloons';
      case ProEffectType.snowflake:
        return 'Snowflakes';
      case ProEffectType.stars:
        return 'Twinkling Stars';
      case ProEffectType.bubbles:
        return 'Rising Bubbles';
      case ProEffectType.confetti:
        return 'Party Confetti';
      case ProEffectType.hearts:
        return 'Floating Hearts';
      // case ProEffectType.lanterns:
      //   return 'Glowing Lanterns';
      case ProEffectType.fall_leaves:
        return 'Fall leaves';
    }
  }
}

class ProThemeEffects extends StatefulWidget {
  final ProThemeType themeType;
  final ProEffectType effectType;
  final Widget child;
  final Size size;

  const ProThemeEffects({
    Key? key,
    required this.themeType,
    required this.effectType,
    required this.child,
    required this.size,
  }) : super(key: key);

  @override
  State<ProThemeEffects> createState() => _ProThemeEffectsState();
}

class _ProThemeEffectsState extends State<ProThemeEffects>
    with TickerProviderStateMixin {
  late List<EffectItem> effects;
  late AnimationController _controller;
  final Random random = Random();

  @override
  void initState() {
    // get size of screen, height and width
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 300),
      vsync: this,
    )..repeat();

    effects = List.generate(15, (index) => _createEffect());
  }

  EffectItem _createEffect() {
    return EffectItem(
      position: Offset(
        random.nextDouble() * widget.size.width,
        random.nextDouble() * widget.size.height,
      ),
      size: 10 + random.nextDouble() * 20,
      speed: 1 + random.nextDouble(),
      angle: random.nextDouble() * pi * 2,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: EffectPainter(
                    themeType: widget.themeType,
                    effectType: widget.effectType,
                    progress: _controller.value,
                    effects: effects,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class EffectItem {
  Offset position;
  final double size;
  final double speed;
  final double angle;

  EffectItem({
    required this.position,
    required this.size,
    required this.speed,
    this.angle = 0,
  });
}

class EffectPainter extends CustomPainter {
  final ProThemeType themeType;
  final ProEffectType effectType;
  final double progress;
  final List<EffectItem> effects;

  EffectPainter({
    required this.themeType,
    required this.effectType,
    required this.progress,
    required this.effects,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final theme = ProThemes.themes[themeType]!.theme;

    // Get theme-specific colors for Chinese New Year
    List<Color> effectColors = [theme.primaryColor];
    if (themeType == ProThemeType.chineseNewYear ||
        themeType == ProThemeType.christmasWinter) {
      effectColors = [
        theme.primaryColor, // Orange
        theme.colorScheme.secondary, // Gold
        theme.colorScheme.tertiary, // Red
        theme.colorScheme.tertiary.withRed(240), // Light red
      ];
    }
    if (themeType == ProThemeType.autumn) {
      effectColors = [
        theme.primaryColor, // Orange
        Colors.orangeAccent,
        Colors.red
      ];
    }

    for (var effect in effects) {
      final paint = Paint()..style = PaintingStyle.fill;

      // Rotate through colors for Chinese New Year theme
      if (effectType == ProEffectType.confetti ||
          effectType == ProEffectType.fall_leaves ||
          effectType == ProEffectType.snowflake) {
        paint.color =
            effectColors[effects.indexOf(effect) % effectColors.length]
                .withOpacity(0.6);
      } else {
        paint.color = theme.primaryColor.withOpacity(0.2);
      }

      // Update position based on progress
      final yOffset = (progress * effect.speed * size.height) % size.height;
      final currentPosition = Offset(
        effect.position.dx % size.width,
        (effect.position.dy + yOffset) % size.height,
      );

      switch (effectType) {
        case ProEffectType.none:
          break;
        case ProEffectType.snowflake:
          _drawSnowflake(
              canvas, currentPosition, effect.size, effect.angle, paint);
          break;
        case ProEffectType.stars:
          _drawStar(canvas, currentPosition, effect.size, paint);
          break;
        case ProEffectType.bubbles:
          _drawBubble(canvas, currentPosition, effect.size, paint);
          break;
        case ProEffectType.confetti:
          _drawConfetti(canvas, currentPosition, effect.size, paint);
          break;
        case ProEffectType.hearts:
          _drawHeart(canvas, currentPosition, effect.size, paint);
          break;
        case ProEffectType.balloons:
          _drawBalloon(canvas, currentPosition, effect.size, paint);
          break;
        case ProEffectType.fall_leaves:
          _drawMapleLeaf(
              canvas, currentPosition, effect.size, effect.angle, paint);
          break;
      }
    }
  }

  void _drawBubble(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawCircle(center, size / 2, paint);

    // Add highlight to bubble
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx - size * 0.2, center.dy - size * 0.2),
      size * 0.2,
      highlightPaint,
    );
  }

  void _drawConfetti(Canvas canvas, Offset center, double size, Paint paint) {
    final rect = Rect.fromCenter(
      center: center,
      width: size * 0.4,
      height: size,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * 2 * pi);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);

    // Left curve
    path.cubicTo(
      center.dx - size * 0.5,
      center.dy - size * 0.3,
      center.dx - size * 0.5,
      center.dy - size * 0.7,
      center.dx,
      center.dy - size * 0.2,
    );

    // Right curve
    path.cubicTo(
      center.dx + size * 0.5,
      center.dy - size * 0.7,
      center.dx + size * 0.5,
      center.dy - size * 0.3,
      center.dx,
      center.dy + size * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  void _drawFlower(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final angle = (i * 2 * pi) / 5;
      final petalPath = Path()
        ..moveTo(center.dx, center.dy)
        ..quadraticBezierTo(
          center.dx + cos(angle) * size,
          center.dy + sin(angle) * size,
          center.dx + cos(angle + pi / 5) * size,
          center.dy + sin(angle + pi / 5) * size,
        );
      path.addPath(petalPath, Offset.zero);
    }
    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final angle = (i * 2 * pi) / 5 - pi / 2;
      final point = Offset(
        center.dx + cos(angle) * size,
        center.dy + sin(angle) * size,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawBalloon(Canvas canvas, Offset center, double size, Paint paint) {
    // Balloon body
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size,
        height: size * 1.2,
      ),
      paint,
    );

    // Balloon string
    final stringPaint = Paint()
      ..color = paint.color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(center.dx, center.dy + size * 0.6)
      ..quadraticBezierTo(
        center.dx + size * 0.2,
        center.dy + size,
        center.dx,
        center.dy + size * 1.2,
      );

    canvas.drawPath(path, stringPaint);
  }

  void _drawLantern(Canvas canvas, Offset center, double size, Paint paint) {
    // Save canvas state
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Create glow effect
    final glowPaint = Paint()
      ..color = paint.color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    // Draw glow
    canvas.drawCircle(Offset.zero, size * 0.8, glowPaint);

    // Draw lantern body
    final lanternPath = Path();

    // Top cap
    lanternPath.moveTo(-size * 0.2, -size * 0.5);
    lanternPath.lineTo(size * 0.2, -size * 0.5);

    // Main body - slightly curved sides
    lanternPath.quadraticBezierTo(
      size * 0.3,
      0,
      size * 0.2,
      size * 0.4,
    );
    lanternPath.lineTo(-size * 0.2, size * 0.4);
    lanternPath.quadraticBezierTo(
      -size * 0.3,
      0,
      -size * 0.2,
      -size * 0.5,
    );

    // Bottom tassel
    final tasselPath = Path()
      ..moveTo(-size * 0.1, size * 0.4)
      ..lineTo(0, size * 0.6)
      ..lineTo(size * 0.1, size * 0.4);

    // Draw with slight gradient for 3D effect
    final gradient = RadialGradient(
      center: const Alignment(0.2, -0.2),
      radius: 0.8,
      colors: [
        paint.color,
        paint.color.withOpacity(0.7),
      ],
    );

    final lanternPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: size),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(lanternPath, lanternPaint);
    canvas.drawPath(tasselPath, paint);

    // Add decorative lines
    final linePaint = Paint()
      ..color = paint.color.withOpacity(0.8)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal decorative lines
    for (var i = 1; i < 3; i++) {
      final y = -size * 0.3 + (i * size * 0.2);
      canvas.drawLine(
        Offset(-size * 0.2, y),
        Offset(size * 0.2, y),
        linePaint,
      );
    }

    // Restore canvas state
    canvas.restore();
  }

  void _drawMapleLeaf(
      Canvas canvas, Offset center, double size, double angle, Paint paint) {
    canvas.save();

    // Move canvas origin to center and rotate by given angle (in radians)
    canvas.translate(center.dx, center.dy);
    // final angle = Random().nextDouble(); // Random rotation in radians
    canvas.rotate(angle);

    final Path path = Path();
    final double s = size;

    // Define the leaf shape relative to the rotated coordinate system
    path.moveTo(0, s * 0.8);
    path.quadraticBezierTo(-s * 0.4, s * 0.4, -s * 0.5, s * 0.1);
    path.quadraticBezierTo(-s * 0.7, 0, -s * 0.4, -s * 0.1);
    path.quadraticBezierTo(-s * 0.7, -s * 0.6, -s * 0.2, -s * 0.6);
    path.quadraticBezierTo(0, -s * 1.2, s * 0.2, -s * 0.6);
    path.quadraticBezierTo(s * 0.7, -s * 0.6, s * 0.4, -s * 0.1);
    path.quadraticBezierTo(s * 0.7, 0, s * 0.5, s * 0.1);
    path.quadraticBezierTo(s * 0.4, s * 0.4, 0, s * 0.8);
    path.close();

    // Draw the leaf
    canvas.drawPath(path, paint);

    // Optional: draw the stem
    final Paint stemPaint = Paint()
      ..color = paint.color
      ..strokeWidth = size * 0.05
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, s * 0.8), Offset(0, s * 1.2), stemPaint);

    // Restore canvas state (so next leaf is not affected by rotation)
    canvas.restore();
  }

  void _drawSnowflake(
      Canvas canvas, Offset center, double size, double angle, Paint paint,
      {int branches = 6, int depth = 3}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final double angleStep = (2 * pi) / branches;

    // Draw each arm with recursive branches
    for (int i = 0; i < branches; i++) {
      canvas.save();
      canvas.rotate(i * angleStep);
      _drawFlakeBranch(canvas, size / 2, paint, depth);
      canvas.restore();
    }

    canvas.restore();
  }

// Recursive helper to draw a single arm with small side branches
  void _drawFlakeBranch(Canvas canvas, double length, Paint paint, int depth) {
    if (depth == 0) return;

    // Draw main line
    canvas.drawLine(Offset.zero, Offset(0, -length), paint);

    // Position at intervals along the main branch to draw smaller arms
    final int segments = 3;
    for (int i = 1; i <= segments; i++) {
      final double y = -length * (i / (segments + 1));
      final double side = length * 0.4;

      // Left and right side arms
      for (final direction in [-1, 1]) {
        canvas.save();
        canvas.translate(0, y);
        canvas.rotate(direction * pi / 6);
        _drawFlakeBranch(canvas, side, paint, depth - 1);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant EffectPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.effectType != effectType;
  }
}
