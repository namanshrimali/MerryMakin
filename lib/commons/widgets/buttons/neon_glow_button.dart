import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeonGlowButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;
  final AnimationController? gradientController;

  const NeonGlowButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
    this.gradientController,
  });

  @override
  State<NeonGlowButton> createState() => _NeonGlowButtonState();
}

class _NeonGlowButtonState extends State<NeonGlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;
    final secondaryColor = widget.theme.colorScheme.secondary;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseValue = _pulseController.value;
        final glowIntensity = 0.6 + (pulseValue * 0.4);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: primaryColor.withOpacity(glowIntensity),
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.2),
                secondaryColor.withOpacity(0.2),
              ],
            ),
            boxShadow: [
              // Neon glow layers
              BoxShadow(
                color: primaryColor.withOpacity(0.8 * glowIntensity),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: primaryColor.withOpacity(0.6 * glowIntensity),
                blurRadius: 30,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: primaryColor.withOpacity(0.4 * glowIntensity),
                blurRadius: 40,
                spreadRadius: 6,
              ),
              BoxShadow(
                color: secondaryColor.withOpacity(0.5 * glowIntensity),
                blurRadius: 25,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: primaryColor.withOpacity(glowIntensity),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.text,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: primaryColor.withOpacity(glowIntensity),
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: primaryColor.withOpacity(0.8 * glowIntensity),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

