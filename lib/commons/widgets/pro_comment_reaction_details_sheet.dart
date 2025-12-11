import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/widgets/pro_list_item.dart';
import 'package:merrymakin/commons/widgets/pro_tab_view.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_user_avatar.dart';
import 'package:merrymakin/commons/utils/constants.dart';

/// A bottom sheet widget that displays reaction details in a tabbed view.
/// Similar to WhatsApp's reaction viewer - shows tabs for each reaction type
/// and lists users who reacted. Tapping on your own reaction removes it.
class ProCommentReactionDetailsSheet extends StatelessWidget {
  final Comment comment;
  final User? currentUser;
  final Function(Comment, String)? onReaction; // Callback to remove reaction
  final String? selectedEmoji; // Emoji that was tapped to open this sheet

  const ProCommentReactionDetailsSheet({
    super.key,
    required this.comment,
    this.currentUser,
    this.onReaction,
    this.selectedEmoji,
  });

  /// Checks if a user is the current user
  bool _isCurrentUser(User user) {
    if (currentUser == null) return false;
    return user.id == currentUser!.id || user.email == currentUser!.email;
  }

  /// Builds a list of users for a specific reaction emoji
  Widget _buildUserListForReaction(BuildContext context, String emoji, List<User> users) {
    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: generalAppLevelPadding * 1.5,
            vertical: generalAppLevelPadding * 2,
          ),
          child: ProText(
            'No users reacted with $emoji',
            textStyle: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: generalAppLevelPadding / 2),
      itemCount: users.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        indent: generalAppLevelPadding / 2 + 22 + 16, // padding + avatar radius + spacing
        endIndent: generalAppLevelPadding / 2,
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      ),
      itemBuilder: (context, index) {
        final user = users[index];
        final isCurrentUserReaction = _isCurrentUser(user);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: generalAppLevelPadding / 2,
            vertical: generalAppLevelPadding / 3,
          ),
          child: ProListItem(
            key: Key('reaction-user-${user.email}-$emoji'),
            leading: ProUserAvatar(
              user: user,
              radius: 22,
            ),
            title: ProText(
              user.getFirstAndLastName(),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: isCurrentUserReaction ? FontWeight.w600 : FontWeight.w500,
                color: isCurrentUserReaction
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
            subtitle: isCurrentUserReaction
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ProText(
                      'Tap to remove reaction',
                      textStyle: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ),
                    ),
                  )
                : null,
            onTap: isCurrentUserReaction && onReaction != null
                ? () {
                    // Remove the current user's reaction
                    onReaction!(comment, emoji);
                    Navigator.pop(context);
                  }
                : null,
            swipeForEditAndDelete: false,
          ),
        );
      },
    );
  }

  /// Builds tabs for each reaction type
  List<Widget> _buildReactionTabs(BuildContext context) {
    final reactionEntries = comment.reactions.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    if (reactionEntries.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: generalAppLevelPadding * 1.5,
              vertical: generalAppLevelPadding * 3,
            ),
            child: ProText(
              'No reactions yet',
              textStyle: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        )
      ];
    }

    return reactionEntries.map((entry) {
      return _buildUserListForReaction(context, entry.key, entry.value);
    }).toList();
  }

  /// Builds tab titles (emoji + count)
  List<String> _buildTabTitles() {
    final reactionEntries = comment.reactions.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    return reactionEntries.map((entry) {
      final emoji = entry.key;
      final count = entry.value.length;
      return '$emoji $count';
    }).toList();
  }

  /// Finds the index of the selected emoji in the reaction entries
  int? _findSelectedEmojiIndex() {
    if (selectedEmoji == null) return null;
    
    final reactionEntries = comment.reactions.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();
    
    for (int i = 0; i < reactionEntries.length; i++) {
      if (reactionEntries[i].key == selectedEmoji) {
        return i;
      }
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tabTitles = _buildTabTitles();
    final tabChildren = _buildReactionTabs(context);
    final initialTabIndex = _findSelectedEmojiIndex();

    return ProTabView(
      children: tabChildren,
      childrenTabTitle: tabTitles,
      initialTabIndex: initialTabIndex,
    );
  }
}
