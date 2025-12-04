import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplitColorButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;
  final AnimationController? gradientController;

  const SplitColorButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
    this.gradientController,
  });

  @override
  State<SplitColorButton> createState() => _SplitColorButtonState();
}

class _SplitColorButtonState extends State<SplitColorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _splitController;

  @override
  void initState() {
    super.initState();
    _splitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _splitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;
    final secondaryColor = widget.theme.colorScheme.secondary;

    return AnimatedBuilder(
      animation: _splitController,
      builder: (context, child) {
        final splitProgress = _splitController.value;
        final angle = (splitProgress * 2 * pi) % (2 * pi);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.5),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Left side
                Positioned.fill(
                  child: Transform.rotate(
                    angle: angle * 0.1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        ),
                      ),
                    ),
                  ),
                ),
                // Right side
                Positioned.fill(
                  child: Transform.rotate(
                    angle: -angle * 0.1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [secondaryColor, secondaryColor.withOpacity(0.8)],
                        ),
                      ),
                    ),
                  ),
                ),
                // Content
                Material(
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
                            Icons.auto_awesome,
                            color: widget.theme.colorScheme.onPrimary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.text,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: widget.theme.colorScheme.onPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

