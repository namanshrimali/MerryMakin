import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/widgets/pro_comment_textfield.dart';
import 'package:merrymakin/factory/app_factory.dart';
import '../models/comment.dart';
import '../utils/constants.dart';
import '../widgets/buttons/pro_primary_button.dart';
import 'pro_text.dart';

class ProAddReply extends StatefulWidget {
  final Comment parentComment;
  final User user;
  final Function(Comment) onUpdate;

  const ProAddReply({
    super.key,
    required this.parentComment,
    required this.user,
    required this.onUpdate,
  });

  @override
  State<ProAddReply> createState() => _ProAddReplyState();
}

class _ProAddReplyState extends State<ProAddReply> {
  Comment? reply;
  final _formKey = GlobalKey<FormState>();

  void _submitData(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (reply != null) {
        widget.onUpdate(reply!);
        Navigator.pop(context, reply);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: generalAppLevelPadding),
            child: ProText(
              'Replying to @${widget.parentComment.user.getFirstName()}',
              textStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ProUserCommentTextField(
            comment: reply,
            user: widget.user,
            label: 'Reply',
            hintText: 'Write a reply...',
            onChanged: (String? value, String? gifUrl) {
              reply = Comment(
                comment: value ?? '',
                gifUrl: gifUrl,
                user: AppFactory().cookiesService.currentUser!,
                createdAt: DateTime.now().toUtc(),
                parentCommentId: widget.parentComment.id,
              );
            },
            gifService: AppFactory().gifService,
          ),
          const SizedBox(height: generalAppLevelPadding),
          ProPrimaryButton(
            ProText("Post Reply"),
            isBig: true,
            onPressed: () => _submitData(context),
          ),
        ],
      ),
    );
  }
}

