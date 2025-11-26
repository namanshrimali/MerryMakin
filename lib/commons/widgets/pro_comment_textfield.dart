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
  final User? user;
  final Function(String?, String?) onChanged;
  final ImageService gifService;
  const ProUserCommentTextField({
    super.key,
    this.comment,
    this.user,
    required this.onChanged,
    required this.gifService,
  });

  @override
  State<ProUserCommentTextField> createState() =>
      _ProUserCommentTextFieldState();
}

class _ProUserCommentTextFieldState extends State<ProUserCommentTextField> {
  String? commentText;
  String? gifUrl;

  @override
  void initState() {
    super.initState();
    commentText = widget.comment?.comment;
    gifUrl = widget.comment?.gifUrl;
  }

  void _updateComment(String? text, String? selectedGifUrl) {
    final commentTextTrimmed = text?.trim() ?? '';
    final gifUrlTrimmed = selectedGifUrl?.trim();

    setState(() {
        commentText = commentTextTrimmed;
        gifUrl = gifUrlTrimmed;
      });
      widget.onChanged(commentText, gifUrl);
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
              imageUrl: gifUrl ?? '',
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
                  _updateComment(commentText, null);
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
            _updateComment(value, gifUrl);
          },
          initialValue: commentText == null ? '' : commentText,
          onValidationCallback: (value) {
            final hasText = value.isNotEmpty;
            final hasGif =
                gifUrl != null && gifUrl?.isNotEmpty == true;
            if (!hasText && !hasGif) {
              return 'Please add a comment or GIF';
            }
            return null;
          },
          keyboardType: TextInputType.multiline,
          multiline: true,
          onSaved: (value) {
            _updateComment(value, gifUrl);
          },
          autofocus: true,
          prefixWidget: widget.user != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ProUserAvatar(user: widget.user!),
                )
              : null,
          suffixWidget: IconButton(
            icon: const Icon(Icons.gif_box),
            onPressed: () => _openGifPicker(context),
            tooltip: 'Add GIF',
          ),
        ),
        if (gifUrl != null && true == gifUrl?.isNotEmpty) ...[
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
              onImageSelected: (selectedGifUrl) {
                setState(() {
                  _updateComment(commentText, selectedGifUrl);
                });
                Navigator.pop(context);
              },
              imageService: widget.gifService)),
    );
  }
}
