import 'package:json_annotation/json_annotation.dart';
import '../../../auth/domain/models/user.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  final int id;
  final String title;
  final String content;
  final String? excerpt;
  final User author;
  final String category;
  final List<String> tags;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Post({
    required this.id,
    required this.title,
    required this.content,
    this.excerpt,
    required this.author,
    required this.category,
    required this.tags,
    required this.viewCount,
    required this.likeCount,
    this.commentCount = 0,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);

  Post copyWith({
    int? id,
    String? title,
    String? content,
    String? excerpt,
    User? author,
    String? category,
    List<String>? tags,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      author: author ?? this.author,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
