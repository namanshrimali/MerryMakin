import 'package:flutter/material.dart';
import 'package:merrymakin/commons/themes/pro_themes.dart' show ProThemeType;
import 'package:merrymakin/commons/widgets/pro_theme_effects.dart'
    show ProEffectType;

import '../commons/models/comment.dart';
import '../commons/models/event.dart';
import '../commons/models/user.dart';
import '../commons/service/cookie_service.dart';
import '../commons/utils/constants.dart';
import '../commons/widgets/buttons/pro_outlined_button.dart';
import '../commons/widgets/cards/pro_card.dart';
import '../commons/widgets/pro_add_comment.dart';
import '../commons/widgets/pro_bottom_modal_sheet.dart';
import '../commons/widgets/pro_text.dart';
import '../commons/widgets/pro_user_comment.dart';
import '../factory/app_factory.dart';
import '../service/event_service.dart';

class CommentSection extends StatefulWidget {
  final Event event;
  final bool hideNames;
  final ThemeData? eventTheme;
  final ProEffectType? effectType;
  final ProThemeType themeType;
  final List<Color> gradientColors;
  const CommentSection(
      {super.key,
      required this.event,
      required this.hideNames,
      required this.eventTheme,
      required this.effectType,
      required this.themeType,
      required this.gradientColors});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  Comment? _findCommentById(List<Comment> comments, String commentId) {
    for (var comment in comments) {
      if (comment.id == commentId) {
        return comment;
      }
      if (comment.replies.isNotEmpty) {
        final found = _findCommentById(comment.replies, commentId);
        if (found != null) return found;
      }
    }
    return null;
  }

  void _updateCommentInList(List<Comment> comments, Comment updatedComment) {
    for (int i = 0; i < comments.length; i++) {
      if (comments[i].id == updatedComment.id) {
        comments[i] = updatedComment;
        return;
      }
      if (comments[i].replies.isNotEmpty) {
        _updateCommentInList(comments[i].replies, updatedComment);
      }
    }
  }

  /// Updates reactions while preserving insertion order.
  /// New emojis are appended to the end, existing emojis stay in place.
  /// When count reaches 0, the emoji is kept with empty list to preserve position for animation.
  Map<String, List<User>> _updateReactionsPreservingOrder(
    Map<String, List<User>> currentReactions,
    String emoji,
    User currentUser,
    bool isAdding,
  ) {
    // Create a new LinkedHashMap to preserve order
    final updatedReactions = <String, List<User>>{};
    
    // First, copy all existing reactions in their current order
    for (final entry in currentReactions.entries) {
      if (entry.key == emoji) {
        // Update the existing emoji's user list
        final updatedUsers = List<User>.from(entry.value);
        if (isAdding) {
          // Add user if not already present
          if (!updatedUsers.any(
            (user) => user.id == currentUser.id || user.email == currentUser.email,
          )) {
            updatedUsers.add(currentUser);
          }
        } else {
          // Remove user
          updatedUsers.removeWhere(
            (user) => user.id == currentUser.id || user.email == currentUser.email,
          );
        }
        // Keep the emoji in place even if count is 0 (empty list)
        // This allows it to animate out from its original position
        updatedReactions[emoji] = updatedUsers;
      } else {
        // Keep other reactions as-is
        updatedReactions[entry.key] = List<User>.from(entry.value);
      }
    }
    
    // If adding a new emoji (not in existing reactions), append it to the end
    if (isAdding && !currentReactions.containsKey(emoji)) {
      updatedReactions[emoji] = [currentUser];
    }
    
    return updatedReactions;
  }

