// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_recommendation_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiApiHash() => r'6d6af38fcde7221f266f5ffad2da1710a51ad5c8';

/// See also [aiApi].
@ProviderFor(aiApi)
final aiApiProvider = AutoDisposeProvider<AIApi>.internal(
  aiApi,
  name: r'aiApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aiApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiApiRef = AutoDisposeProviderRef<AIApi>;
String _$aiRecommendationServiceHash() =>
    r'76062e2b24f3ce712d35d1a9561bb9c1f0180835';

/// See also [aiRecommendationService].
@ProviderFor(aiRecommendationService)
final aiRecommendationServiceProvider =
    AutoDisposeProvider<AIRecommendationService>.internal(
  aiRecommendationService,
  name: r'aiRecommendationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiRecommendationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiRecommendationServiceRef
    = AutoDisposeProviderRef<AIRecommendationService>;
String _$currentUserIdHash() => r'eb6f1e7562a7c607aff835675184e891bdf1918e';

/// 현재 로그인한 사용자 ID 가져오기
///
/// Copied from [currentUserId].
@ProviderFor(currentUserId)
final currentUserIdProvider = AutoDisposeProvider<int?>.internal(
  currentUserId,
  name: r'currentUserIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserIdRef = AutoDisposeProviderRef<int?>;
String _$personalizedPostsHash() => r'9f43d2d2ae0c598b02f610731ac2d57567784af6';

/// 개인화 추천 게시물 프로바이더
///
/// Copied from [personalizedPosts].
@ProviderFor(personalizedPosts)
final personalizedPostsProvider =
    AutoDisposeFutureProvider<List<RecommendedPost>>.internal(
  personalizedPosts,
  name: r'personalizedPostsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$personalizedPostsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PersonalizedPostsRef
    = AutoDisposeFutureProviderRef<List<RecommendedPost>>;
String _$similarPostsHash() => r'1203bdb95f6d2383a1855511f44f7d65d7a1c265';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 유사 게시물 프로바이더
///
/// Copied from [similarPosts].
@ProviderFor(similarPosts)
const similarPostsProvider = SimilarPostsFamily();

/// 유사 게시물 프로바이더
///
/// Copied from [similarPosts].
class SimilarPostsFamily extends Family<AsyncValue<List<SimilarPost>>> {
  /// 유사 게시물 프로바이더
  ///
  /// Copied from [similarPosts].
  const SimilarPostsFamily();

  /// 유사 게시물 프로바이더
  ///
  /// Copied from [similarPosts].
  SimilarPostsProvider call(
    int postId,
  ) {
    return SimilarPostsProvider(
      postId,
    );
  }

  @override
  SimilarPostsProvider getProviderOverride(
    covariant SimilarPostsProvider provider,
  ) {
    return call(
      provider.postId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'similarPostsProvider';
}

/// 유사 게시물 프로바이더
///
/// Copied from [similarPosts].
class SimilarPostsProvider
    extends AutoDisposeFutureProvider<List<SimilarPost>> {
  /// 유사 게시물 프로바이더
  ///
  /// Copied from [similarPosts].
  SimilarPostsProvider(
    int postId,
  ) : this._internal(
          (ref) => similarPosts(
            ref as SimilarPostsRef,
            postId,
          ),
          from: similarPostsProvider,
          name: r'similarPostsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$similarPostsHash,
          dependencies: SimilarPostsFamily._dependencies,
          allTransitiveDependencies:
              SimilarPostsFamily._allTransitiveDependencies,
          postId: postId,
        );

  SimilarPostsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final int postId;

  @override
  Override overrideWith(
    FutureOr<List<SimilarPost>> Function(SimilarPostsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SimilarPostsProvider._internal(
        (ref) => create(ref as SimilarPostsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SimilarPost>> createElement() {
    return _SimilarPostsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SimilarPostsProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SimilarPostsRef on AutoDisposeFutureProviderRef<List<SimilarPost>> {
  /// The parameter `postId` of this provider.
  int get postId;
}

class _SimilarPostsProviderElement
    extends AutoDisposeFutureProviderElement<List<SimilarPost>>
    with SimilarPostsRef {
  _SimilarPostsProviderElement(super.provider);

  @override
  int get postId => (origin as SimilarPostsProvider).postId;
}

String _$trendingTopicsHash() => r'ba9565a4f76c8ec55604735ca9f33c3ab7427855';

/// 트렌딩 토픽 프로바이더
///
/// Copied from [trendingTopics].
@ProviderFor(trendingTopics)
final trendingTopicsProvider =
    AutoDisposeFutureProvider<List<TrendingTopic>>.internal(
  trendingTopics,
  name: r'trendingTopicsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trendingTopicsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrendingTopicsRef = AutoDisposeFutureProviderRef<List<TrendingTopic>>;
String _$smartFeedHash() => r'598464e55b6bab4eb309b5a4750b97bffae92d07';

/// See also [smartFeed].
@ProviderFor(smartFeed)
final smartFeedProvider =
    AutoDisposeFutureProvider<List<RecommendedPost>>.internal(
  smartFeed,
  name: r'smartFeedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$smartFeedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SmartFeedRef = AutoDisposeFutureProviderRef<List<RecommendedPost>>;
String _$contentAnalysisHash() => r'efbd84c728913b634e5054f16675e6c9e2c4e428';

/// See also [contentAnalysis].
@ProviderFor(contentAnalysis)
const contentAnalysisProvider = ContentAnalysisFamily();

/// See also [contentAnalysis].
class ContentAnalysisFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [contentAnalysis].
  const ContentAnalysisFamily();

  /// See also [contentAnalysis].
  ContentAnalysisProvider call(
    String content,
  ) {
    return ContentAnalysisProvider(
      content,
    );
  }

  @override
  ContentAnalysisProvider getProviderOverride(
    covariant ContentAnalysisProvider provider,
  ) {
    return call(
      provider.content,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contentAnalysisProvider';
}

/// See also [contentAnalysis].
class ContentAnalysisProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [contentAnalysis].
  ContentAnalysisProvider(
    String content,
  ) : this._internal(
          (ref) => contentAnalysis(
            ref as ContentAnalysisRef,
            content,
          ),
          from: contentAnalysisProvider,
          name: r'contentAnalysisProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$contentAnalysisHash,
          dependencies: ContentAnalysisFamily._dependencies,
          allTransitiveDependencies:
              ContentAnalysisFamily._allTransitiveDependencies,
          content: content,
        );

  ContentAnalysisProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.content,
  }) : super.internal();

  final String content;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(ContentAnalysisRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContentAnalysisProvider._internal(
        (ref) => create(ref as ContentAnalysisRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        content: content,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _ContentAnalysisProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContentAnalysisProvider && other.content == content;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, content.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContentAnalysisRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `content` of this provider.
  String get content;
}

class _ContentAnalysisProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with ContentAnalysisRef {
  _ContentAnalysisProviderElement(super.provider);

  @override
  String get content => (origin as ContentAnalysisProvider).content;
}

String _$userInteractionNotifierHash() =>
    r'162399cd44f155df66a50ffbe59e0bddb2d8634d';

/// See also [UserInteractionNotifier].
@ProviderFor(UserInteractionNotifier)
final userInteractionNotifierProvider = AutoDisposeNotifierProvider<
    UserInteractionNotifier, UserInteractionLocalState>.internal(
  UserInteractionNotifier.new,
  name: r'userInteractionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userInteractionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserInteractionNotifier
    = AutoDisposeNotifier<UserInteractionLocalState>;
String _$aISearchNotifierHash() => r'0f8b1c3c237f6b3734c0189223c86fe7c8933e60';

/// See also [AISearchNotifier].
@ProviderFor(AISearchNotifier)
final aISearchNotifierProvider = AutoDisposeNotifierProvider<AISearchNotifier,
    AsyncValue<AISearchResponse?>>.internal(
  AISearchNotifier.new,
  name: r'aISearchNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aISearchNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AISearchNotifier = AutoDisposeNotifier<AsyncValue<AISearchResponse?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
