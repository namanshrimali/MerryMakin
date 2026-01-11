import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'celebration_animations.dart';

/// Abstract base class for all celebration effects
/// 
/// Each effect type (confetti, shimmer, etc.) implements this interface
/// to provide a consistent API for playing animations and building widgets.
abstract class CelebrationEffect {
  final CelebrationConfig config;
  final VoidCallback? onAnimationComplete;
  final ConfettiVerticalPosition? verticalPositionOverride;

  CelebrationEffect({
    required this.config,
    this.onAnimationComplete,
    this.verticalPositionOverride,
  });

  /// Initialize the effect (create controllers, etc.)
  void initialize();

  /// Play the celebration animation
  void play();

  /// Build the widget tree for this effect
  /// Returns a list of widgets to overlay on the content
  List<Widget> buildWidgets();

  /// Dispose of any resources (controllers, etc.)
  void dispose();
}

/// Confetti celebration effect implementation
class ConfettiEffect extends CelebrationEffect {
  late List<ConfettiController> _controllers;

  ConfettiEffect({
    required super.config,
    super.onAnimationComplete,
    super.verticalPositionOverride,
  });

  @override
  void initialize() {
    final controllerCount = config.numberOfControllers;
    _controllers = List.generate(
      controllerCount,
      (index) => ConfettiController(
        duration: config.duration,
      ),
    );
  }

