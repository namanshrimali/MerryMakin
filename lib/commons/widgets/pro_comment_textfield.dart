import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/service/image_service.dart';

import '../models/user.dart';
import '../utils/constants.dart';
import 'pro_bottom_modal_sheet.dart';
import 'pro_image_picker.dart';
import 'pro_text_field.dart';
import 'pro_user_avatar.dart';

class ProUserCommentTextField extends StatefulWidget {
  final Comment? comment;
  final User user;
  final Function(Comment?) onChanged;
  final ImageService gifService;
  const ProUserCommentTextField({
    super.key,
    required this.comment,
    required this.user,
    required this.onChanged,
    required this.gifService,
  });

  @override
  State<ProUserCommentTextField> createState() =>
      _ProUserCommentTextFieldState();
}

class _ProUserCommentTextFieldState extends State<ProUserCommentTextField> {
  Comment? comment;

  @override
  void initState() {
    super.initState();
    comment = widget.comment;
  }

  void _updateComment(String? text, String? gifUrl) {
    final commentText = text?.trim() ?? '';
    final gifUrlTrimmed = gifUrl?.trim();

    if (commentText.isNotEmpty ||
        (gifUrlTrimmed != null && gifUrlTrimmed.isNotEmpty)) {
      comment = Comment(
        comment: commentText,
        gifUrl: gifUrlTrimmed?.isNotEmpty == true ? gifUrlTrimmed : null,
        user: widget.user,
        createdAt: DateTime.now().toUtc(),
      );
    } else {
      comment = null;
    }
    widget.onChanged(comment);
  }

  Widget _buildGif() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        maxHeight: 150,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: CachedNetworkImage(
              imageUrl: comment?.gifUrl ?? '',
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                setState(() {
                  _updateComment(comment?.comment, null);
                });
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                padding: const EdgeInsets.all(4),
                minimumSize: const Size(24, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProTextField(
          label: 'Comment',
          hintText: 'Leave a comment',
          onChanged: (value) {
            _updateComment(value, comment?.gifUrl);
          },
          initialValue: comment == null ? '' : comment!.comment,
          onValidationCallback: (value) {
            final hasText = value.isNotEmpty;
            final hasGif =
                comment?.gifUrl != null && comment?.gifUrl?.isNotEmpty == true;
            if (!hasText && !hasGif) {
              return 'Please add a comment or GIF';
            }
            return null;
          },
          keyboardType: TextInputType.multiline,
          multiline: true,
          onSaved: (value) {
            _updateComment(value, comment?.gifUrl);
          },
          autofocus: true,
          prefixWidget: comment != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ProUserAvatar(user: comment!.user),
                )
              : null,
          suffixWidget: IconButton(
            icon: const Icon(Icons.gif_box),
            onPressed: () => _openGifPicker(context),
            tooltip: 'Add GIF',
          ),
        ),
        if (comment?.gifUrl != null && true == comment?.gifUrl?.isNotEmpty) ...[
          const SizedBox(height: generalAppLevelPadding),
          _buildGif(),
          
        ],
      ],
    );
  }

  void _openGifPicker(BuildContext context) {
    openProBottomModalSheet(
      context,
      SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: ProImagePicker(
              showAll: false,
              canUpload: false,
              onImageSelected: (gifUrl) {
                setState(() {
                  _updateComment(comment?.comment, gifUrl);
                });
                Navigator.pop(context);
              },
              imageService: widget.gifService)),
    );
  }
}
