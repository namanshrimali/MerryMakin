import 'package:flutter/material.dart';
import 'package:merrymakin/commons/utils/date_time.dart';
import 'package:merrymakin/commons/widgets/pro_list_item.dart';
import '../models/comment.dart';
import 'pro_text.dart';
import 'pro_user_avatar.dart';

class ProUserComment extends StatelessWidget {
  final Comment comment;
  final bool hideNames;
  const ProUserComment({super.key, required this.comment, this.hideNames = false});

  @override
  Widget build(BuildContext context) {
    final nameOfUser = hideNames ? 'Someone' : comment.user.getFirstName();
    
    return ProListItem(
      key: Key(comment.user.email.toString() + comment.createdAt.toString()),
      leading: hideNames? CircleAvatar(child: Icon(Icons.person))  : ProUserAvatar(user: comment.user),
      title: ProText(nameOfUser + ' ' + getRelativeTimePassed(comment.createdAt.toUtc()), maxLines: 1),
      subtitle: ProText(comment.comment, textStyle: Theme.of(context).textTheme.bodyLarge),
      swipeForEditAndDelete: false,
    );
  }
}

