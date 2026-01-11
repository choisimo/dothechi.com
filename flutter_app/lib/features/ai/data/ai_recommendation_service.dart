import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_chat_client/core/ai/ai_service_interface.dart';
import 'package:flutter_chat_client/core/ai/ai_providers.dart';
import 'package:flutter_chat_client/core/network/api_client.dart';
import 'package:flutter_chat_client/features/auth/data/providers/auth_providers.dart';
import 'package:flutter_chat_client/features/auth/domain/dto/auth_status.dart';

import 'api/ai_api.dart';
import '../domain/models/ai_models.dart';

part 'ai_recommendation_service.g.dart';

// ============================================================================
// AI API Provider
// ============================================================================

@riverpod
AIApi aiApi(AiApiRef ref) {
  final dio = ref.watch(communityDioProvider);
  return AIApi(dio);
}

// ============================================================================
// AI Recommendation Service
// ============================================================================

class AIRecommendationService {
  final AIApi aiApi;
  final AIServiceInterface aiService;

  AIRecommendationService({
    required this.aiApi,
    required this.aiService,
  });

  /// 사용자 관심사 기반 게시물 추천
  Future<List<RecommendedPost>> getPersonalizedPosts(
    int userId, {
    List<String>? preferredCategories,
    List<String>? preferredTags,
    int limit = 10,
  }) async {
    try {
      return await aiApi.getPersonalizedRecommendations(
        userId: userId,
        preferredCategories: preferredCategories,
        preferredTags: preferredTags,
        limit: limit,
      );
    } catch (e) {
      developer.log('Error fetching personalized posts: $e',
          name: 'AIRecommendationService');
      // Fallback to empty list on error
      return [];
    }
  }

  /// 유사 게시물 추천
  Future<List<SimilarPost>> getSimilarPosts(int postId, {int limit = 5}) async {
    try {
      return await aiApi.getSimilarPosts(postId, limit: limit);
    } catch (e) {
      developer.log('Error fetching similar posts: $e',
          name: 'AIRecommendationService');
      return [];
    }
  }

  /// 트렌딩 토픽 분석
  Future<List<TrendingTopic>> getTrendingTopics() async {
    try {
      return await aiApi.getTrendingTopics();
    } catch (e) {
      developer.log('Error fetching trending topics: $e',
          name: 'AIRecommendationService');
      return [];
    }
  }

  /// 사용자 행동 기록
  Future<void> recordUserInteraction({
    required int userId,
    required String action, // 'view', 'like', 'comment', 'share'
    required int postId,
    String? category,
    List<String>? tags,
  }) async {
    try {
      final interaction = UserInteraction(
        userId: userId,
        postId: postId,
        action: action,
        category: category,
        tags: tags,
        timestamp: DateTime.now(),
      );
      await aiApi.recordInteraction(interaction);
    } catch (e) {
      developer.log('Error recording interaction: $e',
          name: 'AIRecommendationService');
      // Non-critical, don't throw
    }
  }

  /// AI 스마트 검색
  Future<AISearchResponse> smartSearch(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await aiApi.smartSearch(query: query, page: page, limit: limit);
    } catch (e) {
      developer.log('Error performing smart search: $e',
          name: 'AIRecommendationService');
      return AISearchResponse(
        posts: [],
        relatedTopics: [],
        suggestedQueries: [],
        totalCount: 0,
      );
    }
  }
}

// ============================================================================
// Riverpod Providers
// ============================================================================

@riverpod
AIRecommendationService aiRecommendationService(
    AiRecommendationServiceRef ref) {
  final aiApi = ref.watch(aiApiProvider);
  final aiService = ref.watch(aiServiceProvider);
  return AIRecommendationService(aiApi: aiApi, aiService: aiService);
}

/// 현재 로그인한 사용자 ID 가져오기
@riverpod
int? currentUserId(CurrentUserIdRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return switch (authState) {
    AuthAuthenticated(:final user) => int.tryParse(user.id),
    _ => null,
  };
}

/// 개인화 추천 게시물 프로바이더
@riverpod
Future<List<RecommendedPost>> personalizedPosts(
    PersonalizedPostsRef ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final service = ref.read(aiRecommendationServiceProvider);
  return await service.getPersonalizedPosts(userId);
}

/// 유사 게시물 프로바이더
@riverpod
Future<List<SimilarPost>> similarPosts(SimilarPostsRef ref, int postId) async {
  final service = ref.read(aiRecommendationServiceProvider);
  return await service.getSimilarPosts(postId);
}

/// 트렌딩 토픽 프로바이더
@riverpod
Future<List<TrendingTopic>> trendingTopics(TrendingTopicsRef ref) async {
  final service = ref.read(aiRecommendationServiceProvider);
  return await service.getTrendingTopics();
}

// ============================================================================
// User Interaction State Management
// ============================================================================

class UserInteractionLocalState {
  final Map<int, DateTime> viewedPosts;
  final Set<int> likedPosts;
  final Map<String, int> categoryInteractions;
  final Map<String, int> tagInteractions;

  UserInteractionLocalState({
    this.viewedPosts = const {},
    this.likedPosts = const {},
    this.categoryInteractions = const {},
    this.tagInteractions = const {},
  });

