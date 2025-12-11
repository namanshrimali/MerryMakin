import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/pro_user_comment_constants.dart';

/// Widget for displaying GIF images in comments.
class ProCommentGifWidget extends StatelessWidget {
  final String gifUrl;

  const ProCommentGifWidget({
    super.key,
    required this.gifUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: generalAppLevelPadding / 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(generalAppLevelPadding),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: ProUserCommentConstants.gifMaxWidth,
            maxHeight: ProUserCommentConstants.gifMaxHeight,
          ),
          child: CachedNetworkImage(
            imageUrl: gifUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => Container(
              width: ProUserCommentConstants.gifPlaceholderWidth,
              height: ProUserCommentConstants.gifPlaceholderHeight,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: ProUserCommentConstants.gifPlaceholderWidth,
              height: ProUserCommentConstants.gifPlaceholderHeight,
              color: Colors.grey[200],
              child: const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
}
