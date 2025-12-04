import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HolographicButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;
  final AnimationController? gradientController;

  const HolographicButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
    this.gradientController,
  });

  @override
  State<HolographicButton> createState() => _HolographicButtonState();
}

class _HolographicButtonState extends State<HolographicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hologramController;

  @override
  void initState() {
    super.initState();
    _hologramController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _hologramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hologramController,
      builder: (context, child) {
        final hologramProgress = _hologramController.value;

        return CustomPaint(
          painter: HolographicPainter(progress: hologramProgress),
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
                        color: _getHolographicColor(hologramProgress),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.text,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _getHolographicColor(hologramProgress),
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

  Color _getHolographicColor(double progress) {
    final hue = (progress * 360) % 360;
    return HSVColor.fromAHSV(1.0, hue, 0.8, 0.9).toColor();
  }
}

class HolographicPainter extends CustomPainter {
  final double progress;

  HolographicPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = List.generate(360, (i) {
      final hue = ((i + progress * 360) % 360) / 360.0;
      return HSVColor.fromAHSV(1.0, hue, 0.8, 0.9).toColor();
    });

    final shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        HSVColor.fromAHSV(1.0, (progress * 360) % 360, 0.8, 0.9).toColor(),
        HSVColor.fromAHSV(1.0, ((progress * 360) + 60) % 360, 0.8, 0.9).toColor(),
        HSVColor.fromAHSV(1.0, ((progress * 360) + 120) % 360, 0.8, 0.9).toColor(),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant HolographicPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

