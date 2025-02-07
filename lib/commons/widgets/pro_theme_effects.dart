import 'dart:math';
import 'package:flutter/material.dart';
import '../themes/pro_themes.dart';

enum ProEffectType {
  none,
  balloons,
  flowers,
  stars,
  bubbles,
  confetti,
  hearts,
  lanterns,
}

extension ProEffectTypeExtension on ProEffectType {
  String get displayName {
    switch (this) {
      case ProEffectType.none:
        return 'No Effects';
      case ProEffectType.balloons:
        return 'Floating Balloons';
      case ProEffectType.flowers:
        return 'Falling Petals';
      case ProEffectType.stars:
        return 'Twinkling Stars';
      case ProEffectType.bubbles:
        return 'Rising Bubbles';
      case ProEffectType.confetti:
        return 'Party Confetti';
      case ProEffectType.hearts:
        return 'Floating Hearts';
      case ProEffectType.lanterns:
        return 'Glowing Lanterns';
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

class _ProThemeEffectsState extends State<ProThemeEffects> with TickerProviderStateMixin {
  late List<EffectItem> effects;
  late AnimationController _controller;
  final Random random = Random();

  @override
  void initState() {
    // get size of screen, height and width
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 100),
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

  EffectItem({
    required this.position,
    required this.size,
    required this.speed,
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
    if (themeType == ProThemeType.chineseNewYear) {
      effectColors = [
        theme.primaryColor,                    // Orange
        theme.colorScheme.secondary,           // Gold
        theme.colorScheme.tertiary,            // Red
        theme.colorScheme.tertiary.withRed(240), // Light red
      ];
    }

    for (var effect in effects) {
      final paint = Paint()
        ..style = PaintingStyle.fill;
      
      // Rotate through colors for Chinese New Year theme
      if (themeType == ProThemeType.chineseNewYear) {
        paint.color = effectColors[effects.indexOf(effect) % effectColors.length]
            .withOpacity(0.6);
      } else {
        paint.color = theme.primaryColor.withOpacity(0.2);
      }

      // Update position based on progress
      final yOffset = (progress * effect.speed * size.height) % size.height;
      final currentPosition = Offset(
        effect.position.dx % size.width,
        (effect.position.dy - yOffset) % size.height,
      );

      switch (effectType) {
        case ProEffectType.none:
          break;
        case ProEffectType.flowers:
          _drawFlower(canvas, currentPosition, effect.size, paint);
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
        case ProEffectType.lanterns:
          _drawLantern(canvas, currentPosition, effect.size, paint);
          break;
        default:
          _drawBalloon(canvas, currentPosition, effect.size, paint);
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
      center.dx - size * 0.5, center.dy - size * 0.3,
      center.dx - size * 0.5, center.dy - size * 0.7,
      center.dx, center.dy - size * 0.2,
    );
    
    // Right curve
    path.cubicTo(
      center.dx + size * 0.5, center.dy - size * 0.7,
      center.dx + size * 0.5, center.dy - size * 0.3,
      center.dx, center.dy + size * 0.3,
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
      size * 0.3, 0,
      size * 0.2, size * 0.4,
    );
    lanternPath.lineTo(-size * 0.2, size * 0.4);
    lanternPath.quadraticBezierTo(
      -size * 0.3, 0,
      -size * 0.2, -size * 0.5,
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

  @override
  bool shouldRepaint(covariant EffectPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.effectType != effectType;
  }
} 