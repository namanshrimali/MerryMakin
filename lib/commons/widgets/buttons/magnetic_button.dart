import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MagneticButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;

  const MagneticButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
  });

  @override
  State<MagneticButton> createState() => _MagneticButtonState();
}

class _MagneticButtonState extends State<MagneticButton> {
  Offset _offset = Offset.zero;
  bool _isHovering = false;

  void _updateMagneticEffect(Offset position, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final dx = position.dx - centerX;
    final dy = position.dy - centerY;
    final distance = (dx * dx + dy * dy) / (centerX * centerX + centerY * centerY);
    final strength = (1 - distance.clamp(0.0, 1.0)) * 0.3;

    setState(() {
      _offset = Offset(dx * strength, dy * strength);
      _isHovering = distance < 0.5;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;
    final secondaryColor = widget.theme.colorScheme.secondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (details) {
            _updateMagneticEffect(
              details.localPosition,
              Size(constraints.maxWidth, constraints.maxHeight),
            );
          },
          onPanEnd: (_) {
            setState(() {
              _offset = Offset.zero;
              _isHovering = false;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0)
              ..scale(_isHovering ? 1.05 : 1.0),
            child: Container(
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
          ),
        );
      },
    );
  }
}

