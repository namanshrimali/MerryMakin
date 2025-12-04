import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShakeToRevealButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;

  const ShakeToRevealButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
  });

  @override
  State<ShakeToRevealButton> createState() => _ShakeToRevealButtonState();
}

class _ShakeToRevealButtonState extends State<ShakeToRevealButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0).then((_) {
      setState(() => _isRevealed = true);
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onPressed();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;
    final secondaryColor = widget.theme.colorScheme.secondary;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shakeValue = _shakeController.value;
        final offsetX = math.sin(shakeValue * 10 * 3.14159) * 10;

        return Transform.translate(
          offset: Offset(offsetX, 0),
          child: Opacity(
            opacity: _isRevealed ? 1.0 : 0.7 + (shakeValue * 0.3),
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
                  onTap: _triggerShake,
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
                          _isRevealed ? widget.text : '???',
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

