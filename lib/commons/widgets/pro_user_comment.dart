import 'package:flutter/material.dart';
import 'package:merrymakin/commons/utils/date_time.dart';
import 'package:merrymakin/commons/widgets/pro_bottom_modal_sheet.dart';
import 'package:merrymakin/commons/widgets/pro_list_item.dart';
import '../models/comment.dart';
import 'pro_text.dart';
import 'pro_user_avatar.dart';

class ProUserComment extends StatelessWidget {
  final Comment comment;
  final bool hideNames;
  final bool canDelete;
  final Function(Comment)? onDelete;
  const ProUserComment(
      {super.key,
      required this.comment,
      this.hideNames = false,
      this.canDelete = false,
      this.onDelete = null});

  Widget buildDeleteCommentTrailingWidget(BuildContext context) {
    return IconButton(
        onPressed: () {
          openProBottomModalSheet(
              context,
              Column(
                children: [
                  ProListItem(
                    key: Key("delete-comment"),
                    leading: Icon(Icons.delete,
                        color: Theme.of(context).colorScheme.error),
                    title: ProText(
                      'Delete Comment',
                      textStyle:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    onTap: () async {
                      // Close the bottom sheet
                      Navigator.pop(context);

                      // Show confirmation dialog
                      final bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: ProText('Delete Comment'),
                            content: const ProText(
                              'Are you sure you want to delete this comment?',
                              maxLines: 2,
                            ),
                            actions: [
                              TextButton(
                                child: const ProText('Cancel'),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                child: ProText(
                                  'Delete',
                                  textStyle: TextStyle(color: Theme.of(context).colorScheme.error),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (onDelete != null) {
                                    onDelete!(comment);
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        // await deleteEvent(event.id!);
                        if (context.mounted) {
                          Navigator.pop(context); // Return to previous screen
                        }
                      }
                    },
                  ),
                ],
              ));
        },
        icon: Icon(Icons.more_horiz));
  }

  @override
  Widget build(BuildContext context) {
    final nameOfUser = hideNames ? 'Someone' : comment.user.getFirstName();
    final statusText = comment.status != null && comment.status != '' ? comment.status! : '';
    final statusTextWithSpace = statusText.isNotEmpty ? " · " : '';
    final relativeTimePassed = getRelativeTimePassed(comment.createdAt.toUtc());

    return ProListItem(
      key: Key(comment.user.email.toString() + comment.createdAt.toString()),
      leading: hideNames
          ? CircleAvatar(child: Icon(Icons.person), radius: 20)
          : ProUserAvatar(user: comment.user, radius: 20),
      trailing: canDelete ? buildDeleteCommentTrailingWidget(context) : null,
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: nameOfUser.trim() + " ",),
            TextSpan(text: statusText + statusTextWithSpace + relativeTimePassed , style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300),),
          ],
        ),
      ),
      subtitle: comment.comment.isNotEmpty ? ProText(comment.comment,
          textStyle: Theme.of(context).textTheme.bodyLarge) : null,
      swipeForEditAndDelete: false,
    );
  }
}



