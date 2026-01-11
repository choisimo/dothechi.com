import 'package:json_annotation/json_annotation.dart';
import '../../../auth/domain/models/user.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  final int id;
  final String content;
  final User author;
  final int postId;
  final int? parentId; // 대댓글의 경우 부모 댓글 ID
  final List<Comment> replies;
  final int likeCount;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Comment({
    required this.id,
    required this.content,
    required this.author,
    required this.postId,
    this.parentId,
    required this.replies,
    required this.likeCount,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  Comment copyWith({
    int? id,
    String? content,
    User? author,
    int? postId,
    int? parentId,
    List<Comment>? replies,
    int? likeCount,
    bool? isLiked,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      author: author ?? this.author,
      postId: postId ?? this.postId,
      parentId: parentId ?? this.parentId,
      replies: replies ?? this.replies,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
