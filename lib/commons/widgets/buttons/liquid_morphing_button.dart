import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiquidMorphingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;
  final AnimationController? gradientController;

  const LiquidMorphingButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
    this.gradientController,
  });

  @override
  State<LiquidMorphingButton> createState() => _LiquidMorphingButtonState();
}

class _LiquidMorphingButtonState extends State<LiquidMorphingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;
    final secondaryColor = widget.theme.colorScheme.secondary;

    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final waveProgress = _waveController.value;

        return CustomPaint(
          painter: LiquidMorphPainter(
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            progress: waveProgress,
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
                        Icons.water_drop,
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

class LiquidMorphPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double progress;

  LiquidMorphPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor, secondaryColor],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final waveHeight = 8.0;
    final frequency = 0.02;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          sin((x * frequency) + (progress * 2 * pi)) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidMorphPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

