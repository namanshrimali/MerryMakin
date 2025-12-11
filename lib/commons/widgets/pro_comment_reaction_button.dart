import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/widgets/pro_pill.dart';

/// A button widget for reacting to comments.
class ProCommentReactionButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ProPill(
      label: Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Icon(Icons.add_reaction, size: 16)),
      isSelected: true,
      onSelected: onTap,
    );
  }
}
