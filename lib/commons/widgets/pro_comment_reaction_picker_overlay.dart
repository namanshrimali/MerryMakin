import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merrymakin/commons/widgets/pro_comment_reaction_picker.dart';
import 'package:merrymakin/commons/widgets/pro_user_comment_constants.dart';

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

    final pickerWidth = ProUserCommentConstants.reactionPickerWidth;
    final pickerHeight = ProUserCommentConstants.reactionPickerHeight;
    final pickerLeft = position.dx + (size.width / 2) - (pickerWidth / 2);
    final pickerTop =
        position.dy - pickerHeight - ProUserCommentConstants.reactionPickerOffset;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    HapticFeedback.mediumImpact();

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: remove,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: pickerLeft.clamp(
              ProUserCommentConstants.reactionPickerEdgePadding,
              screenWidth - pickerWidth - ProUserCommentConstants.reactionPickerEdgePadding,
            ),
            top: pickerTop.clamp(
              ProUserCommentConstants.reactionPickerEdgePadding,
              screenHeight - pickerHeight - ProUserCommentConstants.reactionPickerEdgePadding,
            ),
            child: ProCommentReactionPicker(
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
            ),
          ),
        ],
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