  @override
  void play() {
    // Play all controllers with slight delays for more dynamic effect
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 0), () {
        _controllers[i].play();
      });
    }

    // Call completion callback after animation duration
    if (onAnimationComplete != null) {
      Future.delayed(config.duration, () {
        onAnimationComplete?.call();
      });
    }
  }

  @override
  List<Widget> buildWidgets() {
    return List.generate(
      _controllers.length,
      (index) {
        final controller = _controllers[index];
        final blastDir = _getBlastDirectionForIndex(index);
        return Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: _getAlignmentForIndex(index),
              child: ConfettiWidget(
                confettiController: controller,
                blastDirection: blastDir,
                emissionFrequency: config.emissionFrequency,
                numberOfParticles: config.numberOfParticles,
                gravity: config.gravity,
                colors: config.colors,
                minBlastForce: config.minBlastForce,
                maxBlastForce: config.maxBlastForce,
                shouldLoop: false,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
  }

  /// Get alignment position for each confetti controller
  Alignment _getAlignmentForIndex(int index) {
    final verticalPos = verticalPositionOverride ?? config.verticalPosition;
    
    // Calculate horizontal position based on number of controllers
    final totalControllers = _controllers.length;
    double horizontalX;
    if (totalControllers == 1) {
      horizontalX = 0.0; // Center
    } else {
      // Map index to position between -1.0 (left) and 1.0 (right)
      horizontalX = -1.0 + (index / (totalControllers - 1)) * 2.0;
    }
    
    // Combine with vertical position
    switch (verticalPos) {
      case ConfettiVerticalPosition.top:
        return Alignment(horizontalX, -1.0);
      case ConfettiVerticalPosition.center:
        return Alignment(horizontalX, 0.0);
      case ConfettiVerticalPosition.bottom:
        return Alignment(horizontalX, 1.0);
    }
  }

  /// Get blast direction for each controller with spread angle
  double _getBlastDirectionForIndex(int index) {
    final baseDirection = config.blastDirection;
    final spread = config.spreadAngle;
    final totalControllers = _controllers.length;
    final verticalPos = verticalPositionOverride ?? config.verticalPosition;
    
    // If no spread or only one controller, return base direction
    if (spread == 0.0 || totalControllers == 1) {
      return baseDirection;
    }
    
    // Special case: 2 controllers at bottom edges should converge toward center
    // Left edge (index 0) should shoot up-right, right edge (index 1) should shoot up-left
    if (totalControllers == 2 && verticalPos == ConfettiVerticalPosition.bottom) {
      // Left edge shoots up-right toward center: angle ≈ -π/4
      // Right edge shoots up-left toward center: angle ≈ -3π/4
      if (index == 0) {
        // also need to account for spread angle
        // Left edge: shoot up-right (-π/4 radians = -45°)
        return -1.308997;
      } else {
        // Right edge: shoot up-left (-3π/4 radians = -135°)
        return -1.832596;
      }
    }
    
    // Default spread logic for other cases
    final centerIndex = (totalControllers - 1) / 2.0;
    if (centerIndex == 0.0) {
      return baseDirection;
    }
    
    final offsetFromCenter = index - centerIndex;
    final angleOffset = (offsetFromCenter / centerIndex) * spread;
    
    return baseDirection + angleOffset;
  }
}

/// Shimmer celebration effect implementation
/// 
/// Placeholder for future shimmer effect implementation
class ShimmerEffect extends CelebrationEffect {
  ShimmerEffect({
    required super.config,
    super.onAnimationComplete,
    super.verticalPositionOverride,
  });

  @override
  void initialize() {
    // TODO: Initialize shimmer animation controllers
  }

  @override
  void play() {
    // TODO: Implement shimmer animation
    // Call completion callback
    if (onAnimationComplete != null) {
      Future.delayed(config.duration, () {
        onAnimationComplete?.call();
      });
    }
  }

  @override
  List<Widget> buildWidgets() {
    // TODO: Return shimmer effect widgets
    return [];
  }

  @override
  void dispose() {
    // TODO: Dispose shimmer resources
  }
}

/// Firework emoji celebration effect implementation
/// 
/// Creates animated emoji particles that explode outward like fireworks
class FireworkEmojiEffect extends CelebrationEffect {
  final List<_EmojiParticle> _particles = [];
  bool _isPlaying = false;
  ValueNotifier<double>? _animationProgress;
  Timer? _animationTimer;

  FireworkEmojiEffect({
    required super.config,
    super.onAnimationComplete,
    super.verticalPositionOverride,
  });

  @override
  void initialize() {
    // Create particles for each emoji
    final emojis = config.emojis.isEmpty 
        ? ['🎉', '🎊', '✨', '🌟', '💫', '⭐', '🎈', '🎁']
        : config.emojis;
    
    final particleCount = config.numberOfParticles;
    final random = math.Random();
    
    for (int i = 0; i < particleCount; i++) {
      final emoji = emojis[random.nextInt(emojis.length)];
      
      // Calculate random direction and velocity
      final angle = (config.blastDirection + 
          (random.nextDouble() - 0.5) * config.spreadAngle * 2);
      final speed = config.minBlastForce + 
          random.nextDouble() * (config.maxBlastForce - config.minBlastForce);
      
      _particles.add(_EmojiParticle(
        emoji: emoji,
        angle: angle,
        speed: speed,
        startX: 0.5, // Start from center
        startY: _getVerticalStartPosition(),
        size: 20 + random.nextDouble() * 20, // Random size between 20-40
      ));
    }
    
    _animationProgress = ValueNotifier<double>(0.0);
  }

  double _getVerticalStartPosition() {
    final verticalPos = verticalPositionOverride ?? config.verticalPosition;
    switch (verticalPos) {
      case ConfettiVerticalPosition.top:
        return 0.0;
      case ConfettiVerticalPosition.center:
        return 0.5;
      case ConfettiVerticalPosition.bottom:
        return 1.0;
    }
  }

  @override
  void play() {
    if (_isPlaying) return;
    _isPlaying = true;
    _animationProgress?.value = 0.0;
    
    // Cancel any existing timer
    _animationTimer?.cancel();
    
    // Animate from 0 to 1 over the duration
    final startTime = DateTime.now();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final elapsed = DateTime.now().difference(startTime);
      final progress = (elapsed.inMilliseconds / config.duration.inMilliseconds).clamp(0.0, 1.0);
      
      _animationProgress?.value = progress;
      
      if (progress >= 1.0) {
        timer.cancel();
        _animationTimer = null;
        _isPlaying = false;
        if (onAnimationComplete != null) {
          onAnimationComplete?.call();
        }
      }
    });
  }

  @override
  List<Widget> buildWidgets() {
    if (_particles.isEmpty || _animationProgress == null) return [];
    
    return [
      Positioned.fill(
        child: IgnorePointer(
          child: ValueListenableBuilder<double>(
            valueListenable: _animationProgress!,
            builder: (context, progress, child) {
              return CustomPaint(
                painter: _FireworkEmojiPainter(
                  particles: _particles,
                  gravity: config.gravity,
                  progress: progress,
                ),
              );
            },
          ),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _animationTimer = null;
    _animationProgress?.dispose();
    _animationProgress = null;
    _particles.clear();
  }
}

/// Represents a single emoji particle in the firework effect
class _EmojiParticle {
  final String emoji;
  final double angle;
  final double speed;
  final double startX;
  final double startY;
  final double size;

  _EmojiParticle({
    required this.emoji,
    required this.angle,
    required this.speed,
    required this.startX,
    required this.startY,
    required this.size,
  });
}

/// Custom painter for rendering emoji particles
class _FireworkEmojiPainter extends CustomPainter {
  final List<_EmojiParticle> particles;
  final double gravity;
  final double progress;

  _FireworkEmojiPainter({
    required this.particles,
    required this.gravity,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) return;
    
    for (var particle in particles) {
      
      // Calculate position based on angle, speed, and gravity
      final velocityX = math.cos(particle.angle) * particle.speed;
      final velocityY = math.sin(particle.angle) * particle.speed;
      
      // Apply gravity (positive Y is downward in Flutter)
      final x = particle.startX * size.width + 
          velocityX * size.width * progress;
      final y = particle.startY * size.height + 
          velocityY * size.height * progress + 
          gravity * size.height * progress * progress;
      
      // Calculate opacity (fade out as it moves)
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      
      // Calculate scale (slight shrink as it moves)
      final scale = (1.0 - progress * 0.3).clamp(0.5, 1.0);
      
      // Draw emoji
      final textPainter = TextPainter(
        text: TextSpan(
          text: particle.emoji,
          style: TextStyle(
            fontSize: particle.size * scale,
            color: Colors.white.withOpacity(opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          y - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_FireworkEmojiPainter oldDelegate) {
    return true; // Always repaint for smooth animation
  }
}


/// Balloon emoji celebration effect implementation
/// 
/// Creates emoji balloons that inflate to fill the screen, then pop
class BalloonEmojiEffect extends CelebrationEffect {
  final List<_BalloonParticle> _balloons = [];
  bool _isPlaying = false;
  ValueNotifier<double>? _animationProgress;
  Timer? _animationTimer;

  BalloonEmojiEffect({
    required super.config,
    super.onAnimationComplete,
    super.verticalPositionOverride,
  });

  @override
  void initialize() {
    // Create balloon particles
    final emojis = config.emojis.isEmpty 
        ? ['🎈', '🎉', '🎊', '🎁', '✨', '🌟', '💫', '⭐']
        : config.emojis;
    
    final balloonCount = config.numberOfControllers > 0 
        ? config.numberOfControllers 
        : 8; // Default to 8 balloons
    final random = math.Random();
    
    for (int i = 0; i < balloonCount; i++) {
      final emoji = emojis[random.nextInt(emojis.length)];
      
      // Random starting position
      final startX = 0.2 + random.nextDouble() * 0.6; // Avoid edges
      final startY = random.nextDouble() * 0.8;
      
      // Random delay for staggered inflation
      final delay = random.nextDouble() * 0.3;
      
      // Random max size (some balloons bigger than others)
      final maxSize = 80 + random.nextDouble() * 120; // 80-200
      
      _balloons.add(_BalloonParticle(
        emoji: emoji,
        startX: startX,
        startY: startY,
        delay: delay,
        maxSize: maxSize,
      ));
    }
    
    _animationProgress = ValueNotifier<double>(0.0);
  }

  @override
  void play() {
    if (_isPlaying) return;
    _isPlaying = true;
    _animationProgress?.value = 0.0;
    
    // Cancel any existing timer
    _animationTimer?.cancel();
    
    // Animate from 0 to 1 over the duration
    final startTime = DateTime.now();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final elapsed = DateTime.now().difference(startTime);
      final progress = (elapsed.inMilliseconds / config.duration.inMilliseconds).clamp(0.0, 1.0);
      
      _animationProgress?.value = progress;
      
      if (progress >= 1.0) {
        timer.cancel();
        _animationTimer = null;
        _isPlaying = false;
        if (onAnimationComplete != null) {
          onAnimationComplete?.call();
        }
      }
    });
  }

  @override
  List<Widget> buildWidgets() {
    if (_balloons.isEmpty || _animationProgress == null) return [];
    
    return [
      Positioned.fill(
        child: IgnorePointer(
          child: ValueListenableBuilder<double>(
            valueListenable: _animationProgress!,
            builder: (context, progress, child) {
              return CustomPaint(
                painter: _BalloonEmojiPainter(
                  balloons: _balloons,
                  progress: progress,
                ),
              );
            },
          ),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _animationTimer = null;
    _animationProgress?.dispose();
    _animationProgress = null;
    _balloons.clear();
  }
}

/// Represents a single balloon emoji particle
class _BalloonParticle {
  final String emoji;
  final double startX;
  final double startY;
  final double delay;
  final double maxSize;

  _BalloonParticle({
    required this.emoji,
    required this.startX,
    required this.startY,
    required this.delay,
    required this.maxSize,
  });
}

/// Custom painter for rendering balloon emoji particles
class _BalloonEmojiPainter extends CustomPainter {
  final List<_BalloonParticle> balloons;
  final double progress;

  _BalloonEmojiPainter({
    required this.balloons,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) return;
    
    for (var balloon in balloons) {
      // Calculate effective progress for this balloon (with delay)
      final effectiveProgress = ((progress - balloon.delay) / (1.0 - balloon.delay)).clamp(0.0, 1.0);
      
      if (effectiveProgress <= 0.0) continue;
      
      // Phase 1: Inflate (0-0.7 of effective progress)
      // Phase 2: Pop (0.7-1.0 of effective progress)
      final inflatePhase = 0.7;
      
      double scale;
      double opacity;
      
      if (effectiveProgress < inflatePhase) {
        // Inflating phase: grow from 0.1 to 1.0
        final inflateProgress = effectiveProgress / inflatePhase;
        // Use ease-out curve for smooth inflation
        final easedProgress = 1 - math.pow(1 - inflateProgress, 3);
        scale = 0.1 + easedProgress * 0.9;
        opacity = 1.0;
      } else {
        // Popping phase: shrink and fade
        final popProgress = (effectiveProgress - inflatePhase) / (1.0 - inflatePhase);
        scale = 1.0 - popProgress * 0.5; // Shrink to 50%
        opacity = 1.0 - popProgress; // Fade out
      }
      
      final currentSize = balloon.maxSize * scale;
      final x = balloon.startX * size.width;
      final y = balloon.startY * size.height;
      
      // Draw emoji with opacity
      final textPainter = TextPainter(
        text: TextSpan(
          text: balloon.emoji,
          style: TextStyle(
            fontSize: currentSize,
            color: Colors.white.withOpacity(opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          y - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_BalloonEmojiPainter oldDelegate) {
    return true; // Always repaint for smooth animation
  }
}

/// No-op effect for when no celebration is needed
class NoneEffect extends CelebrationEffect {
  NoneEffect({
    required super.config,
    super.onAnimationComplete,
    super.verticalPositionOverride,
  });

  @override
  void initialize() {
    // No initialization needed
  }

  @override
  void play() {
    // No animation to play
    if (onAnimationComplete != null) {
      onAnimationComplete?.call();
    }
  }

  @override
  List<Widget> buildWidgets() {
    return [];
  }

  @override
  void dispose() {
    // Nothing to dispose
  }
}

/// Factory for creating celebration effects based on configuration
class CelebrationEffectFactory {
  /// Create an effect instance based on the celebration type
  static CelebrationEffect create({
    required CelebrationConfig config,
    VoidCallback? onAnimationComplete,
    ConfettiVerticalPosition? verticalPositionOverride,
  }) {
    switch (config.type) {
      case CelebrationType.confetti:
        return ConfettiEffect(
          config: config,
          onAnimationComplete: onAnimationComplete,
          verticalPositionOverride: verticalPositionOverride,
        );
      case CelebrationType.shimmer:
        return ShimmerEffect(
          config: config,
          onAnimationComplete: onAnimationComplete,
          verticalPositionOverride: verticalPositionOverride,
        );
      case CelebrationType.fireworkEmoji:
        return FireworkEmojiEffect(
          config: config,
          onAnimationComplete: onAnimationComplete,
          verticalPositionOverride: verticalPositionOverride,
        );
      case CelebrationType.balloonEmoji:
        return BalloonEmojiEffect(
          config: config,
          onAnimationComplete: onAnimationComplete,
          verticalPositionOverride: verticalPositionOverride,
        );
      case CelebrationType.none:
        return NoneEffect(
          config: config,
          onAnimationComplete: onAnimationComplete,
          verticalPositionOverride: verticalPositionOverride,
        );
    }
  }
}

