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
    }
  }
}

class ProThemeEffects extends StatefulWidget {
  final ProThemeType themeType;
  final ProEffectType effectType;
  final Widget child;

  const ProThemeEffects({
    Key? key,
    required this.themeType,
    required this.effectType,
    required this.child,
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
        random.nextDouble() * 400,
        random.nextDouble() * 800,
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
    final paint = Paint()
      ..color = theme.primaryColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (var effect in effects) {
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

  @override
  bool shouldRepaint(covariant EffectPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.effectType != effectType;
  }
} 