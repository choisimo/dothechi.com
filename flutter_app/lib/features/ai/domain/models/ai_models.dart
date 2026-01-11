import 'package:json_annotation/json_annotation.dart';

part 'ai_models.g.dart';

/// 추천 게시물 DTO
@JsonSerializable()
class RecommendedPost {
  final int id;
  final String title;
  final String content;
  final String? excerpt;
  final String category;
  final int authorId;
  final String authorName;
  final int viewCount;
  final int likeCount;
  final DateTime createdAt;
  final bool isRecommended;
  final double recommendationScore;
  final String? recommendationReason;

  const RecommendedPost({
    required this.id,
    required this.title,
    required this.content,
    this.excerpt,
    required this.category,
    required this.authorId,
    required this.authorName,
    required this.viewCount,
    required this.likeCount,
    required this.createdAt,
    this.isRecommended = true,
    required this.recommendationScore,
    this.recommendationReason,
  });

  factory RecommendedPost.fromJson(Map<String, dynamic> json) =>
      _$RecommendedPostFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendedPostToJson(this);
}

/// 유사 게시물 DTO
@JsonSerializable()
class SimilarPost {
  final int id;
  final String title;
  final String excerpt;
  final double similarity;

  const SimilarPost({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.similarity,
  });

  factory SimilarPost.fromJson(Map<String, dynamic> json) =>
      _$SimilarPostFromJson(json);
  Map<String, dynamic> toJson() => _$SimilarPostToJson(this);
}

/// 트렌딩 토픽 DTO
@JsonSerializable()
class TrendingTopic {
  final String topic;
  final int count;
  final double growth;
  final String? description;

  const TrendingTopic({
    required this.topic,
    required this.count,
    required this.growth,
    this.description,
  });

  factory TrendingTopic.fromJson(Map<String, dynamic> json) =>
      _$TrendingTopicFromJson(json);
  Map<String, dynamic> toJson() => _$TrendingTopicToJson(this);
}

/// 사용자 상호작용 DTO
@JsonSerializable()
class UserInteraction {
  final int userId;
  final int postId;
  final String action; // 'view', 'like', 'comment', 'share'
  final String? category;
  final List<String>? tags;
  final DateTime? timestamp;

  const UserInteraction({
    required this.userId,
    required this.postId,
    required this.action,
    this.category,
    this.tags,
    this.timestamp,
  });

  factory UserInteraction.fromJson(Map<String, dynamic> json) =>
      _$UserInteractionFromJson(json);
  Map<String, dynamic> toJson() => _$UserInteractionToJson(this);
}

/// AI 검색 응답 DTO
@JsonSerializable()
class AISearchResponse {
  final List<AISearchPost> posts;
  final List<String> relatedTopics;
  final List<String> suggestedQueries;
  final int totalCount;

  const AISearchResponse({
    required this.posts,
    required this.relatedTopics,
    required this.suggestedQueries,
    required this.totalCount,
  });

  factory AISearchResponse.fromJson(Map<String, dynamic> json) =>
      _$AISearchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AISearchResponseToJson(this);
}

/// AI 검색 결과 게시물 DTO
@JsonSerializable()
class AISearchPost {
  final int id;
  final String title;
  final String content;
  final String? excerpt;
  final String category;
  final String authorName;
  final int viewCount;
  final int likeCount;
  final DateTime createdAt;

  const AISearchPost({
    required this.id,
    required this.title,
    required this.content,
    this.excerpt,
    required this.category,
    required this.authorName,
    required this.viewCount,
    required this.likeCount,
    required this.createdAt,
  });

  factory AISearchPost.fromJson(Map<String, dynamic> json) =>
      _$AISearchPostFromJson(json);
  Map<String, dynamic> toJson() => _$AISearchPostToJson(this);
}
