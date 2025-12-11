import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merrymakin/commons/widgets/pro_user_comment_constants.dart';

/// A floating reaction picker widget that displays emoji reactions.
class ProCommentReactionPicker extends StatelessWidget {
  final List<String> availableReactions;
  final List<String>? currentUserReaction;
  final Function(String emoji) onReactionSelected;
  final VoidCallback onShowEmojiKeyboard;

  const ProCommentReactionPicker({
    super.key,
    this.availableReactions = ProUserCommentConstants.defaultReactions,
    this.currentUserReaction = const [],
    required this.onReactionSelected,
    required this.onShowEmojiKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: ProUserCommentConstants.reactionPickerWidth,
        height: ProUserCommentConstants.reactionPickerHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...availableReactions.map((emoji) {
              final isSelected = currentUserReaction?.contains(emoji) ?? false;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onReactionSelected(emoji);
                },
                child: AnimatedContainer(
                  duration: ProUserCommentConstants.reactionAnimationDuration,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 28,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ),
              );
            }),
            Container(
              width: 1,
              height: 40,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onShowEmojiKeyboard();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.add,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
