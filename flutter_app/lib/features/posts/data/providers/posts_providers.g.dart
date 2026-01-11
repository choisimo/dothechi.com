// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postsApiHash() => r'97d42950730f7508ba3db6ef2c07cee01ab9e3f3';

/// See also [postsApi].
@ProviderFor(postsApi)
final postsApiProvider = AutoDisposeProvider<PostsApi>.internal(
  postsApi,
  name: r'postsApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$postsApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PostsApiRef = AutoDisposeProviderRef<PostsApi>;
String _$postsRepositoryHash() => r'db74d76f2638ec2a208b03ebb506bee8eb5d164e';

/// See also [postsRepository].
@ProviderFor(postsRepository)
final postsRepositoryProvider = AutoDisposeProvider<PostsRepository>.internal(
  postsRepository,
  name: r'postsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$postsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PostsRepositoryRef = AutoDisposeProviderRef<PostsRepository>;
String _$latestPostsHash() => r'2b90ccd51ad8becc4169373bc7ffec94f8d6e685';

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

/// See also [latestPosts].
@ProviderFor(latestPosts)
const latestPostsProvider = LatestPostsFamily();

/// See also [latestPosts].
class LatestPostsFamily extends Family<AsyncValue<List<Post>>> {
  /// See also [latestPosts].
  const LatestPostsFamily();

  /// See also [latestPosts].
  LatestPostsProvider call({
    int limit = 10,
  }) {
    return LatestPostsProvider(
      limit: limit,
    );
  }

  @override
  LatestPostsProvider getProviderOverride(
    covariant LatestPostsProvider provider,
  ) {
    return call(
      limit: provider.limit,
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
  String? get name => r'latestPostsProvider';
}

/// See also [latestPosts].
class LatestPostsProvider extends AutoDisposeFutureProvider<List<Post>> {
  /// See also [latestPosts].
  LatestPostsProvider({
    int limit = 10,
  }) : this._internal(
          (ref) => latestPosts(
            ref as LatestPostsRef,
            limit: limit,
          ),
          from: latestPostsProvider,
          name: r'latestPostsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$latestPostsHash,
          dependencies: LatestPostsFamily._dependencies,
          allTransitiveDependencies:
              LatestPostsFamily._allTransitiveDependencies,
          limit: limit,
        );

  LatestPostsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<Post>> Function(LatestPostsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LatestPostsProvider._internal(
        (ref) => create(ref as LatestPostsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Post>> createElement() {
    return _LatestPostsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LatestPostsProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LatestPostsRef on AutoDisposeFutureProviderRef<List<Post>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _LatestPostsProviderElement
    extends AutoDisposeFutureProviderElement<List<Post>> with LatestPostsRef {
  _LatestPostsProviderElement(super.provider);

  @override
  int get limit => (origin as LatestPostsProvider).limit;
}

String _$recommendedPostsHash() => r'5f66d13799befd3f2cb486c0fa35e767db75540c';

/// See also [recommendedPosts].
@ProviderFor(recommendedPosts)
const recommendedPostsProvider = RecommendedPostsFamily();

/// See also [recommendedPosts].
class RecommendedPostsFamily extends Family<AsyncValue<List<Post>>> {
  /// See also [recommendedPosts].
  const RecommendedPostsFamily();

  /// See also [recommendedPosts].
  RecommendedPostsProvider call({
    int limit = 5,
  }) {
    return RecommendedPostsProvider(
      limit: limit,
    );
  }

  @override
  RecommendedPostsProvider getProviderOverride(
    covariant RecommendedPostsProvider provider,
  ) {
    return call(
      limit: provider.limit,
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
  String? get name => r'recommendedPostsProvider';
}

/// See also [recommendedPosts].
class RecommendedPostsProvider extends AutoDisposeFutureProvider<List<Post>> {
  /// See also [recommendedPosts].
  RecommendedPostsProvider({
    int limit = 5,
  }) : this._internal(
          (ref) => recommendedPosts(
            ref as RecommendedPostsRef,
            limit: limit,
          ),
          from: recommendedPostsProvider,
          name: r'recommendedPostsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$recommendedPostsHash,
          dependencies: RecommendedPostsFamily._dependencies,
          allTransitiveDependencies:
              RecommendedPostsFamily._allTransitiveDependencies,
          limit: limit,
        );

  RecommendedPostsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<Post>> Function(RecommendedPostsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecommendedPostsProvider._internal(
        (ref) => create(ref as RecommendedPostsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Post>> createElement() {
    return _RecommendedPostsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecommendedPostsProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecommendedPostsRef on AutoDisposeFutureProviderRef<List<Post>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _RecommendedPostsProviderElement
    extends AutoDisposeFutureProviderElement<List<Post>>
    with RecommendedPostsRef {
  _RecommendedPostsProviderElement(super.provider);

  @override
  int get limit => (origin as RecommendedPostsProvider).limit;
}

String _$categoriesHash() => r'e227488471a13f30bad99e4d6e49cc786c7c5fbd';

/// See also [categories].
@ProviderFor(categories)
final categoriesProvider = AutoDisposeFutureProvider<List<Category>>.internal(
  categories,
  name: r'categoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$categoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoriesRef = AutoDisposeFutureProviderRef<List<Category>>;
String _$popularCategoriesHash() => r'3b91eb622fcd95972ff6ba1b431d6ad2de12922f';

/// See also [popularCategories].
@ProviderFor(popularCategories)
const popularCategoriesProvider = PopularCategoriesFamily();

/// See also [popularCategories].
class PopularCategoriesFamily extends Family<AsyncValue<List<Category>>> {
  /// See also [popularCategories].
  const PopularCategoriesFamily();

  /// See also [popularCategories].
  PopularCategoriesProvider call({
    int limit = 5,
  }) {
    return PopularCategoriesProvider(
      limit: limit,
    );
  }

  @override
  PopularCategoriesProvider getProviderOverride(
    covariant PopularCategoriesProvider provider,
  ) {
    return call(
      limit: provider.limit,
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
  String? get name => r'popularCategoriesProvider';
}

/// See also [popularCategories].
class PopularCategoriesProvider
    extends AutoDisposeFutureProvider<List<Category>> {
  /// See also [popularCategories].
  PopularCategoriesProvider({
    int limit = 5,
  }) : this._internal(
          (ref) => popularCategories(
            ref as PopularCategoriesRef,
            limit: limit,
          ),
          from: popularCategoriesProvider,
          name: r'popularCategoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$popularCategoriesHash,
          dependencies: PopularCategoriesFamily._dependencies,
          allTransitiveDependencies:
              PopularCategoriesFamily._allTransitiveDependencies,
          limit: limit,
        );

  PopularCategoriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<Category>> Function(PopularCategoriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PopularCategoriesProvider._internal(
        (ref) => create(ref as PopularCategoriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Category>> createElement() {
    return _PopularCategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PopularCategoriesProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PopularCategoriesRef on AutoDisposeFutureProviderRef<List<Category>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _PopularCategoriesProviderElement
    extends AutoDisposeFutureProviderElement<List<Category>>
    with PopularCategoriesRef {
  _PopularCategoriesProviderElement(super.provider);

  @override
  int get limit => (origin as PopularCategoriesProvider).limit;
}

String _$postHash() => r'dbe2cfc09c343447bdb4519aaff47dfb3ba65ad5';

/// See also [post].
@ProviderFor(post)
const postProvider = PostFamily();

/// See also [post].
class PostFamily extends Family<AsyncValue<Post>> {
  /// See also [post].
  const PostFamily();

  /// See also [post].
  PostProvider call(
    int id,
  ) {
    return PostProvider(
      id,
    );
  }

  @override
  PostProvider getProviderOverride(
    covariant PostProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'postProvider';
}

/// See also [post].
class PostProvider extends AutoDisposeFutureProvider<Post> {
  /// See also [post].
  PostProvider(
    int id,
  ) : this._internal(
          (ref) => post(
            ref as PostRef,
            id,
          ),
          from: postProvider,
          name: r'postProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product') ? null : _$postHash,
          dependencies: PostFamily._dependencies,
          allTransitiveDependencies: PostFamily._allTransitiveDependencies,
          id: id,
        );

  PostProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<Post> Function(PostRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PostProvider._internal(
        (ref) => create(ref as PostRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Post> createElement() {
    return _PostProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostRef on AutoDisposeFutureProviderRef<Post> {
  /// The parameter `id` of this provider.
  int get id;
}

class _PostProviderElement extends AutoDisposeFutureProviderElement<Post>
    with PostRef {
  _PostProviderElement(super.provider);

  @override
  int get id => (origin as PostProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
