// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'likes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$likesApiHash() => r'c97b894d79d9f06415e182253dd5b28481c24d61';

/// See also [likesApi].
@ProviderFor(likesApi)
final likesApiProvider = AutoDisposeProvider<LikesApi>.internal(
  likesApi,
  name: r'likesApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$likesApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LikesApiRef = AutoDisposeProviderRef<LikesApi>;
String _$postLikesHash() => r'25c5bcf12edd2f99f2eb7648e27a7a6c39509de8';

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

/// See also [postLikes].
@ProviderFor(postLikes)
const postLikesProvider = PostLikesFamily();

/// See also [postLikes].
class PostLikesFamily extends Family<AsyncValue<List<UserLikeInfo>>> {
  /// See also [postLikes].
  const PostLikesFamily();

  /// See also [postLikes].
  PostLikesProvider call(
    int postId,
  ) {
    return PostLikesProvider(
      postId,
    );
  }

  @override
  PostLikesProvider getProviderOverride(
    covariant PostLikesProvider provider,
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
  String? get name => r'postLikesProvider';
}

/// See also [postLikes].
class PostLikesProvider extends AutoDisposeFutureProvider<List<UserLikeInfo>> {
  /// See also [postLikes].
  PostLikesProvider(
    int postId,
  ) : this._internal(
          (ref) => postLikes(
            ref as PostLikesRef,
            postId,
          ),
          from: postLikesProvider,
          name: r'postLikesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$postLikesHash,
          dependencies: PostLikesFamily._dependencies,
          allTransitiveDependencies: PostLikesFamily._allTransitiveDependencies,
          postId: postId,
        );

  PostLikesProvider._internal(
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
    FutureOr<List<UserLikeInfo>> Function(PostLikesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PostLikesProvider._internal(
        (ref) => create(ref as PostLikesRef),
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
  AutoDisposeFutureProviderElement<List<UserLikeInfo>> createElement() {
    return _PostLikesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostLikesProvider && other.postId == postId;
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
mixin PostLikesRef on AutoDisposeFutureProviderRef<List<UserLikeInfo>> {
  /// The parameter `postId` of this provider.
  int get postId;
}

class _PostLikesProviderElement
    extends AutoDisposeFutureProviderElement<List<UserLikeInfo>>
    with PostLikesRef {
  _PostLikesProviderElement(super.provider);

  @override
  int get postId => (origin as PostLikesProvider).postId;
}

String _$userLikedPostIdsHash() => r'2a74c1ab35af5954513193a57111c1a1060d284d';

/// See also [userLikedPostIds].
@ProviderFor(userLikedPostIds)
final userLikedPostIdsProvider = AutoDisposeFutureProvider<List<int>>.internal(
  userLikedPostIds,
  name: r'userLikedPostIdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userLikedPostIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserLikedPostIdsRef = AutoDisposeFutureProviderRef<List<int>>;
String _$likeNotifierHash() => r'726aa974f9477a09adbd91f369c0f1bc50f0087c';

/// See also [LikeNotifier].
@ProviderFor(LikeNotifier)
final likeNotifierProvider =
    AutoDisposeNotifierProvider<LikeNotifier, AsyncValue<void>>.internal(
  LikeNotifier.new,
  name: r'likeNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$likeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LikeNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
