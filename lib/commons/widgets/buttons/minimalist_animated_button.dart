import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MinimalistAnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;
  final AnimationController? bounceController;

  const MinimalistAnimatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
    this.bounceController,
  });

  @override
  State<MinimalistAnimatedButton> createState() => _MinimalistAnimatedButtonState();
}

class _MinimalistAnimatedButtonState extends State<MinimalistAnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _minimalController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _minimalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _minimalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _minimalController,
      builder: (context, child) {
        final progress = _minimalController.value;
        final underlineWidth = progress * MediaQuery.of(context).size.width * 0.6;

        return GestureDetector(
          onTapDown: (_) => _minimalController.forward(),
          onTapUp: (_) {
            _minimalController.reverse();
            widget.onPressed();
          },
          onTapCancel: () => _minimalController.reverse(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.text,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.translationValues(progress * 8, 0, 0),
                      child: Icon(
                        Icons.arrow_forward,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: underlineWidth,
                  height: 2,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(1),
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

