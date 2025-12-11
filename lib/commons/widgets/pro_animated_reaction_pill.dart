import 'package:flutter/material.dart';
import 'package:merrymakin/commons/widgets/pro_pill.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';

/// An animated wrapper for reaction pills that provides pop-in/pop-out animations.
class ProAnimatedReactionPill extends StatefulWidget {
  final String emoji;
  final int count;
  final bool isSelected;
  final VoidCallback? onTap;
  final Key? pillKey; // Used to track when pills are added/removed

  const ProAnimatedReactionPill({
    super.key,
    required this.emoji,
    required this.count,
    required this.isSelected,
    this.onTap,
    this.pillKey,
  });

  @override
  State<ProAnimatedReactionPill> createState() =>
      _ProAnimatedReactionPillState();
}

class _ProAnimatedReactionPillState extends State<ProAnimatedReactionPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isAnimatingOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Pop-in animation with bounce effect
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    // Slight rotation for more dynamic effect
    _rotationAnimation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Start animation immediately when widget appears
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProAnimatedReactionPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if pill is being removed (count becomes 0)
    if (widget.count == 0 && oldWidget.count > 0 && !_isAnimatingOut) {
      _isAnimatingOut = true;
      // Animate out (scale down and fade)
      _controller.reverse().then((_) {
        // Animation complete, widget will be removed
      });
    } else if (widget.count > 0 && oldWidget.count == 0) {
      // Pill is being added back
      _isAnimatingOut = false;
      _controller.forward();
    } else if (widget.pillKey != oldWidget.pillKey) {
      // New pill with different key - animate in
      if (_controller.status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: ProPill(
              key: widget.pillKey,
              label: ProText(
                widget.emoji,
                textStyle: const TextStyle(fontSize: 16),
              ),
              count: widget.count,
              isSelected: widget.isSelected,
              onSelected: widget.onTap,
            ),
          ),
        );
      },
    );
  }
}
