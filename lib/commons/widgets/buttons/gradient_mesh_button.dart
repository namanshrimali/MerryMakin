import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientMeshButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;
  final AnimationController? gradientController;

  const GradientMeshButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
    this.gradientController,
  });

  @override
  State<GradientMeshButton> createState() => _GradientMeshButtonState();
}

class _GradientMeshButtonState extends State<GradientMeshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _meshController;

  @override
  void initState() {
    super.initState();
    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _meshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;
    final secondaryColor = widget.theme.colorScheme.secondary;

    return AnimatedBuilder(
      animation: _meshController,
      builder: (context, child) {
        final meshProgress = _meshController.value;

        return CustomPaint(
          painter: GradientMeshPainter(
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            progress: meshProgress,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
          ),
        );
      },
    );
  }
}

class GradientMeshPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double progress;

  GradientMeshPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = LinearGradient(
      begin: Alignment(
        sin(progress * 2 * pi),
        cos(progress * 2 * pi),
      ),
      end: Alignment(
        -sin(progress * 2 * pi),
        -cos(progress * 2 * pi),
      ),
      colors: [
        primaryColor,
        secondaryColor,
        primaryColor,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()..shader = shader;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant GradientMeshPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

