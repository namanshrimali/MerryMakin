import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/themes/pro_themes.dart';

/// Types of celebration animations available
enum CelebrationType {
  confetti,
  shimmer,
  fireworkEmoji,
  balloonEmoji,
  none,
  // Future: emojiRain, particles, etc.
}

/// Vertical position for confetti controllers
enum ConfettiVerticalPosition {
  top,
  center,
  bottom,
}

/// Configuration for celebration animations based on RSVP status
class CelebrationConfig {
  final CelebrationType type;
  final Duration duration;
  final List<Color> colors;
  final double blastDirection;
  final double emissionFrequency;
  final int numberOfParticles;
  final double gravity;
  final double minBlastForce;
  final double maxBlastForce;
  final ConfettiVerticalPosition verticalPosition;

  /// Number of controllers to create for fuller effect
  final int numberOfControllers;

  /// Spread angle in radians for creating a cone effect
  /// Larger values create wider spread
  final double spreadAngle;

  /// List of emojis to use for firework emoji effect
  final List<String> emojis;

  const CelebrationConfig({
    required this.type,
    required this.duration,
    required this.colors,
    this.blastDirection = 0,
    this.emissionFrequency = 0.05,
    this.numberOfParticles = 50,
    this.gravity = 0.01,
    this.minBlastForce = 0.05,
    this.maxBlastForce = 0.12,
    this.verticalPosition = ConfettiVerticalPosition.center,
    this.numberOfControllers = 3,
    this.spreadAngle = 0.0,
    this.emojis = const [],
  });

  /// Compare two configs by value (not instance)
  bool isEqual(CelebrationConfig other) {
    return type == other.type &&
        duration == other.duration &&
        blastDirection == other.blastDirection &&
        emissionFrequency == other.emissionFrequency &&
        numberOfParticles == other.numberOfParticles &&
        gravity == other.gravity &&
        minBlastForce == other.minBlastForce &&
        maxBlastForce == other.maxBlastForce &&
        verticalPosition == other.verticalPosition &&
        numberOfControllers == other.numberOfControllers &&
        spreadAngle == other.spreadAngle &&
        colors.length == other.colors.length &&
        colors.every((color) => other.colors.contains(color)) &&
        emojis.length == other.emojis.length &&
        emojis.every((emoji) => other.emojis.contains(emoji));
  }

  /// Get celebration configuration based on RSVP status and theme
  static CelebrationConfig forRsvpStatus(
    RSVPStatus status,
    ProThemeType themeType,
  ) {
    final theme = ProThemes.themes[themeType]?.theme;
    final primaryColor = theme?.colorScheme.primary ?? Colors.blue;
    final secondaryColor = theme?.colorScheme.secondary ?? Colors.blue.shade700;
    final tertiaryColor = theme?.colorScheme.tertiary ?? Colors.blue.shade50;

    switch (status) {
      case RSVPStatus.GOING:
        // Festive confetti with theme colors + festive accents
        // Confetti launches from bottom, goes up, then falls down

        return CelebrationConfig(
          type: CelebrationType.confetti,
          duration: const Duration(seconds: 1),
          colors: [
            primaryColor,
            secondaryColor,
            tertiaryColor,
            Colors.pink,
            Colors.orange,
            Colors.purple,
            Colors.yellow,
            Colors.green,
          ],
          blastDirection: -math.pi / 2,
          emissionFrequency: 0.05,
          numberOfParticles: 50,
          gravity: 0.5, // Pulls confetti down after it goes up
          minBlastForce: 0.1, // Increased force to go higher
          maxBlastForce: 100, // Increased force to go higher
          verticalPosition:
              ConfettiVerticalPosition.top, // Controllers at absolute bottom
          numberOfControllers: 20, // More controllers for fuller effect
          spreadAngle:
              math.pi / 4, // 45 degrees spread (π/4 radians) for wide cone
        );

      case RSVPStatus.MAYBE:
        // Subtle shimmer effect (can be extended later)
        return CelebrationConfig(
          type: CelebrationType.shimmer,
          duration: const Duration(seconds: 1),
          colors: [
            primaryColor.withOpacity(0.6),
            secondaryColor.withOpacity(0.4),
          ],
          emissionFrequency: 0.1,
          numberOfParticles: 20,
          gravity: 0.05,
          minBlastForce: 0.02,
          maxBlastForce: 0.04,
        );

      case RSVPStatus.NOT_GOING:
      case RSVPStatus.UNDECIDED:
        // No animation
        return CelebrationConfig(
          type: CelebrationType.none,
          duration: Duration.zero,
          colors: [],
        );
    }
  }
}
