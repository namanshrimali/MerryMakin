/// Constants used in the ProUserComment widget
class ProUserCommentConstants {
  ProUserCommentConstants._();

  // Layout constants
  static const double nestingIndent = 24.0;
  static const double avatarRadius = 20.0;
  static const double replyAvatarRadius = 15.0;
  static const double contentLeftPadding = 55.0;
  static const double replyBorderWidth = 2.0;

  // GIF widget constants
  static const double gifMaxWidth = 300.0;
  static const double gifMaxHeight = 200.0;
  static const double gifPlaceholderWidth = 300.0;
  static const double gifPlaceholderHeight = 200.0;

  // Reaction picker constants
  static const double reactionPickerWidth = 320.0;
  static const double reactionPickerHeight = 60.0;
  static const double reactionPickerOffset = 12.0;
  static const double reactionPickerEdgePadding = 8.0;
  static const Duration reactionPickerAutoCloseDuration = Duration(seconds: 3);
  static const Duration reactionAnimationDuration = Duration(milliseconds: 150);

  // Default available reactions
  static const List<String> defaultReactions = [
    '👍',
    '❤️',
    '😂',
    '😮',
    '😢',
    '🙏',
  ];

  // Text constants
  static const String deleteCommentTitle = 'Delete Comment';
  static const String deleteCommentConfirmation =
      'Are you sure you want to delete this comment?';
  static const String cancelButtonText = 'Cancel';
  static const String deleteButtonText = 'Delete';
  static const String replyButtonText = 'Reply';
  static const String repliesText = 'replies';
  static const String replyText = 'reply';
  static const String anonymousUserName = 'Someone';
  static const String statusSeparator = ' · ';
}
