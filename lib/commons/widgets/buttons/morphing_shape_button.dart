import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MorphingShapeButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;
  final AnimationController? bounceController;

  const MorphingShapeButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
    this.bounceController,
  });

  @override
  State<MorphingShapeButton> createState() => _MorphingShapeButtonState();
}

class _MorphingShapeButtonState extends State<MorphingShapeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _morphController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;
    final secondaryColor = widget.theme.colorScheme.secondary;

    return AnimatedBuilder(
      animation: _morphController,
      builder: (context, child) {
        final morphValue = _morphController.value;
        final borderRadius = 20.0 + (morphValue * 15); // Morphs between 20 and 35
        final padding = 20.0 - (morphValue * 4); // Morphs padding between 20 and 16

        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: Transform.scale(
            scale: _isPressed ? 0.95 : 1.0,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, secondaryColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.5),
                    blurRadius: 24,
                    spreadRadius: 2 + (morphValue * 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: padding),
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

