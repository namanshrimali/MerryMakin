import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/utils/date_time.dart';
import 'package:merrymakin/commons/widgets/pro_bottom_modal_sheet.dart';
import 'package:merrymakin/commons/widgets/pro_list_item.dart';
import 'package:merrymakin/commons/widgets/pro_add_reply.dart';
import 'package:merrymakin/commons/widgets/pro_emoji_keyboard.dart';
import 'package:merrymakin/commons/widgets/pro_comment_delete_dialog.dart';
import 'package:merrymakin/commons/widgets/pro_comment_reaction_button.dart';
import 'package:merrymakin/commons/widgets/pro_comment_reaction_picker_overlay.dart';
import 'package:merrymakin/commons/widgets/pro_comment_gif_widget.dart';
import 'package:merrymakin/commons/widgets/pro_comment_reaction_details_sheet.dart';
import 'package:merrymakin/commons/widgets/pro_animated_reaction_pill.dart';
import 'package:merrymakin/commons/widgets/pro_user_comment_constants.dart';
import 'package:merrymakin/factory/app_factory.dart';
import '../models/comment.dart';
import '../utils/constants.dart';
import 'pro_text.dart';
import 'pro_user_avatar.dart';

/// A widget that displays a user comment with support for replies, reactions, and deletion.
///
/// This widget follows SOLID principles by:
/// - Single Responsibility: Focuses on rendering comment UI
/// - Open/Closed: Extensible through callbacks and customizable props
/// - Dependency Inversion: Uses callbacks instead of direct service dependencies
class ProUserComment extends StatefulWidget {
  final Comment comment;
  final bool hideNames;
  final bool canDelete;
  final Function(Comment)? onDelete;
  final Function(Comment, Comment)? onReply;
  final Function(Comment, String)? onReaction;
  final bool isReply;
  final int nestingLevel;
  final User?
      currentUser; // Injected dependency instead of direct AppFactory call

  const ProUserComment({
    super.key,
    required this.comment,
    this.hideNames = false,
    this.canDelete = false,
    this.onDelete,
    this.onReply,
    this.onReaction,
    this.isReply = false,
    this.nestingLevel = 0,
    this.currentUser,
  });

  @override
  State<ProUserComment> createState() => _ProUserCommentState();
}

class _ProUserCommentState extends State<ProUserComment> {
  bool _showReplies = true;
  ProCommentReactionPickerOverlay? _reactionPickerOverlay;
  final GlobalKey _reactionButtonKey = GlobalKey();
  Set<String> _previousReactionKeys = {};
  Set<String> _animatingOutReactions = {};

  @override
  void dispose() {
    _reactionPickerOverlay?.dispose();
    super.dispose();
  }

  /// Gets the current user's reaction to this comment.
  List<String>? _getCurrentUserReaction() {
    final currentUser =
        widget.currentUser ?? AppFactory().cookiesService.currentUser;
    if (currentUser == null) return null;
    return widget.comment.getUserReactions(currentUser);
  }

  /// Gets the current user from widget prop or AppFactory fallback.
  User? get _currentUser =>
      widget.currentUser ?? AppFactory().cookiesService.currentUser;

