import 'package:flutter/material.dart';
import 'confetti_button.dart';
import 'gift_box_button.dart';
import 'floating_3d_button.dart';
import 'party_popper_button.dart';
import 'morphing_shape_button.dart';
import 'neon_glow_button.dart';
import 'glassmorphism_button.dart';
import 'liquid_morphing_button.dart';
import 'particle_trail_button.dart';
import 'split_color_button.dart';
import 'breathing_button.dart';
import 'ripple_wave_button.dart';
import 'gradient_mesh_button.dart';
import 'holographic_button.dart';
import 'shake_to_reveal_button.dart';
import 'magnetic_button.dart';
import 'minimalist_animated_button.dart';

/// Enum for different fun button styles
enum FunButtonStyle {
  confettiExplosion,
  giftBox,
  floating3D,
  partyPopper,
  morphingShape,
  neonGlow,
  glassmorphism,
  liquidMorphing,
  particleTrail,
  splitColor,
  breathing,
  rippleWave,
  gradientMesh,
  holographic,
  shakeToReveal,
  magnetic,
  minimalistAnimated,
}

class FunButton extends StatelessWidget {
  final FunButtonStyle style;
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;
  final AnimationController? bounceController;
  final AnimationController? gradientController;

  const FunButton({
    super.key,
    required this.style,
    required this.onPressed,
    this.text = 'Get Started',
    required this.theme,
    this.bounceController,
    this.gradientController,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case FunButtonStyle.confettiExplosion:
        return ConfettiButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
        );
      case FunButtonStyle.giftBox:
        return GiftBoxButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
        );
      case FunButtonStyle.floating3D:
        return Floating3DButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
        );
      case FunButtonStyle.partyPopper:
        return PartyPopperButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
        );
      case FunButtonStyle.morphingShape:
        return MorphingShapeButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
          bounceController: bounceController,
        );
      case FunButtonStyle.neonGlow:
        return NeonGlowButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
          gradientController: gradientController,
        );
      case FunButtonStyle.glassmorphism:
        return GlassmorphismButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
        );
      case FunButtonStyle.liquidMorphing:
        return LiquidMorphingButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
          gradientController: gradientController,
        );
      case FunButtonStyle.particleTrail:
        return ParticleTrailButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
        );
      case FunButtonStyle.splitColor:
        return SplitColorButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
          gradientController: gradientController,
        );
      case FunButtonStyle.breathing:
        return BreathingButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
          bounceController: bounceController,
        );
      case FunButtonStyle.rippleWave:
        return RippleWaveButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
        );
      case FunButtonStyle.gradientMesh:
        return GradientMeshButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
          gradientController: gradientController,
        );
      case FunButtonStyle.holographic:
        return HolographicButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
          gradientController: gradientController,
        );
      case FunButtonStyle.shakeToReveal:
        return ShakeToRevealButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
        );
      case FunButtonStyle.magnetic:
        return MagneticButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
        );
      case FunButtonStyle.minimalistAnimated:
        return MinimalistAnimatedButton(
          onPressed: onPressed,
          text: text,
          theme: theme,
          bounceController: bounceController,
        );
    }
  }
}

