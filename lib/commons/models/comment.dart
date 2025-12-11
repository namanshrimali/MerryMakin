import 'package:merrymakin/commons/models/user.dart';

/// Represents a comment on an event with support for replies and reactions.
class Comment {
  final String? id;
  final String comment;
  final String? status;
  final String? gifUrl;
  final User user;
  final DateTime createdAt;
  final List<Comment> replies;
  final String? parentCommentId;
  final Map<String, List<User>> reactions; // emoji -> list of users who reacted with this emoji

  /// Whether this comment is a reply to another comment.
  /// Computed from [parentCommentId] for consistency.
  bool get isReply => parentCommentId != null;

  Comment({
    this.id,
    required this.comment,
    this.status,
    this.gifUrl,
    required this.user,
    required this.createdAt,
    this.replies = const [],
    this.parentCommentId,
    this.reactions = const {},
  });

  /// Creates a [Comment] from a JSON map.
  /// Handles null values and type safety for nested structures.
  factory Comment.fromMap(Map<String, dynamic> map) {
    final repliesList = map['replies'];
    final parsedReplies = repliesList is List
        ? repliesList
            .whereType<Map<String, dynamic>>()
            .map((replyMap) => Comment.fromMap(replyMap))
            .toList()
        : <Comment>[];

    final reactionsMap = map['reactions'];
    final parsedReactions = <String, List<User>>{};
    if (reactionsMap is Map) {
      reactionsMap.forEach((key, value) {
        if (value is List) {
          parsedReactions[key.toString()] = value
              .whereType<Map<String, dynamic>>()
              .map((userMap) => User.fromMap(userMap))
              .toList();
        }
      });
    }

    final userMap = map['user'];
    if (userMap == null || userMap is! Map<String, dynamic>) {
      throw ArgumentError('Comment must have a valid user map');
    }

    final createdAtStr = map['createdAt'];
    if (createdAtStr == null || createdAtStr is! String) {
      throw ArgumentError('Comment must have a valid createdAt string');
    }

    return Comment(
      id: map['id'] as String?,
      comment: (map['comment'] as String?) ?? '',
      status: map['status'] as String?,
      gifUrl: map['gifUrl'] as String?,
      user: User.fromMap(userMap),
      createdAt: DateTime.parse(createdAtStr),
      replies: parsedReplies,
      parentCommentId: map['parentCommentId'] as String?,
      reactions: parsedReactions,
    );
  }

  /// Converts this [Comment] to a JSON map.
  /// Properly serializes nested structures including reactions.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'comment': comment,
      if (status != null) 'status': status,
      if (gifUrl != null) 'gifUrl': gifUrl,
      'user': user.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'isReply': isReply,
      'replies': replies.map((reply) => reply.toMap()).toList(),
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
      'reactions': reactions.map(
        (emoji, users) => MapEntry(emoji, users.map((user) => user.toMap()).toList()),
      ),
    };
  }

  /// Creates a copy of this [Comment] with the given fields replaced.
  /// Useful for immutable updates.
  Comment copyWith({
    String? id,
    String? comment,
    String? status,
    String? gifUrl,
    User? user,
    DateTime? createdAt,
    List<Comment>? replies,
    String? parentCommentId,
    Map<String, List<User>>? reactions,
  }) {
    return Comment(
      id: id ?? this.id,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      gifUrl: gifUrl ?? this.gifUrl,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      reactions: reactions ?? this.reactions,
    );
  }

  /// Returns the total count of all reactions on this comment.
  int get totalReactionsCount {
    return reactions.values.fold<int>(0, (sum, users) => sum + users.length);
  }

  /// Checks if a user has reacted with a specific emoji.
  bool hasUserReaction(User user, String emoji) {
    final users = reactions[emoji];
    if (users == null) return false;
    return users.any((u) => u.id == user.id || u.email == user.email);
  }

  /// Gets the emojis that a user has reacted with, if any.
  List<String>? getUserReactions(User user) {
    final userReactions = <String>[];
    for (final entry in reactions.entries) {
      if (entry.value.any((u) => u.id == user.id || u.email == user.email)) {
        userReactions.add(entry.key);
      }
    }
    return userReactions;
  }
}
