import 'package:flutter_chat_client/core/ai/ai_service_interface.dart';
import 'package:flutter_chat_client/core/ai/ai_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIRecommendationService {
  final AIServiceInterface aiService;

  AIRecommendationService(this.aiService);

  /// 사용자 관심사 기반 게시물 추천
  Future<List<Map<String, dynamic>>> getPersonalizedPosts(
    String userId, {
    List<String>? preferredCategories,
    List<String>? preferredTags,
  }) async {
    // TODO: 실제 사용자 행동 데이터 기반 추천 구현
    // 현재는 Mock 데이터 반환
    await Future.delayed(const Duration(seconds: 1));

    return [
      {
        'id': 201,
        'title': 'Flutter 성능 최적화 실전 가이드',
        'content': 'Flutter 앱의 성능을 극대화하는 실전 기법들을 상세히 다룹니다. 위젯 최적화부터 메모리 관리까지.',
        'excerpt': 'Flutter 앱의 성능을 극대화하는 실전 기법들을 상세히 다룹니다.',
        'author': {'userNick': '성능마스터'},
        'category': 'tech',
        'tags': ['flutter', '성능', '최적화'],
        'likeCount': 45,
        'viewCount': 320,
        'createdAt': DateTime.now().subtract(const Duration(hours: 3)),
        'isRecommended': true,
        'recommendationScore': 0.92,
        'recommendationReason': '최근 Flutter 성능 관련 글을 자주 읽으셨네요',
      },
      {
        'id': 202,
        'title': 'AI 챗봇 구현하기: 처음부터 끝까지',
        'content':
            'Flutter 앱에 AI 챗봇을 통합하는 완벽한 가이드입니다. OpenAI API 연동부터 UI 구성까지.',
        'excerpt': 'Flutter 앱에 AI 챗봇을 통합하는 완벽한 가이드입니다.',
        'author': {'userNick': 'AI개발자'},
        'category': 'tech',
        'tags': ['ai', 'chatbot', 'openai'],
        'likeCount': 67,
        'viewCount': 480,
        'createdAt': DateTime.now().subtract(const Duration(hours: 5)),
        'isRecommended': true,
        'recommendationScore': 0.89,
        'recommendationReason': 'AI 관련 콘텐츠에 관심이 많으시네요',
      },
    ];
  }

  /// 유사 게시물 추천
  Future<List<Map<String, dynamic>>> getSimilarPosts(int postId) async {
    // TODO: 게시물 내용 유사도 기반 추천 구현
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      {
        'id': 301,
        'title': '관련 글: Dart 언어 심화 학습',
        'excerpt': 'Dart 언어의 고급 기능들을 활용한 효율적인 코딩 방법을 소개합니다.',
        'similarity': 0.85,
      },
      {
        'id': 302,
        'title': '관련 글: 모바일 앱 아키텍처 패턴',
        'excerpt': 'Clean Architecture와 MVVM 패턴을 Flutter에 적용하는 방법을 다룹니다.',
        'similarity': 0.78,
      },
    ];
  }

  /// 트렌딩 토픽 분석
  Future<List<Map<String, dynamic>>> getTrendingTopics() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      {
        'topic': 'Flutter 3.16',
        'count': 25,
        'growth': 0.35,
        'description': 'Flutter 최신 버전 업데이트',
      },
      {
        'topic': 'AI 통합',
        'count': 18,
        'growth': 0.42,
        'description': '모바일 앱에 AI 기능 추가',
      },
      {
        'topic': '상태 관리',
        'count': 15,
        'growth': 0.12,
        'description': 'Riverpod, Bloc 등 상태 관리 라이브러리',
      },
    ];
  }

  /// 사용자 행동 기록
  Future<void> recordUserInteraction({
    required String userId,
    required String action, // 'view', 'like', 'comment', 'share'
    required int postId,
    String? category,
    List<String>? tags,
  }) async {
    // TODO: 사용자 행동 데이터 저장
    // 실제 구현에서는 이 데이터를 기반으로 추천 모델 학습
  }

  /// 개인화 추천 모델 업데이트
  Future<void> updatePersonalizationModel(String userId) async {
    // TODO: 사용자별 추천 모델 재학습
  }
}

