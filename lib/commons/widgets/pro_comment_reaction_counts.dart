import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/pro_pill.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';

/// Widget that displays reaction counts as chips.
class ProCommentReactionCounts extends StatelessWidget {
  final Comment comment;
  final User? currentUser;
  final Function(String emoji)? onReactionTap;

  const ProCommentReactionCounts({
    super.key,
    required this.comment,
    this.currentUser,
    this.onReactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (comment.reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: comment.reactions.entries.map((entry) {
        final emoji = entry.key;
        final List<User> users = entry.value;
        final count = users.length;
        final hasCurrentUser = currentUser != null &&
            comment.hasUserReaction(currentUser!, emoji);
    
        return ProPill(
          onSelected: onReactionTap != null ? () => onReactionTap!(emoji) : null,
          label: ProText(emoji, textStyle: const TextStyle(fontSize: 16)),
          count: count,
          isSelected: hasCurrentUser,
        );
      }).toList(),
    );
  }
}
