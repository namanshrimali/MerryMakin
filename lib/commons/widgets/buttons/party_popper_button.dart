import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PartyPopperButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;

  const PartyPopperButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
  });

  @override
  State<PartyPopperButton> createState() => _PartyPopperButtonState();
}

class _PartyPopperButtonState extends State<PartyPopperButton>
    with TickerProviderStateMixin {
  late AnimationController _popController;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  void _triggerPop() {
    _particles.clear();
    for (int i = 0; i < 40; i++) {
      _particles.add(Particle(
        color: [
          widget.theme.colorScheme.primary,
          widget.theme.colorScheme.secondary,
          Colors.yellow,
          Colors.pink,
          Colors.blue,
          Colors.green,
        ][_random.nextInt(6)],
        angle: _random.nextDouble() * 2 * pi,
        speed: 300 + _random.nextDouble() * 400,
        size: 3 + _random.nextDouble() * 5,
      ));
    }
    _popController.forward(from: 0).then((_) {
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;
    final secondaryColor = widget.theme.colorScheme.secondary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Party popper shape button
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
              onTap: _triggerPop,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.celebration_outlined,
                      color: widget.theme.colorScheme.onPrimary,
                      size: 24,
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
        // Particles
        AnimatedBuilder(
          animation: _popController,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                progress: _popController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

class Particle {
  final Color color;
  final double angle;
  final double speed;
  final double size;

  Particle({
    required this.color,
    required this.angle,
    required this.speed,
    required this.size,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final distance = particle.speed * progress;
      final x = size.width / 2 + cos(particle.angle) * distance;
      final y = size.height / 2 + sin(particle.angle) * distance - (progress * progress * 500);

      final paint = Paint()
        ..color = particle.color.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