// 추천 시스템 프로바이더들
final aiRecommendationServiceProvider =
    Provider<AIRecommendationService>((ref) {
  final aiService = ref.read(aiServiceProvider);
  return AIRecommendationService(aiService);
});

final personalizedPostsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, userId) async {
  final service = ref.read(aiRecommendationServiceProvider);
  return await service.getPersonalizedPosts(userId);
});

final similarPostsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, postId) async {
  final service = ref.read(aiRecommendationServiceProvider);
  return await service.getSimilarPosts(postId);
});

final trendingTopicsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(aiRecommendationServiceProvider);
  return await service.getTrendingTopics();
});

// 사용자 상호작용 기록 프로바이더
final userInteractionNotifierProvider =
    StateNotifierProvider<UserInteractionNotifier, UserInteractionState>((ref) {
  final service = ref.read(aiRecommendationServiceProvider);
  return UserInteractionNotifier(service);
});

class UserInteractionState {
  final Map<int, DateTime> viewedPosts;
  final Set<int> likedPosts;
  final Map<String, int> categoryInteractions;
  final Map<String, int> tagInteractions;

  UserInteractionState({
    this.viewedPosts = const {},
    this.likedPosts = const {},
    this.categoryInteractions = const {},
    this.tagInteractions = const {},
  });

  UserInteractionState copyWith({
    Map<int, DateTime>? viewedPosts,
    Set<int>? likedPosts,
    Map<String, int>? categoryInteractions,
    Map<String, int>? tagInteractions,
  }) {
    return UserInteractionState(
      viewedPosts: viewedPosts ?? this.viewedPosts,
      likedPosts: likedPosts ?? this.likedPosts,
      categoryInteractions: categoryInteractions ?? this.categoryInteractions,
      tagInteractions: tagInteractions ?? this.tagInteractions,
    );
  }
}

class UserInteractionNotifier extends StateNotifier<UserInteractionState> {
  final AIRecommendationService _service;

  UserInteractionNotifier(this._service) : super(UserInteractionState());

  Future<void> recordPostView(int postId,
      {String? category, List<String>? tags}) async {
    // 상태 업데이트
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

    // 서버에 기록
    await _service.recordUserInteraction(
      userId: 'current_user', // TODO: 실제 사용자 ID 사용
      action: 'view',
      postId: postId,
      category: category,
      tags: tags,
    );
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

    await _service.recordUserInteraction(
      userId: 'current_user',
      action: 'like',
      postId: postId,
      category: category,
      tags: tags,
    );
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

// 스마트 피드 프로바이더 - 사용자 관심사 기반으로 피드 구성
final smartFeedProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userInteractionNotifier =
      ref.read(userInteractionNotifierProvider.notifier);
  final recommendationService = ref.read(aiRecommendationServiceProvider);

  // 사용자 관심 카테고리와 태그 기반으로 맞춤형 피드 생성
  final topCategories = userInteractionNotifier.getTopInteractedCategories();
  final topTags = userInteractionNotifier.getTopInteractedTags();

  // AI 추천 게시물 가져오기 (사용자 관심사 반영)
  final personalizedPosts = await recommendationService.getPersonalizedPosts(
    'current_user',
    preferredCategories: topCategories,
    preferredTags: topTags,
  );

  // 트렌딩 토픽도 포함
  final trendingTopics = await recommendationService.getTrendingTopics();

  // 피드 구성 (추천 게시물 + 트렌딩 기반 게시물)
  final feed = <Map<String, dynamic>>[];
  feed.addAll(personalizedPosts);

  // 트렌딩 토픽 기반 추가 게시물 (Mock)
  for (final topic in trendingTopics.take(2)) {
    feed.add({
      'id': 400 + feed.length,
      'title': '🔥 ${topic['topic']}: 지금 가장 핫한 주제',
      'content': '${topic['description']} - 커뮤니티에서 가장 많이 이야기되고 있는 주제입니다.',
      'excerpt': topic['description'],
      'isTrending': true,
      'trendingScore': topic['growth'],
    });
  }

  return feed;
});

// AI 콘텐츠 분석 프로바이더
final contentAnalysisProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, content) async {
  final aiService = ref.read(aiServiceProvider);

  // 동시에 여러 AI 분석 수행
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
});
