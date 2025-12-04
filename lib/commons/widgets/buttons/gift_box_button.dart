import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GiftBoxButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;

  const GiftBoxButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
  });

  @override
  State<GiftBoxButton> createState() => _GiftBoxButtonState();
}

class _GiftBoxButtonState extends State<GiftBoxButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _unwrapController;
  bool _isUnwrapping = false;

  @override
  void initState() {
    super.initState();
    _unwrapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _unwrapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!_isUnwrapping) {
      setState(() => _isUnwrapping = true);
      _unwrapController.forward().then((_) {
        widget.onPressed();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;
    final secondaryColor = widget.theme.colorScheme.secondary;

    return AnimatedBuilder(
      animation: _unwrapController,
      builder: (context, child) {
        final unwrapProgress = _unwrapController.value;
        final scale = 1.0 - (unwrapProgress * 0.1);
        final ribbonHeight = 20.0 * (1 - unwrapProgress);

        return Transform.scale(
          scale: scale,
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
                onTap: _handleTap,
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_giftcard,
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
                    // Ribbon effect
                    if (ribbonHeight > 0)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: ribbonHeight,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

