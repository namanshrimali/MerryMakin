import 'package:merrymakin/commons/models/user.dart';

class Comment {
  final String? id;
  final String comment;
  final String? status;
  final User user;
  final DateTime createdAt;
  final List<Comment> replies;
  final bool isReply;

  Comment({
    this.id,
    required this.comment,
    this.status,
    required this.user,
    required this.createdAt,
    this.isReply = false,
    this.replies = const [],
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      comment: map['comment'],
      status: map['status'],
      user: User.fromMap(map['user']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'comment': comment,
      'status': status,
      'user': user.toMap(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
