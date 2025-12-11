import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/widgets/pro_pill.dart';

/// A button widget for reacting to comments.
class ProCommentReactionButton extends StatefulWidget {
  final Comment comment;
  final User? currentUser;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ProCommentReactionButton({
    super.key,
    required this.comment,
    this.currentUser,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<ProCommentReactionButton> createState() =>
      _ProCommentReactionButtonState();
}

class _ProCommentReactionButtonState
    extends State<ProCommentReactionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown() {
    HapticFeedback.lightImpact();
    _controller.forward();
  }

  void _handleTapUp() {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
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
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Icon(
                  Icons.add_reaction,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              isSelected: true,
              onSelected: widget.onTap, // Handled by GestureDetector
            ),
          ),
        );
      },
    );
  }
}
