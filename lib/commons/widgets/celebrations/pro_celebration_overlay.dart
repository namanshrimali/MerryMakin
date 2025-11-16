import 'package:flutter/material.dart';
import 'package:merrymakin/commons/themes/pro_themes.dart';
import 'celebration_animations.dart';
import 'celebration_effects.dart';

/// Controller to trigger celebration animations programmatically
/// 
/// Create an instance and pass it to ProCelebrationOverlay,
/// then call [play()] whenever you want to trigger the celebration effect.
/// 
/// Example:
/// ```dart
/// final celebrationController = CelebrationController();
/// 
/// ProCelebrationOverlay(
///   controller: celebrationController,
///   config: CelebrationConfig(...),
///   child: YourContent(),
/// )
/// 
/// // Later, trigger the celebration:
/// celebrationController.play();
/// ```
class CelebrationController {
  ProCelebrationOverlayState? _state;

  void _attach(ProCelebrationOverlayState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  /// Trigger the celebration animation
  void play() {
    _state?.play();
  }

  /// Check if animation is available
  bool get isAvailable => _state != null;
}

/// A reusable widget that provides celebration animations overlay
/// 
/// This widget wraps your content and provides various celebration effects
/// (confetti, shimmer, etc.) that can be triggered programmatically.
/// The effect type is determined by the CelebrationConfig.
/// 
/// Example usage (generic):
/// ```dart
/// final celebrationController = CelebrationController();
/// 
/// ProCelebrationOverlay(
///   controller: celebrationController,
///   config: CelebrationConfig(
///     type: CelebrationType.confetti,
///     duration: Duration(seconds: 3),
///     colors: [Colors.pink, Colors.orange, Colors.purple],
///     // ... other config options
///   ),
///   child: YourContent(),
/// )
/// 
/// // Trigger celebration from anywhere:
/// celebrationController.play();
/// ```
class ProCelebrationOverlay extends StatefulWidget {
  final Widget child;
  
  /// Controller to trigger animations programmatically
  /// If provided, you can call controller.play() to trigger the celebration effect
  final CelebrationController? controller;
  
  /// Direct configuration for the celebration animation
  /// If provided, this takes precedence over rsvpStatus
  final CelebrationConfig config;
  
  /// Theme type (used when rsvpStatus is provided)
  final ProThemeType themeType;
  
  final VoidCallback? onAnimationComplete;
  /// Override vertical position for effects that support it (e.g., confetti)
  /// If null, uses the position from CelebrationConfig
  final ConfettiVerticalPosition? verticalPosition;

  const ProCelebrationOverlay({
    super.key,
    required this.child,
    this.controller,
    required this.config,
    this.themeType = ProThemeType.midnight,
    this.onAnimationComplete,
    this.verticalPosition,
  });

  @override
  State<ProCelebrationOverlay> createState() => ProCelebrationOverlayState();
}

class ProCelebrationOverlayState extends State<ProCelebrationOverlay> {
  CelebrationEffect? _effect;

  @override
  void initState() {
    super.initState();
    _setupEffect();
    widget.controller?._attach(this);
  }

  void _setupEffect() {
    // Dispose existing effect if any
    _effect?.dispose();

    // Create effect based on config
    _effect = CelebrationEffectFactory.create(
      config: widget.config,
      onAnimationComplete: widget.onAnimationComplete,
      verticalPositionOverride: widget.verticalPosition,
    );

    // Initialize the effect
    _effect?.initialize();
  }

  @override
  void didUpdateWidget(ProCelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle controller changes
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
    
    // Handle config changes
    // Compare configs by value, not instance, to avoid unnecessary recreations
    final configChanged = !oldWidget.config.isEqual(widget.config) ||
        oldWidget.themeType != widget.themeType ||
        oldWidget.verticalPosition != widget.verticalPosition ||
        oldWidget.onAnimationComplete != widget.onAnimationComplete;
    
    if (configChanged) {
      _setupEffect();
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _effect?.dispose();
    super.dispose();
  }

  /// Play the celebration animation
  void play() {
    if (!mounted || _effect == null) {
      return;
    }
    _effect?.play();
  }

  @override
  Widget build(BuildContext context) {
    if (_effect == null || widget.config.type == CelebrationType.none) {
      return widget.child;
    }

    final effectWidgets = _effect!.buildWidgets();
    
    if (effectWidgets.isEmpty) {
      return widget.child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        ...effectWidgets,
      ],
    );
  }
}

/// Extension to easily access the celebration overlay controller
extension ProCelebrationOverlayExtension on BuildContext {
  /// Get the ProCelebrationOverlay state from the widget tree
  ProCelebrationOverlayState? findCelebrationOverlay() {
    return findAncestorStateOfType<ProCelebrationOverlayState>();
  }
}

