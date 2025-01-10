import 'package:flutter/material.dart';
import '../models/comment.dart';
import 'pro_text.dart';
import 'pro_user_avatar.dart';

class ProUserComment extends StatelessWidget {
  final Comment comment;
  const ProUserComment({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ProUserAvatar(user: comment.user),
      title: ProText(comment.comment),
    );
  }
}
