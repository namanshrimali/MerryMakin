import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merrymakin/commons/widgets/pro_comment_reaction_picker.dart';
import 'package:merrymakin/commons/widgets/pro_user_comment_constants.dart';

/// Animated overlay content for the reaction picker
class _ReactionPickerOverlayContent extends StatefulWidget {
  final double pickerLeft;
  final double pickerTop;
  final List<String> availableReactions;
  final List<String> currentUserReaction;
  final Function(String emoji) onReactionSelected;
  final VoidCallback onShowEmojiKeyboard;
  final VoidCallback onDismiss;

  const _ReactionPickerOverlayContent({
    required this.pickerLeft,
    required this.pickerTop,
    required this.availableReactions,
    required this.currentUserReaction,
    required this.onReactionSelected,
    required this.onShowEmojiKeyboard,
    required this.onDismiss,
  });

  @override
  State<_ReactionPickerOverlayContent> createState() =>
      _ReactionPickerOverlayContentState();
}

class _ReactionPickerOverlayContentState
    extends State<_ReactionPickerOverlayContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismiss,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),
        ),
        Positioned(
          left: widget.pickerLeft,
          top: widget.pickerTop,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ProCommentReactionPicker(
                  availableReactions: widget.availableReactions,
                  currentUserReaction: widget.currentUserReaction,
                  onReactionSelected: (emoji) {
                    _dismiss();
                    widget.onReactionSelected(emoji);
                  },
                  onShowEmojiKeyboard: () {
                    _dismiss();
                    widget.onShowEmojiKeyboard();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Manages the overlay for the floating reaction picker.
class ProCommentReactionPickerOverlay {
  OverlayEntry? _overlayEntry;
  final GlobalKey reactionButtonKey;
  final List<String> availableReactions;
  List<String>? currentUserReaction;
  final Function(String emoji) onReactionSelected;
  final VoidCallback onShowEmojiKeyboard;
  final VoidCallback onClose;

  ProCommentReactionPickerOverlay({
    required this.reactionButtonKey,
    this.availableReactions = ProUserCommentConstants.defaultReactions,
    this.currentUserReaction,
    required this.onReactionSelected,
    required this.onShowEmojiKeyboard,
    required this.onClose,
  });

  /// Shows the reaction picker overlay.
  void show(BuildContext context) {
    remove();

    final RenderBox? renderBox =
        reactionButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final edgePadding = ProUserCommentConstants.reactionPickerEdgePadding * 2;
    final maxWidth = screenWidth - edgePadding;
    final pickerWidth = ProUserCommentConstants.reactionPickerWidth.clamp(
      200.0,
      maxWidth,
    );
    final pickerHeight = ProUserCommentConstants.reactionPickerHeight;
    final pickerLeft = position.dx + (size.width / 2) - (pickerWidth / 2);
    final pickerTop =
        position.dy - pickerHeight - ProUserCommentConstants.reactionPickerOffset;

    HapticFeedback.mediumImpact();

    _overlayEntry = OverlayEntry(
      builder: (context) => _ReactionPickerOverlayContent(
        pickerLeft: pickerLeft.clamp(
          ProUserCommentConstants.reactionPickerEdgePadding,
          screenWidth - pickerWidth - ProUserCommentConstants.reactionPickerEdgePadding,
        ),
        pickerTop: pickerTop.clamp(
          ProUserCommentConstants.reactionPickerEdgePadding,
          screenHeight - pickerHeight - ProUserCommentConstants.reactionPickerEdgePadding,
        ),
        availableReactions: availableReactions,
        currentUserReaction: currentUserReaction ?? [],
        onReactionSelected: (emoji) {
          remove();
          onReactionSelected(emoji);
        },
        onShowEmojiKeyboard: () {
          remove();
          onShowEmojiKeyboard();
        },
        onDismiss: remove,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto-close after duration
    Future.delayed(ProUserCommentConstants.reactionPickerAutoCloseDuration, () {
      remove();
    });
  }

  /// Removes the overlay if it exists.
  void remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Disposes the overlay manager.
  void dispose() {
    remove();
  }
}
