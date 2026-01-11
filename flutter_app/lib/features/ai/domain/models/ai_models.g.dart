// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendedPost _$RecommendedPostFromJson(Map<String, dynamic> json) =>
    RecommendedPost(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      excerpt: json['excerpt'] as String?,
      category: json['category'] as String,
      authorId: (json['authorId'] as num).toInt(),
      authorName: json['authorName'] as String,
      viewCount: (json['viewCount'] as num).toInt(),
      likeCount: (json['likeCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRecommended: json['isRecommended'] as bool? ?? true,
      recommendationScore: (json['recommendationScore'] as num).toDouble(),
      recommendationReason: json['recommendationReason'] as String?,
    );

Map<String, dynamic> _$RecommendedPostToJson(RecommendedPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'excerpt': instance.excerpt,
      'category': instance.category,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'viewCount': instance.viewCount,
      'likeCount': instance.likeCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRecommended': instance.isRecommended,
      'recommendationScore': instance.recommendationScore,
      'recommendationReason': instance.recommendationReason,
    };

SimilarPost _$SimilarPostFromJson(Map<String, dynamic> json) => SimilarPost(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      excerpt: json['excerpt'] as String,
      similarity: (json['similarity'] as num).toDouble(),
    );

Map<String, dynamic> _$SimilarPostToJson(SimilarPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'excerpt': instance.excerpt,
      'similarity': instance.similarity,
    };

TrendingTopic _$TrendingTopicFromJson(Map<String, dynamic> json) =>
    TrendingTopic(
      topic: json['topic'] as String,
      count: (json['count'] as num).toInt(),
      growth: (json['growth'] as num).toDouble(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$TrendingTopicToJson(TrendingTopic instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'count': instance.count,
      'growth': instance.growth,
      'description': instance.description,
    };

UserInteraction _$UserInteractionFromJson(Map<String, dynamic> json) =>
    UserInteraction(
      userId: (json['userId'] as num).toInt(),
      postId: (json['postId'] as num).toInt(),
      action: json['action'] as String,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$UserInteractionToJson(UserInteraction instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'postId': instance.postId,
      'action': instance.action,
      'category': instance.category,
      'tags': instance.tags,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

AISearchResponse _$AISearchResponseFromJson(Map<String, dynamic> json) =>
    AISearchResponse(
      posts: (json['posts'] as List<dynamic>)
          .map((e) => AISearchPost.fromJson(e as Map<String, dynamic>))
          .toList(),
      relatedTopics: (json['relatedTopics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      suggestedQueries: (json['suggestedQueries'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
    );

Map<String, dynamic> _$AISearchResponseToJson(AISearchResponse instance) =>
    <String, dynamic>{
      'posts': instance.posts,
      'relatedTopics': instance.relatedTopics,
      'suggestedQueries': instance.suggestedQueries,
      'totalCount': instance.totalCount,
    };

AISearchPost _$AISearchPostFromJson(Map<String, dynamic> json) => AISearchPost(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      excerpt: json['excerpt'] as String?,
      category: json['category'] as String,
      authorName: json['authorName'] as String,
      viewCount: (json['viewCount'] as num).toInt(),
      likeCount: (json['likeCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AISearchPostToJson(AISearchPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'excerpt': instance.excerpt,
      'category': instance.category,
      'authorName': instance.authorName,
      'viewCount': instance.viewCount,
      'likeCount': instance.likeCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };
