import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_user_comment_constants.dart';

/// A reusable dialog for confirming comment deletion.
class ProCommentDeleteDialog extends StatelessWidget {
  final Comment comment;
  final VoidCallback onConfirm;

  const ProCommentDeleteDialog({
    super.key,
    required this.comment,
    required this.onConfirm,
  });

  /// Shows the delete confirmation dialog.
  static Future<bool?> show(
    BuildContext context, {
    required Comment comment,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ProCommentDeleteDialog(
          comment: comment,
          onConfirm: onConfirm,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const ProText(ProUserCommentConstants.deleteCommentTitle),
      content: const ProText(
        ProUserCommentConstants.deleteCommentConfirmation,
        maxLines: 2,
      ),
      actions: [
        TextButton(
          child: const ProText(ProUserCommentConstants.cancelButtonText),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: ProText(
            ProUserCommentConstants.deleteButtonText,
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
        ),
      ],
    );
  }
}
