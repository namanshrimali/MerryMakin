import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Floating3DButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ThemeData theme;

  const Floating3DButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.theme,
  });

  @override
  State<Floating3DButton> createState() => _Floating3DButtonState();
}

class _Floating3DButtonState extends State<Floating3DButton> {
  double _tiltX = 0;
  double _tiltY = 0;
  bool _isPressed = false;

  void _updateTilt(Offset position, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    setState(() {
      _tiltX = (position.dx - centerX) / centerX * 0.1;
      _tiltY = (position.dy - centerY) / centerY * 0.1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;
    final secondaryColor = widget.theme.colorScheme.secondary;

    return GestureDetector(
      onPanUpdate: (details) {
        _updateTilt(details.localPosition, context.size!);
      },
      onPanEnd: (_) {
        setState(() {
          _tiltX = 0;
          _tiltY = 0;
        });
      },
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_tiltY)
          ..rotateY(_tiltX)
          ..translate(0.0, _isPressed ? 2.0 : 0.0),
        alignment: FractionalOffset.center,
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
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: Offset(_tiltX * 20, _tiltY * 20 + (_isPressed ? 4 : 8)),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: primaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: Offset(_tiltX * 10, _tiltY * 10),
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
  }
}