  /// Shows the delete comment options modal.
  void _showDeleteCommentModal(BuildContext context) {
    if (!widget.canDelete || widget.onDelete == null) return;

    openProBottomModalSheet(
      context,
      Column(
        children: [
          ProListItem(
            key: const Key("delete-comment"),
            isThreeLine: false,
            leading: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.error,
            ),
            title: ProText(
              ProUserCommentConstants.deleteCommentTitle,
              textStyle: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              await _handleDeleteConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  /// Handles the delete confirmation dialog.
  Future<void> _handleDeleteConfirmation(BuildContext context) async {
    final confirmed = await ProCommentDeleteDialog.show(
      context,
      comment: widget.comment,
      onConfirm: () {
        if (widget.onDelete != null) {
          widget.onDelete!(widget.comment);
        }
      },
    );

    if (confirmed == true && context.mounted) {
      Navigator.pop(context);
    }
  }

  /// Creates or gets the reaction picker overlay instance.
  ProCommentReactionPickerOverlay _getReactionPickerOverlay() {
    _reactionPickerOverlay ??= ProCommentReactionPickerOverlay(
      reactionButtonKey: _reactionButtonKey,
      currentUserReaction: _getCurrentUserReaction(),
      onReactionSelected: _handleReactionSelected,
      onShowEmojiKeyboard: () => _showEmojiKeyboard(context),
      onClose: () {},
    );
    return _reactionPickerOverlay!;
  }

  /// Shows the floating reaction picker overlay.
  void _showFloatingReactionPicker(BuildContext context) {
    if (widget.onReaction == null) return;

    final overlay = _getReactionPickerOverlay();
    overlay.currentUserReaction = _getCurrentUserReaction();
    overlay.show(context);
  }

  /// Handles reaction selection from the picker.
  void _handleReactionSelected(String emoji) {
    if (widget.onReaction != null) {
      widget.onReaction!(widget.comment, emoji);
    }
  }

  /// Shows the emoji keyboard modal.
  void _showEmojiKeyboard(BuildContext context) {
    if (widget.onReaction == null) return;

    final currentUserReaction = _getCurrentUserReaction();

    HapticFeedback.mediumImpact();

    openProBottomModalSheet(
      context,
      SizedBox(
        child: ProEmojiKeyboard(
          currentUserReaction: currentUserReaction,
          onEmojiSelected: (emoji) {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            _handleReactionSelected(emoji);
          },
        ),
      ),
    );
  }

  /// Shows the reply modal.
  void _showReplyModal(BuildContext context) {
    final currentUser = _currentUser;
    if (currentUser == null || widget.onReply == null) return;

    openProBottomModalSheet(
      context,
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: ProAddReply(
          parentComment: widget.comment,
          user: currentUser,
          onUpdate: (reply) {
            if (widget.onReply != null) {
              widget.onReply!(widget.comment, reply);
            }
          },
        ),
      ),
    );
  }

  /// Shows the reaction details modal sheet.
  /// Similar to WhatsApp - displays tabs for each reaction type with user lists.
  void _showReactionDetailsSheet(BuildContext context, {String? emoji}) {
    if (widget.comment.reactions.isEmpty) return;

    HapticFeedback.lightImpact();

    openProBottomModalSheet(
      context,
      ProCommentReactionDetailsSheet(
        comment: widget.comment,
        currentUser: _currentUser,
        onReaction: widget.onReaction,
        selectedEmoji: emoji,
      ),
    );
  }

  /// Builds the reaction button widget.
  Widget _buildReactionButton() {
    if (widget.onReaction == null) {
      return const SizedBox.shrink();
    }

    return ProCommentReactionButton(
      key: _reactionButtonKey,
      comment: widget.comment,
      currentUser: _currentUser,
      onTap: () => _showFloatingReactionPicker(context),
    );
  }

  /// Builds individual reaction pill widgets as a list.
  List<Widget> _buildReactionPills() {
    final currentReactionKeys = widget.comment.reactions.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => e.key)
        .toSet();
    
    // Detect removed reactions (reactions that went from non-empty to empty)
    // and add them to animating out set
    final removedReactions = _previousReactionKeys.difference(currentReactionKeys);
    for (final emoji in removedReactions) {
      if (!_animatingOutReactions.contains(emoji)) {
        _animatingOutReactions.add(emoji);
        // Remove after animation duration
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _animatingOutReactions.remove(emoji);
            });
          }
        });
      }
    }
    
    // Remove reactions that came back from animating out set (count > 0 again)
    _animatingOutReactions.removeAll(currentReactionKeys);
    
    // Update previous reaction keys for next build
    _previousReactionKeys = currentReactionKeys;

    // Build allReactions preserving order from comment.reactions
    // This includes reactions with empty lists (count 0) in their original position
    final allReactions = <String, List<User>>{};
    for (final entry in widget.comment.reactions.entries) {
      allReactions[entry.key] = entry.value;
    }
    
    // Add any animating out reactions that aren't in comment.reactions yet
    // (for backward compatibility with old data that might have removed them)
    for (final emoji in _animatingOutReactions) {
      if (!allReactions.containsKey(emoji)) {
        // This shouldn't happen with the new logic, but handle it gracefully
        allReactions[emoji] = [];
      }
    }

    if (allReactions.isEmpty) {
      return [];
    }

    // Build widgets preserving the order from allReactions
    // Show reactions with count > 0 or reactions that are animating out (count 0)
    return allReactions.entries
        .where((entry) => entry.value.isNotEmpty || _animatingOutReactions.contains(entry.key))
        .map((entry) {
          final emoji = entry.key;
          final List<User> users = entry.value;
          final count = users.length;
          final hasCurrentUser = _currentUser != null &&
              widget.comment.hasUserReaction(_currentUser!, emoji);
          final isAnimatingOut = _animatingOutReactions.contains(emoji);

          return ProAnimatedReactionPill(
            key: ValueKey('reaction-pill-$emoji-${widget.comment.id}'),
            pillKey: ValueKey('reaction-pill-$emoji-${widget.comment.id}'),
            emoji: emoji,
            count: count,
            isSelected: hasCurrentUser && !isAnimatingOut,
            onTap: () {
              // Show reaction details sheet when pill is tapped
              _showReactionDetailsSheet(context, emoji: emoji);
            },
          );
        }).toList();
  }

  /// Builds the replies section.
  Widget _buildReplySection() {
    if (widget.comment.replies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        top: generalAppLevelPadding / 2,
      ),
      child: Column(
        children: widget.comment.replies.map((reply) {
          return ProUserComment(
            comment: reply,
            hideNames: widget.hideNames,
            canDelete: widget.canDelete,
            onDelete: widget.onDelete,
      
            onReaction: widget.onReaction,
            isReply: true,
            nestingLevel: widget.nestingLevel + 1,
            currentUser: _currentUser,
          );
        }).toList(),
      ),
    );
  }

  /// Builds the reply button and toggle widget.
  Widget _buildReplyButton(bool hasReplies, int replyCount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onReply != null)
          GestureDetector(
            onTap: () => _showReplyModal(context),
            child: ProText(
              ProUserCommentConstants.replyButtonText,
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReplyToggle(int replyCount) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showReplies = !_showReplies;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _showReplies ? Icons.expand_less : Icons.expand_more,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          ProText(
            '${_showReplies ? 'Hide' : 'Show'} $replyCount ${replyCount == 1 ? ProUserCommentConstants.replyText : ProUserCommentConstants.repliesText}',
            textStyle: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the comment subtitle (text and/or GIF).
  Widget? _buildSubtitle(BuildContext context) {
    final hasText = widget.comment.comment.isNotEmpty;
    final hasGif =
        widget.comment.gifUrl != null && widget.comment.gifUrl!.isNotEmpty;

    if (!hasText && !hasGif) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasText)
          ProText(
            widget.comment.comment,
            textStyle: Theme.of(context).textTheme.bodyLarge,
          ),
        if (hasGif) ProCommentGifWidget(gifUrl: widget.comment.gifUrl!),
      ],
    );
  }

  /// Builds the comment header title with user name, status, and timestamp.
  Widget _buildCommentTitle(BuildContext context) {
    final nameOfUser = widget.hideNames
        ? ProUserCommentConstants.anonymousUserName
        : widget.comment.user.getFirstName();
    final statusText =
        widget.comment.status != null && widget.comment.status!.isNotEmpty
            ? widget.comment.status!
            : '';
    final statusSeparator =
        statusText.isNotEmpty ? ProUserCommentConstants.statusSeparator : '';
    final relativeTimePassed =
        getRelativeTimePassed(widget.comment.createdAt.toUtc());

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: nameOfUser.trim() + " "),
          TextSpan(
            text: statusText + statusSeparator + relativeTimePassed,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }

  /// Builds the comment avatar.
  Widget _buildCommentAvatar() {
    if (widget.hideNames) {
      return const CircleAvatar(
        child: Icon(Icons.person),
        radius: ProUserCommentConstants.avatarRadius,
      );
    }
    return ProUserAvatar(
      user: widget.comment.user,
      radius: ProUserCommentConstants.avatarRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasReplies = widget.comment.replies.isNotEmpty;
    final replyCount = widget.comment.replies.length;

    return Container(
      margin: EdgeInsets.only(
        bottom: generalAppLevelPadding / 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProListItem(
            key: Key(
              widget.comment.user.email.toString() +
                  widget.comment.createdAt.toString(),
            ),
            listTitleAlignment: ListTileTitleAlignment.top,
            leading: _buildCommentAvatar(),
            onLongPress: widget.canDelete
                ? () => _showDeleteCommentModal(context)
                : null,
            title: _buildCommentTitle(context),
            subtitle: _buildSubtitle(context),
            swipeForEditAndDelete: false,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: ProUserCommentConstants.contentLeftPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: generalAppLevelPadding / 2,
                  runSpacing: generalAppLevelPadding / 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ..._buildReactionPills(),
                    _buildReactionButton(),
                    if (widget.onReply != null && !widget.isReply)
                      _buildReplyButton(hasReplies, replyCount),
                  ],
                ),
                if (_showReplies) _buildReplySection(),
                if (hasReplies) ...[
                  const SizedBox(height: generalAppLevelPadding / 2),
                  _buildReplyToggle(replyCount)
                ],
              ],
            ),
          ),
          
        ],
      ),
    );
  }
}
