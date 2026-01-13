import 'dart:math';
import 'package:flutter/material.dart';
import '../themes/pro_themes.dart';

enum ProEffectType {
  none,
  snowflake,
  fall_leaves,
  stars,
  balloons,

  bubbles,
  confetti,
  hearts,
  // lanterns,
}

enum SnowflakeType {
  classic, // 6-branched recursive snowflake
  star, // 8-pointed star-like snowflake
  hexagonal, // Hexagonal center with detailed branches
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

    effects = List.generate(15, (index) => _createEffect(initialSize: index));
  }

  EffectItem _createEffect({int initialSize = 0}) {
    // Randomly assign snowflake type if effect is snowflake
    SnowflakeType? snowflakeType;
    if (widget.effectType == ProEffectType.snowflake) {
      final types = SnowflakeType.values;
      snowflakeType = types[random.nextInt(types.length)];
    }
    
    // Add rotation speed for snowflakes - each rotates at different rate
    double rotationSpeed = 0;
    if (widget.effectType == ProEffectType.snowflake) {
      // Random rotation speed between 0.5 and 2.0 radians per full cycle
      rotationSpeed = 5 + random.nextDouble() * 1.5;
    }
    
    // Determine wind sensitivity based on effect type
    double windSensitivity = 0.0;
    if (widget.effectType == ProEffectType.fall_leaves) {
      // Leaves are most affected by wind
      windSensitivity = 20 + random.nextDouble() * 10;
    } else if (widget.effectType == ProEffectType.snowflake) {
      // Snowflakes drift with wind but less than leaves
      // All snowflakes use same sensitivity range for consistency
      windSensitivity = 10 + random.nextDouble() * 10;
    } else if (widget.effectType == ProEffectType.confetti) {
      // Confetti is affected by wind
      windSensitivity = 20 + random.nextDouble() * 0.3;
    } else if (widget.effectType == ProEffectType.balloons) {
      // Balloons drift with wind
      windSensitivity = 20 + random.nextDouble() * 0.3;
    }
    
    // For snowflakes, use same wind phase (0) so they all follow same wind direction
    // For other effects, use random phase for individual variation
    final windPhase = (widget.effectType == ProEffectType.snowflake) 
        ? 0.0 
        : random.nextDouble() * 2 * pi;
    
    return EffectItem(
      position: Offset(
        random.nextDouble() * widget.size.width,
        random.nextDouble() * widget.size.height,
      ),
      size: initialSize + 10 + random.nextDouble() * 20,
      speed: 5 + random.nextDouble(),
      angle: random.nextDouble() * pi * 2,
      rotationSpeed: rotationSpeed,
      snowflakeType: snowflakeType,
      windSensitivity: windSensitivity,
      windPhase: windPhase,
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
  final double rotationSpeed;
  final SnowflakeType? snowflakeType;
  final double windSensitivity;
  final double windPhase;

  EffectItem({
    required this.position,
    required this.size,
    required this.speed,
    this.angle = 0,
    this.rotationSpeed = 0,
    this.snowflakeType,
    this.windSensitivity = 0.0,
    this.windPhase = 0.0,
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
    if (effectType == ProEffectType.fall_leaves) {
      effectColors = [Colors.orangeAccent, Colors.red];
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

      final direction = (effectType == ProEffectType.balloons || effectType == ProEffectType.bubbles) ? -1 : 1;

      // Calculate global wind direction that changes over time
      // Wind direction oscillates naturally using sine waves
      final windDirectionSpeed1 = 0.03; // Slow primary direction change
      final windDirectionSpeed2 = 0.08; // Faster secondary variation
      
      // Combine multiple sine waves for natural wind direction changes
      final direction1 = sin(progress * 2 * pi * windDirectionSpeed1) * pi; // -π to π
      final direction2 = sin(progress * 2 * pi * windDirectionSpeed2) * 0.5; // Smaller variation
      
      // Base wind direction oscillates around 0 (horizontal) with natural variation
      final baseWindDirection = direction1 * 0.7 + direction2 * 0.3;
      
      // Wind strength varies over time (using multiple sine waves for natural variation)
      final windStrengthSpeed1 = 0.3;
      final windStrengthSpeed2 = 0.5;
      final windStrengthSpeed3 = 0.2;
      
      final windStrength1 = sin(progress * 2 * pi * windStrengthSpeed1);
      final windStrength2 = sin(progress * 2 * pi * windStrengthSpeed2);
      final windStrength3 = sin(progress * 2 * pi * windStrengthSpeed3);
      
      // Combine wind strength components (normalized to 0-1 range, then scale)
      final normalizedWindStrength = (windStrength1 * 0.5 + windStrength2 * 0.3 + windStrength3 * 0.2 + 1.0) / 2.0;
      final windStrength = normalizedWindStrength * 0.2; // Base wind strength multiplier
      
      // For snowflakes, use the global wind direction directly
      // For other effects, add individual phase variation
      final windDirection = baseWindDirection + effect.windPhase;
      
      // Calculate wind vector components (x, y) based on direction
      final windX = cos(windDirection) * windStrength * effect.windSensitivity;
      final windY = sin(windDirection) * windStrength * effect.windSensitivity;
      
      // Apply wind as 2D offset
      final windDriftX = windX * size.width;
      final windDriftY = windY * size.height;
      
      // Update position based on progress
      final yOffset = direction * ((progress * effect.speed * size.height) % size.height);
      
      // Calculate position with wind effect
      final baseX = effect.position.dx;
      final baseY = effect.position.dy;
      
      final windX_final = (baseX + windDriftX) % size.width;
      final finalX = windX_final < 0 ? windX_final + size.width : windX_final;
      
      final windY_final = (baseY + yOffset + windDriftY) % size.height;
      final finalY = windY_final < 0 ? windY_final + size.height : windY_final;
      
      final currentPosition = Offset(finalX, finalY);
      
      // For leaves, update angle based on wind direction for realistic tilting
      double currentAngle = effect.angle;
      if (effectType == ProEffectType.fall_leaves) {
        // Leaves tilt in the direction of wind
        final windTilt = windDirection * 0.4; // Max tilt based on wind direction
        currentAngle = effect.angle + windTilt;
      }

      switch (effectType) {
        case ProEffectType.none:
          break;
        case ProEffectType.snowflake:
          // Add rotation based on progress and rotation speed
          final rotatedAngle = effect.angle + (progress * 2 * pi * effect.rotationSpeed);
          _drawSnowflake(
              canvas, currentPosition, effect.size, rotatedAngle, paint,
              snowflakeType: effect.snowflakeType ?? SnowflakeType.classic);
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
              canvas, currentPosition, effect.size, currentAngle, paint);
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
      {SnowflakeType snowflakeType = SnowflakeType.classic}) {
    switch (snowflakeType) {
      case SnowflakeType.classic:
        _drawClassicSnowflake(canvas, center, size, angle, paint);
        break;
      case SnowflakeType.star:
        _drawStarSnowflake(canvas, center, size, angle, paint);
        break;
      case SnowflakeType.hexagonal:
        _drawHexagonalSnowflake(canvas, center, size, angle, paint);
        break;
    }
  }

  void _drawClassicSnowflake(
      Canvas canvas, Offset center, double size, double angle, Paint paint,
      {int branches = 6, int depth = 3}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final double radius = size / 2;
    final double angleStep = (2 * pi) / branches;

    // Draw beautiful hexagonal center with inner detail
    final hexRadius = radius * 0.12;
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final double hexAngle = i * pi / 3;
      final double x = cos(hexAngle) * hexRadius;
      final double y = sin(hexAngle) * hexRadius;
      if (i == 0) {
        hexPath.moveTo(x, y);
      } else {
        hexPath.lineTo(x, y);
      }
    }
    hexPath.close();
    
    // Draw center hexagon with gradient effect
    final centerPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawPath(hexPath, centerPaint);
    
    // Inner hexagon for depth
    final innerHexPath = Path();
    final innerHexRadius = hexRadius * 0.6;
    for (int i = 0; i < 6; i++) {
      final double hexAngle = i * pi / 3;
      final double x = cos(hexAngle) * innerHexRadius;
      final double y = sin(hexAngle) * innerHexRadius;
      if (i == 0) {
        innerHexPath.moveTo(x, y);
      } else {
        innerHexPath.lineTo(x, y);
      }
    }
    innerHexPath.close();
    final innerPaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(innerHexPath, innerPaint);

    // Draw each arm with enhanced recursive branches
    for (int i = 0; i < branches; i++) {
      canvas.save();
      canvas.rotate(i * angleStep);
      _drawEnhancedFlakeBranch(canvas, radius * 0.85, paint, depth, hexRadius);
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawStarSnowflake(
      Canvas canvas, Offset center, double size, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    // Create beautiful plate-style snowflake with lace-like circular patterns
    final double radius = size / 2;
    final int segments = 12; // More segments for smoother circular pattern
    final double angleStep = (2 * pi) / segments;

    // Draw beautiful circular center with intricate patterns
    final centerRadius = radius * 0.16;
    final centerPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, centerRadius, centerPaint);
    
    // Inner circle for depth
    final innerPaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, centerRadius * 0.6, innerPaint);
    
    // Decorative rings around center
    final ringPaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset.zero, centerRadius * 1.2, ringPaint);
    canvas.drawCircle(Offset.zero, centerRadius * 1.4, ringPaint);

    // Create beautiful plate-style snowflake with lace-like patterns
    final mainPatternPaint = Paint()
      ..color = paint.color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final delicatePatternPaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * 0.8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final finePatternPaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * 0.65)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final ultraFinePaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * 0.5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw radial patterns creating a lace-like plate effect
    for (int i = 0; i < segments; i++) {
      final double currentAngle = i * angleStep;
      
      canvas.save();
      canvas.rotate(currentAngle);
      
      // Main radial pattern - elegant curved lines
      final List<Map<String, dynamic>> radialPatterns = [
        {'radius': 0.25, 'width': 0.08, 'style': 0},
        {'radius': 0.40, 'width': 0.06, 'style': 1},
        {'radius': 0.55, 'width': 0.05, 'style': 2},
        {'radius': 0.70, 'width': 0.04, 'style': 3},
        {'radius': 0.85, 'width': 0.03, 'style': 3},
      ];
      
      for (final pattern in radialPatterns) {
        final double patternRadius = radius * (pattern['radius'] as double);
        final double patternWidth = radius * (pattern['width'] as double);
        final int patternStyle = pattern['style'] as int;
        
        Paint currentPaint;
        switch (patternStyle) {
          case 0:
            currentPaint = mainPatternPaint;
            break;
          case 1:
            currentPaint = delicatePatternPaint;
            break;
          case 2:
            currentPaint = finePatternPaint;
            break;
          default:
            currentPaint = ultraFinePaint;
        }
        
        // Create elegant curved radial lines
        final path = Path();
        path.moveTo(centerRadius * 1.5, 0);
        
        // Create a beautiful curve
        final controlX = patternRadius * 0.3;
        final controlY = -patternRadius * 0.4;
        final endX = patternRadius;
        final endY = -patternRadius * 0.2;
        
        path.quadraticBezierTo(controlX, controlY, endX, endY);
        canvas.drawPath(path, currentPaint);
        
        // Add mirror curve on the other side
        final mirrorPath = Path();
        mirrorPath.moveTo(centerRadius * 1.5, 0);
        mirrorPath.quadraticBezierTo(-controlX, controlY, -endX, endY);
        canvas.drawPath(mirrorPath, currentPaint);
        
        // Add decorative elements at pattern points
        if (patternStyle == 0 || patternStyle == 1) {
          final decorPaint = Paint()
            ..color = paint.color.withOpacity(paint.color.opacity * 0.4)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(endX, endY), patternWidth * 0.3, decorPaint);
          canvas.drawCircle(Offset(-endX, endY), patternWidth * 0.3, decorPaint);
        }
      }
      
      // Add intricate connecting patterns between radials
      if (i % 2 == 0) {
        final List<double> connectionRadii = [0.32, 0.48, 0.64, 0.78];
        for (final connRadius in connectionRadii) {
          final double connX = cos(angleStep / 2) * radius * connRadius;
          final double connY = sin(angleStep / 2) * radius * connRadius;
          
          final connPath = Path();
          connPath.moveTo(centerRadius * 1.3, 0);
          connPath.quadraticBezierTo(
            connX * 0.5,
            connY * 0.5,
            connX,
            connY,
          );
          canvas.drawPath(connPath, finePatternPaint);
        }
      }
      
      canvas.restore();
    }

    // Add beautiful circular decorative rings
    final List<double> ringRadii = [0.30, 0.50, 0.68, 0.82];
    for (final ringRadius in ringRadii) {
      final ringPaint = Paint()
        ..color = paint.color.withOpacity(paint.color.opacity * 0.25)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset.zero, radius * ringRadius, ringPaint);
    }

    // Add delicate dot patterns for texture
    final dotPaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * 0.4)
      ..style = PaintingStyle.fill;
    
    final List<double> dotRadii = [0.35, 0.52, 0.70];
    for (final dotRadius in dotRadii) {
      for (int i = 0; i < segments * 2; i++) {
        final double dotAngle = i * pi / (segments);
        final double dotX = cos(dotAngle) * radius * dotRadius;
        final double dotY = sin(dotAngle) * radius * dotRadius;
        canvas.drawCircle(Offset(dotX, dotY), radius * 0.006, dotPaint);
      }
    }

    // Add outer edge decorative elements
    final outerDecorPaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    for (int i = 0; i < segments; i++) {
      final double outerAngle = i * angleStep;
      final double outerX = cos(outerAngle) * radius * 0.92;
      final double outerY = sin(outerAngle) * radius * 0.92;
      
      canvas.save();
      canvas.translate(outerX, outerY);
      canvas.rotate(outerAngle + pi / 2);
      
      // Delicate outer decorations
      for (final dir in [-1, 1]) {
        canvas.save();
        canvas.rotate(dir * pi / 6);
        final outerPath = Path();
        outerPath.moveTo(0, 0);
        outerPath.quadraticBezierTo(
          dir * radius * 0.03,
          -radius * 0.04,
          0,
          -radius * 0.06,
        );
        canvas.drawPath(outerPath, outerDecorPaint);
        canvas.restore();
      }
      
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawHexagonalSnowflake(
      Canvas canvas, Offset center, double size, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final int branches = 6;
    final double angleStep = (2 * pi) / branches;
    final double radius = size / 2;

    // Draw beautiful multi-layered hexagonal center
    final hexRadius = radius * 0.18;
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final double currentAngle = i * pi / 3;
      final double x = cos(currentAngle) * hexRadius;
      final double y = sin(currentAngle) * hexRadius;
      
      if (i == 0) {
        hexPath.moveTo(x, y);
      } else {
        hexPath.lineTo(x, y);
      }
    }
    hexPath.close();
    
    // Outer hexagon
    final centerPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawPath(hexPath, centerPaint);
    
    // Middle hexagon for depth
    final midHexPath = Path();
    final midHexRadius = hexRadius * 0.7;
    for (int i = 0; i < 6; i++) {
      final double currentAngle = i * pi / 3;
      final double x = cos(currentAngle) * midHexRadius;
      final double y = sin(currentAngle) * midHexRadius;
      if (i == 0) {
        midHexPath.moveTo(x, y);
      } else {
        midHexPath.lineTo(x, y);
      }
    }
    midHexPath.close();
    final midPaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawPath(midHexPath, midPaint);
    
    // Inner hexagon
    final innerHexPath = Path();
    final innerHexRadius = hexRadius * 0.4;
    for (int i = 0; i < 6; i++) {
      final double currentAngle = i * pi / 3;
      final double x = cos(currentAngle) * innerHexRadius;
      final double y = sin(currentAngle) * innerHexRadius;
      if (i == 0) {
        innerHexPath.moveTo(x, y);
      } else {
        innerHexPath.lineTo(x, y);
      }
    }
    innerHexPath.close();
    canvas.drawPath(innerHexPath, centerPaint);

    // Draw main branches with intricate detailed side branches
    final mainBranchPaint = Paint()
      ..color = paint.color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final sideBranchPaint = Paint()
      ..color = paint.color
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final thinBranchPaint = Paint()
      ..color = paint.color.withOpacity(paint.color.opacity * 0.8)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    for (int i = 0; i < branches; i++) {
      final double currentAngle = i * angleStep;
      final double branchLength = radius * 0.75;
      
      canvas.save();
      canvas.rotate(currentAngle);
      
      // Main branch with tapered effect
      canvas.drawLine(Offset(0, -hexRadius), Offset(0, -branchLength), mainBranchPaint);
      
      // Primary side branches at strategic positions
      final List<Map<String, double>> sideBranches = [
        {'pos': 0.25, 'length': 0.35, 'angle': pi / 3},
        {'pos': 0.45, 'length': 0.28, 'angle': pi / 3.5},
        {'pos': 0.65, 'length': 0.22, 'angle': pi / 4},
        {'pos': 0.85, 'length': 0.15, 'angle': pi / 5},
      ];
      
      for (final branch in sideBranches) {
        final double yPos = -hexRadius - branchLength * branch['pos']!;
        final double sideLength = branchLength * branch['length']!;
        final double sideAngle = branch['angle']!;
        
        // Left side branch
        canvas.save();
        canvas.translate(0, yPos);
        canvas.rotate(-sideAngle);
        canvas.drawLine(Offset.zero, Offset(0, -sideLength), sideBranchPaint);
        
        // Secondary branches on left side
        final List<double> secondaryPositions = [0.4, 0.7];
        for (final secPos in secondaryPositions) {
          canvas.save();
          canvas.translate(0, -sideLength * secPos);
          for (final dir in [-1, 1]) {
            canvas.save();
            canvas.rotate(dir * pi / 4);
            canvas.drawLine(Offset.zero, Offset(0, -sideLength * 0.3), thinBranchPaint);
            canvas.restore();
          }
          canvas.restore();
        }
        canvas.restore();
        
        // Right side branch
        canvas.save();
        canvas.translate(0, yPos);
        canvas.rotate(sideAngle);
        canvas.drawLine(Offset.zero, Offset(0, -sideLength), sideBranchPaint);
        
        // Secondary branches on right side
        for (final secPos in secondaryPositions) {
          canvas.save();
          canvas.translate(0, -sideLength * secPos);
          for (final dir in [-1, 1]) {
            canvas.save();
            canvas.rotate(dir * pi / 4);
            canvas.drawLine(Offset.zero, Offset(0, -sideLength * 0.3), thinBranchPaint);
            canvas.restore();
          }
          canvas.restore();
        }
        canvas.restore();
      }
      
      // Elegant end branches with decorative elements
      canvas.save();
      canvas.translate(0, -branchLength);
      
      // Main end branches
      for (final direction in [-1, 1]) {
        canvas.save();
        canvas.rotate(direction * pi / 4);
        final endLength = branchLength * 0.18;
        canvas.drawLine(Offset.zero, Offset(0, -endLength), sideBranchPaint);
        
        // Tiny decorative branches at end
        canvas.save();
        canvas.translate(0, -endLength);
        for (final dir in [-1, 1]) {
          canvas.save();
          canvas.rotate(dir * pi / 3);
          canvas.drawLine(Offset.zero, Offset(0, -endLength * 0.5), thinBranchPaint);
          canvas.restore();
        }
        canvas.restore();
        
        canvas.restore();
      }
      
      // Decorative circle at branch end
      final decorPaint = Paint()
        ..color = paint.color.withOpacity(paint.color.opacity * 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, radius * 0.015, decorPaint);
      
      canvas.restore();
      
      // Add small decorative dots along main branch
      for (final pos in [0.3, 0.6]) {
        final double dotY = -hexRadius - branchLength * pos;
        final dotPaint = Paint()
          ..color = paint.color.withOpacity(paint.color.opacity * 0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(0, dotY), radius * 0.01, dotPaint);
      }
      
      canvas.restore();
    }

    canvas.restore();
  }

