import 'package:flutter/material.dart';

Gradient buildHeroGradient(List<Color> _gradientColors, {double topOffset = 0.0}) {
    // Apply gradient only at the bottom 25% of the image for text readability
    // Keep the rest of the image completely transparent and visible
    if (_gradientColors.length >= 3) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          _gradientColors[1].withOpacity(0.1),
          _gradientColors[1].withOpacity(0.4),
          _gradientColors[2].withOpacity(0.6),
          _gradientColors[2].withOpacity(1),
        ],
        stops: [0.55, 0.6, 0.7, 0.9, 1.0].map((stop) => stop + topOffset).toList(),
      );
    } else if (_gradientColors.length == 2) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.transparent,
          _gradientColors[1].withOpacity(0.3),
          _gradientColors[0].withOpacity(0.6),
          _gradientColors[0].withOpacity(0.75),
        ],
        stops: [0.0, 0.75, 0.8, 0.9, 0.95, 1.0].map((stop) => stop + topOffset).toList(),
      );
    } else {
      // Fallback to single color
      final gradientColor = _gradientColors[0] ?? Colors.black;
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.transparent,
          gradientColor.withOpacity(0.4),
          gradientColor.withOpacity(0.6),
          gradientColor.withOpacity(0.75),
        ],
        stops: [0.0, 0.75, 0.7, 0.9, 0.95, 1.0].map((stop) => stop + topOffset).toList(),
      );
    }
  }

  Gradient buildFullScreenGradient(List<Color> _gradientColors, {bool allowTransparency = true, double topOffset = 0.0}) {
    // Background gradient starts with same colors as hero overlay gradient at bottom
    // Then continues to evolve after the image area for seamless blending
    if (_gradientColors.length >= 3) {
      // Start with hero gradient's bottom colors, then evolve
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _gradientColors[1]
              .withOpacity(allowTransparency ? 0.9 : 1), // Match hero gradient at 0.75 stop
          _gradientColors[2]
              .withOpacity(allowTransparency ? 0.9 : 1), // Match hero gradient at 0.8 stop
          _gradientColors[2].withOpacity(
              allowTransparency ? 0.9: 1), // Match hero gradient at 1.0 stop (seamless transition)
          _gradientColors[1].withOpacity(allowTransparency ? 0.9 : 1), // Continue evolving
          _gradientColors[1].withOpacity(allowTransparency ? 0.9 : 1), // Transition to second color
        ],
        stops: [0.0, 0.3, 0.7, 0.9, 1.0].map((stop) => stop + topOffset).toList(),
      );
    } else if (_gradientColors.length == 2) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _gradientColors[1]
              .withOpacity(allowTransparency ? 0.3 : 1), // Match hero gradient at 0.9 stop
          _gradientColors[0]
              .withOpacity(allowTransparency ? 0.6 : 1), // Match hero gradient at 0.95 stop
          _gradientColors[0].withOpacity(
              allowTransparency ? 0.75 : 1), // Match hero gradient at 1.0 stop (seamless transition)
          _gradientColors[0].withOpacity(allowTransparency ? 0.85 : 1), // Continue evolving
          _gradientColors[0].withOpacity(allowTransparency ? 0.9 : 1),
          _gradientColors[1].withOpacity(allowTransparency ? 0.85 : 1), // Transition to first color
          _gradientColors[1]
              .withOpacity(allowTransparency ? 0.9 : 1), // Loop back - first color at bottom
        ],
        stops: [0.0, 0.05, 0.1, 0.3, 0.5, 0.75, 1.0].map((stop) => stop + topOffset).toList(),
      );
    } else {
      // Fallback to single color - match hero gradient then evolve
      final gradientColor = _gradientColors[0] ?? Colors.black;
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientColor.withOpacity(allowTransparency ? 0.4 : 1), // Match hero gradient at 0.9 stop
          gradientColor.withOpacity(allowTransparency ? 0.6 : 1 ), // Match hero gradient at 0.95 stop
          gradientColor.withOpacity(
              allowTransparency ? 0.75 : 1), // Match hero gradient at 1.0 stop (seamless transition)
          gradientColor.withOpacity(allowTransparency ? 0.85 : 1), // Continue evolving
          gradientColor.withOpacity(allowTransparency ? 0.92 : 1),
          gradientColor.withOpacity(allowTransparency ? 0.95 : 1), // Loop back at bottom
        ],
        stops: [0.0, 0.05, 0.1, 0.4, 0.7, 1.0].map((stop) => stop + topOffset).toList(),
      );
    }
  }
