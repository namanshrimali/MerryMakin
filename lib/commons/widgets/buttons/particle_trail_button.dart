import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParticleTrailButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;

  const ParticleTrailButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
  });

  @override
  State<ParticleTrailButton> createState() => _ParticleTrailButtonState();
}

class _ParticleTrailButtonState extends State<ParticleTrailButton>
    with TickerProviderStateMixin {
  final List<TrailParticle> _particles = [];
  final Random _random = Random();
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();
    _particleController.addListener(_updateParticles);
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _addParticle(Offset position) {
    setState(() {
      _particles.add(TrailParticle(
        position: position,
        color: widget.theme.colorScheme.primary,
        life: 1.0,
      ));
    });
  }

  void _updateParticles() {
    setState(() {
      _particles.removeWhere((p) {
        p.life -= 0.1;
        return p.life <= 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;
    final secondaryColor = widget.theme.colorScheme.secondary;

    return GestureDetector(
      onPanUpdate: (details) {
        _addParticle(details.localPosition);
        _updateParticles();
      },
      onPanEnd: (_) {
        Future.delayed(const Duration(milliseconds: 50), _updateParticles);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
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
          // Particle trail - only render if particles exist
          if (_particles.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: TrailPainter(particles: _particles),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TrailParticle {
  Offset position;
  Color color;
  double life;

  TrailParticle({
    required this.position,
    required this.color,
    required this.life,
  });
}

class TrailPainter extends CustomPainter {
  final List<TrailParticle> particles;

  TrailPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.life * 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, 3 * particle.life, paint);
    }
  }

  @override
  bool shouldRepaint(covariant TrailPainter oldDelegate) {
    return oldDelegate.particles.length != particles.length;
  }
}