  UserInteractionLocalState copyWith({
    Map<int, DateTime>? viewedPosts,
    Set<int>? likedPosts,
    Map<String, int>? categoryInteractions,
    Map<String, int>? tagInteractions,
  }) {
    return UserInteractionLocalState(
      viewedPosts: viewedPosts ?? this.viewedPosts,
      likedPosts: likedPosts ?? this.likedPosts,
      categoryInteractions: categoryInteractions ?? this.categoryInteractions,
      tagInteractions: tagInteractions ?? this.tagInteractions,
    );
  }
}

@riverpod
class UserInteractionNotifier extends _$UserInteractionNotifier {
  @override
  UserInteractionLocalState build() {
    return UserInteractionLocalState();
  }

  AIRecommendationService get _service =>
      ref.read(aiRecommendationServiceProvider);

  int? get _userId => ref.read(currentUserIdProvider);

  Future<void> recordPostView(int postId,
      {String? category, List<String>? tags}) async {
    // Update local state
    final newViewedPosts = Map<int, DateTime>.from(state.viewedPosts);
    newViewedPosts[postId] = DateTime.now();

    final newCategoryInteractions =
        Map<String, int>.from(state.categoryInteractions);
    if (category != null) {
      newCategoryInteractions[category] =
          (newCategoryInteractions[category] ?? 0) + 1;
    }

    final newTagInteractions = Map<String, int>.from(state.tagInteractions);
    if (tags != null) {
      for (final tag in tags) {
        newTagInteractions[tag] = (newTagInteractions[tag] ?? 0) + 1;
      }
    }

    state = state.copyWith(
      viewedPosts: newViewedPosts,
      categoryInteractions: newCategoryInteractions,
      tagInteractions: newTagInteractions,
    );

    // Send to server
    final userId = _userId;
    if (userId != null) {
      await _service.recordUserInteraction(
        userId: userId,
        action: 'view',
        postId: postId,
        category: category,
        tags: tags,
      );
    }
  }

  Future<void> recordPostLike(int postId,
      {String? category, List<String>? tags}) async {
    final newLikedPosts = Set<int>.from(state.likedPosts);
    newLikedPosts.add(postId);

    final newCategoryInteractions =
        Map<String, int>.from(state.categoryInteractions);
    if (category != null) {
      newCategoryInteractions[category] =
          (newCategoryInteractions[category] ?? 0) + 2; // 좋아요는 가중치 2
    }

    final newTagInteractions = Map<String, int>.from(state.tagInteractions);
    if (tags != null) {
      for (final tag in tags) {
        newTagInteractions[tag] = (newTagInteractions[tag] ?? 0) + 2;
      }
    }

    state = state.copyWith(
      likedPosts: newLikedPosts,
      categoryInteractions: newCategoryInteractions,
      tagInteractions: newTagInteractions,
    );

    // Send to server
    final userId = _userId;
    if (userId != null) {
      await _service.recordUserInteraction(
        userId: userId,
        action: 'like',
        postId: postId,
        category: category,
        tags: tags,
      );
    }
  }

  Future<void> recordPostComment(int postId,
      {String? category, List<String>? tags}) async {
    final userId = _userId;
    if (userId != null) {
      await _service.recordUserInteraction(
        userId: userId,
        action: 'comment',
        postId: postId,
        category: category,
        tags: tags,
      );
    }
  }

  Future<void> recordPostShare(int postId,
      {String? category, List<String>? tags}) async {
    final userId = _userId;
    if (userId != null) {
      await _service.recordUserInteraction(
        userId: userId,
        action: 'share',
        postId: postId,
        category: category,
        tags: tags,
      );
    }
  }

  List<String> getTopInteractedCategories({int limit = 5}) {
    final sorted = state.categoryInteractions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  List<String> getTopInteractedTags({int limit = 10}) {
    final sorted = state.tagInteractions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }
}

// ============================================================================
// Smart Feed Provider
// ============================================================================

@riverpod
Future<List<RecommendedPost>> smartFeed(SmartFeedRef ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final interactionNotifier =
      ref.read(userInteractionNotifierProvider.notifier);
  final service = ref.read(aiRecommendationServiceProvider);

  // Get user's preferred categories and tags from local interaction history
  final topCategories = interactionNotifier.getTopInteractedCategories();
  final topTags = interactionNotifier.getTopInteractedTags();

  // Fetch personalized posts with user preferences
  return await service.getPersonalizedPosts(
    userId,
    preferredCategories: topCategories.isNotEmpty ? topCategories : null,
    preferredTags: topTags.isNotEmpty ? topTags : null,
  );
}

// ============================================================================
// AI Content Analysis Provider (using local AI service)
// ============================================================================

@riverpod
Future<Map<String, dynamic>> contentAnalysis(
    ContentAnalysisRef ref, String content) async {
  final aiService = ref.read(aiServiceProvider);

  // Perform multiple AI analyses concurrently
  final results = await Future.wait([
    aiService.generateTags(content),
    aiService.classifyCategory('', content),
    aiService.generateKeywords(content),
    aiService.isSpamContent(content),
  ]);

  return {
    'tags': results[0] as List<String>,
    'category': results[1] as String,
    'keywords': results[2] as List<String>,
    'isSpam': results[3] as bool,
    'analyzedAt': DateTime.now(),
  };
}

// ============================================================================
// AI Search Provider
// ============================================================================

@riverpod
class AISearchNotifier extends _$AISearchNotifier {
  @override
  AsyncValue<AISearchResponse?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> search(String query, {int page = 1, int limit = 10}) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final service = ref.read(aiRecommendationServiceProvider);
      final response =
          await service.smartSearch(query, page: page, limit: limit);
      state = AsyncValue.data(response);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data(null);
  }
}