// Enhanced recursive helper to draw a single arm with beautiful fractal branches
  void _drawEnhancedFlakeBranch(Canvas canvas, double length, Paint paint, int depth, double startOffset) {
    if (depth == 0) return;

    // Draw main line with varying thickness
    final mainPaint = Paint()
      ..color = paint.color
      ..strokeWidth = depth == 3 ? 1.8 : (depth == 2 ? 1.3 : 0.9)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(Offset(0, -startOffset), Offset(0, -length), mainPaint);

    // Position at intervals along the main branch to draw smaller arms
    final int segments = depth == 3 ? 4 : 3;
    for (int i = 1; i <= segments; i++) {
      final double y = -startOffset - length * (i / (segments + 1));
      final double side = length * (depth == 3 ? 0.45 : 0.4);
      final double branchAngle = depth == 3 ? pi / 5.5 : pi / 6;

      // Left and right side arms with varied angles
      for (final direction in [-1, 1]) {
        canvas.save();
        canvas.translate(0, y);
        canvas.rotate(direction * branchAngle);
        _drawEnhancedFlakeBranch(canvas, side, paint, depth - 1, 0);
        canvas.restore();
      }
      
      // Add tiny decorative branches for depth 3
      if (depth == 3 && i == segments) {
        final thinPaint = Paint()
          ..color = paint.color.withOpacity(paint.color.opacity * 0.7)
          ..strokeWidth = 0.6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        
        for (final direction in [-1, 1]) {
          canvas.save();
          canvas.translate(0, y);
          canvas.rotate(direction * pi / 3);
          canvas.drawLine(Offset.zero, Offset(0, -side * 0.3), thinPaint);
          canvas.restore();
        }
      }
    }
    
    // Add decorative element at branch end for top-level branches
    if (depth == 3) {
      final decorPaint = Paint()
        ..color = paint.color.withOpacity(paint.color.opacity * 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(0, -length), length * 0.03, decorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant EffectPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.effectType != effectType;
  }
}
