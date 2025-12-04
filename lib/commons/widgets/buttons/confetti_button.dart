import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfettiButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;

  const ConfettiButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
  });

  @override
  State<ConfettiButton> createState() => _ConfettiButtonState();
}

class _ConfettiButtonState extends State<ConfettiButton>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _triggerConfetti() {
    _particles.clear();
    for (int i = 0; i < 30; i++) {
      _particles.add(ConfettiParticle(
        color: [
          widget.theme.colorScheme.primary,
          widget.theme.colorScheme.secondary,
          Colors.yellow,
          Colors.pink,
          Colors.blue,
        ][_random.nextInt(5)],
        angle: _random.nextDouble() * 2 * pi,
        speed: 200 + _random.nextDouble() * 300,
        size: 4 + _random.nextDouble() * 6,
      ));
    }
    _confettiController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;
    final secondaryColor = widget.theme.colorScheme.secondary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
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
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _triggerConfetti();
                widget.onPressed();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration, color: widget.theme.colorScheme.onPrimary, size: 22),
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
        // Confetti particles
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return CustomPaint(
              painter: ConfettiPainter(
                particles: _particles,
                progress: _confettiController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

class ConfettiParticle {
  final Color color;
  final double angle;
  final double speed;
  final double size;

  ConfettiParticle({
    required this.color,
    required this.angle,
    required this.speed,
    required this.size,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final distance = particle.speed * progress;
      final x = size.width / 2 + cos(particle.angle) * distance;
      final y = size.height / 2 + sin(particle.angle) * distance - (progress * progress * 400);

      final paint = Paint()
        ..color = particle.color.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: particle.size,
          height: particle.size,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

