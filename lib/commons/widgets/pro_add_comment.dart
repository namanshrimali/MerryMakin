import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/widgets/pro_comment_textfield.dart';
import 'package:merrymakin/factory/app_factory.dart';
import '../models/comment.dart';
import '../utils/constants.dart';
import '../widgets/buttons/pro_primary_button.dart';
import '../widgets/pro_text.dart';

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
      if (comment != null) {
        widget.onUpdate(comment!);
        Navigator.pop(context, comment);
      }
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ProUserCommentTextField(
                comment: comment,
                user: widget.user!,
                onChanged: (Comment? value) {
                  comment = value;
                },
                gifService: AppFactory().gifService),
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
