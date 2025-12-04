import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RippleWaveButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;

  const RippleWaveButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
  });

  @override
  State<RippleWaveButton> createState() => _RippleWaveButtonState();
}

class _RippleWaveButtonState extends State<RippleWaveButton>
    with TickerProviderStateMixin {
  final List<Ripple> _ripples = [];
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _addRipple();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _addRipple() {
    setState(() {
      _ripples.add(Ripple(progress: 0.0));
      if (_ripples.length > 3) {
        _ripples.removeAt(0);
      }
    });
    Future.delayed(const Duration(milliseconds: 600), _addRipple);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;
    final secondaryColor = widget.theme.colorScheme.secondary;

    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        // Update ripple progress
        for (var ripple in _ripples) {
          ripple.progress = (_rippleController.value * 2) % 1.0;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Ripple waves
            ..._ripples.map((ripple) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: RipplePainter(
                    ripple: ripple,
                    color: primaryColor,
                  ),
                ),
              );
            }),
            // Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, secondaryColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.5),
                    blurRadius: 24,
                    spreadRadius: 2,
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
                          Icons.waves,
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
          ],
        );
      },
    );
  }
}

class Ripple {
  double progress;

  Ripple({required this.progress});
}

class RipplePainter extends CustomPainter {
  final Ripple ripple;
  final Color color;

  RipplePainter({
    required this.ripple,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = sqrt(size.width * size.width + size.height * size.height) / 2;
    final radius = maxRadius * ripple.progress;

    final paint = Paint()
      ..color = color.withOpacity((1 - ripple.progress) * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) {
    return oldDelegate.ripple.progress != ripple.progress;
  }
}