  List<Widget> _buildComments(Event event, BuildContext context,
      CookiesService cookiesService, final bool hideNames) {
    event.comments?.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return event.comments
            ?.map((comment) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: generalAppLevelPadding),
                  child: ProUserComment(
                      comment: comment,
                      onDelete: (comment) {
                        deleteCommentFromEvent(event, comment, context)
                            .then((value) {
                          setState(() {
                            event.comments?.remove(comment);
                          });
                        });
                      },
                      onReply: (parentComment, reply) {
                        if (parentComment.id == null) return;
                        addReplyToComment(
                                event, parentComment.id!, reply, context)
                            .then((addedReply) {
                          if (addedReply != null) {
                            setState(() {
                              final foundComment = _findCommentById(
                                  event.comments ?? [], parentComment.id!);
                              if (foundComment != null) {
                                final updatedReplies = [
                                  ...foundComment.replies,
                                  addedReply
                                ];
                                final updatedComment = foundComment.copyWith(
                                  replies: updatedReplies,
                                );
                                _updateCommentInList(
                                    event.comments ?? [], updatedComment);
                              }
                            });
                          }
                        });
                      },
                      onReaction: (comment, emoji) {
                        if (comment.id == null) return;
                        final currentUser =
                            AppFactory().cookiesService.currentUser;
                        if (currentUser == null) return;

                        final hasReaction = comment.hasUserReaction(currentUser, emoji);

                        if (hasReaction) {
                          // Remove reaction
                          removeReactionFromComment(
                                  event, comment.id!, emoji, context)
                              .then((_) {
                            setState(() {
                              final updatedReactions = _updateReactionsPreservingOrder(
                                comment.reactions,
                                emoji,
                                currentUser,
                                false, // isAdding = false
                              );
                              final updatedComment = comment.copyWith(
                                reactions: updatedReactions,
                              );
                              _updateCommentInList(
                                  event.comments ?? [], updatedComment);
                            });
                          });
                        } else {
                          // Add reaction
                          addReactionToComment(
                                  event, comment.id!, emoji, context)
                              .then((updatedComment) {
                            if (updatedComment != null) {
                              // Server response - preserve client-side order for existing reactions, append new ones
                              setState(() {
                                final serverReactions = updatedComment.reactions;
                                final orderedReactions = <String, List<User>>{};
                                
                                // First, preserve existing reactions in their current client-side order
                                // Only include reactions that exist on server (filters out empty ones that were animating out)
                                for (final entry in comment.reactions.entries) {
                                  if (serverReactions.containsKey(entry.key) && 
                                      serverReactions[entry.key]!.isNotEmpty) {
                                    // Use server data but maintain client-side position
                                    orderedReactions[entry.key] = serverReactions[entry.key]!;
                                  }
                                }
                                
                                // Then, append any new reactions from server (new emojis at the end)
                                for (final entry in serverReactions.entries) {
                                  if (!orderedReactions.containsKey(entry.key) && entry.value.isNotEmpty) {
                                    orderedReactions[entry.key] = entry.value;
                                  }
                                }
                                
                                final orderedComment = updatedComment.copyWith(
                                  reactions: orderedReactions,
                                );
                                _updateCommentInList(
                                    event.comments ?? [], orderedComment);
                              });
                            } else {
                              // Optimistic update
                              setState(() {
                                final updatedReactions = _updateReactionsPreservingOrder(
                                  comment.reactions,
                                  emoji,
                                  currentUser,
                                  true, // isAdding = true
                                );
                                final optimisticComment = comment.copyWith(
                                  reactions: updatedReactions,
                                );
                                _updateCommentInList(
                                    event.comments ?? [], optimisticComment);
                              });
                            }
                          });
                        }
                      },
                      canDelete:
                          (cookiesService.locallyAvailableUserInfo != null &&
                                  comment.user.email ==
                                      cookiesService
                                          .locallyAvailableUserInfo!.email) ||
                              event.isHostedByMe(
                                  cookiesService.locallyAvailableUserInfo),
                      hideNames: event.isGuestListHidden || hideNames),
                ))
            .toList() ??
        [];
  }

  Widget buildCommentSection(BuildContext context,
      CookiesService cookiesService, bool isUserAuthorized) {
    return Padding(
      padding: const EdgeInsets.only(
          left: generalAppLevelPadding,
          right: generalAppLevelPadding,
          top: generalAppLevelPadding),
      child: ProCard(
          elevation: 10,
          surfaceTintColor: Colors.white.withOpacity(0.1),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ProText(
                  'Activity',
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isUserAuthorized)
                  ProOutlinedButton(
                    onPressed: () {
                      openProBottomModalSheet(
                        context,
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: ProAddComment(
                              onUpdate: (final Comment comment) {
                                if (widget.event.comments == null) {
                                  widget.event.comments = [];
                                }
                                addCommentToEvent(
                                        widget.event, comment, context)
                                    .then((comment) {
                                  if (comment != null) {
                                    setState(() {
                                      widget.event.comments!.add(comment);
                                    });
                                  }
                                });
                              },
                              user: cookiesService.locallyAvailableUserInfo),
                        ),
                        themeData: widget.eventTheme,
                        themeType: widget.themeType,
                        gradientColors: [widget.gradientColors[0]],
                      );
                    },
                    child: ProText('Comment'),
                  ),
              ],
            ),
            if (widget.event.comments != null &&
                widget.event.comments!.isNotEmpty)
              ..._buildComments(widget.event, context, cookiesService,
                  cookiesService.currentJwtToken == null),
            if (widget.event.comments == null || widget.event.comments!.isEmpty)
              SizedBox(
                  height: 200,
                  child: Center(
                      child: const ProText(
                          textStyle: TextStyle(
                            fontSize: 16,
                          ),
                          'Be the first to break the silence! 🎤'))),
            // const SizedBox(height: 200),
          ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CookiesService cookiesService = AppFactory().cookiesService;
    final User? user = AppFactory().cookiesService.currentUser;
    final isUserAuthorized = user?.isUserAuthorized() ?? false;
    return buildCommentSection(context, cookiesService, isUserAuthorized);
  }
}
