import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/widgets/pro_user_avatar.dart';
import '../models/comment.dart';
import '../utils/constants.dart';
import '../widgets/buttons/pro_primary_button.dart';
import '../widgets/pro_text.dart';
import 'pro_text_field.dart';

class ProAddComment extends StatefulWidget {
  final Function(Comment) onUpdate;
  final User? user;
  const ProAddComment({super.key, required this.onUpdate, required this.user});

  @override
  State<ProAddComment> createState() => _ProAddCommentState();
}

class _ProAddCommentState extends State<ProAddComment> {
  Comment? comment;
  final _formKey = GlobalKey<FormState>();

  void _submitData(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onUpdate(comment!);
      Navigator.pop(context, comment);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return const ProText('Please login to comment');
    }
    return Form(
      key: _formKey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ProTextField(
              label: 'Comment',
              hintText: 'Leave a comment',
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  comment = Comment(
                    comment: value,
                    user: widget.user!,
                    createdAt: DateTime.now().toUtc());
                }
              },
              initialValue: comment == null ? '' : comment!.comment,
              onValidationCallback: (value) {
                if (value.isEmpty) {
                  return 'Comment cannot be empty';
                }
                return null;
              },
              keyboardType: TextInputType.multiline,
              onSaved: (value) {
                if (value != null && value.isNotEmpty) { 
                  comment = Comment(
                    comment: value,
                    user: widget.user!,
                    createdAt: DateTime.now().toUtc());
                }
              },
              autofocus: true,
              prefixWidget: ProUserAvatar(user: widget.user!),
            ),
            const SizedBox(
              height: generalAppLevelPadding,
            ),
            ProPrimaryButton(
              ProText("Post"),
              isBig: true,
              onPressed: () => _submitData(context),
            ),
          ]),
    );
  }
}
