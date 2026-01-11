// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchApiHash() => r'9fcd5f25a2f891f69a00c8e847e0eaa3c4467512';

/// See also [searchApi].
@ProviderFor(searchApi)
final searchApiProvider = AutoDisposeProvider<SearchApi>.internal(
  searchApi,
  name: r'searchApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchApiRef = AutoDisposeProviderRef<SearchApi>;
String _$searchRepositoryHash() => r'2388f340924b5ae29cdd42c816d199ebd9d99a94';

/// See also [searchRepository].
@ProviderFor(searchRepository)
final searchRepositoryProvider = AutoDisposeProvider<SearchRepository>.internal(
  searchRepository,
  name: r'searchRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchRepositoryRef = AutoDisposeProviderRef<SearchRepository>;
String _$searchPostsHash() => r'fab2466233de7d251395b87f5f4937e5a967fcc2';

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

/// See also [searchPosts].
@ProviderFor(searchPosts)
const searchPostsProvider = SearchPostsFamily();

/// See also [searchPosts].
class SearchPostsFamily extends Family<AsyncValue<List<Post>>> {
  /// See also [searchPosts].
  const SearchPostsFamily();

  /// See also [searchPosts].
  SearchPostsProvider call(
    String query,
  ) {
    return SearchPostsProvider(
      query,
    );
  }

  @override
  SearchPostsProvider getProviderOverride(
    covariant SearchPostsProvider provider,
  ) {
    return call(
      provider.query,
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
  String? get name => r'searchPostsProvider';
}

/// See also [searchPosts].
class SearchPostsProvider extends AutoDisposeFutureProvider<List<Post>> {
  /// See also [searchPosts].
  SearchPostsProvider(
    String query,
  ) : this._internal(
          (ref) => searchPosts(
            ref as SearchPostsRef,
            query,
          ),
          from: searchPostsProvider,
          name: r'searchPostsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchPostsHash,
          dependencies: SearchPostsFamily._dependencies,
          allTransitiveDependencies:
              SearchPostsFamily._allTransitiveDependencies,
          query: query,
        );

  SearchPostsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<Post>> Function(SearchPostsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchPostsProvider._internal(
        (ref) => create(ref as SearchPostsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Post>> createElement() {
    return _SearchPostsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchPostsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchPostsRef on AutoDisposeFutureProviderRef<List<Post>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchPostsProviderElement
    extends AutoDisposeFutureProviderElement<List<Post>> with SearchPostsRef {
  _SearchPostsProviderElement(super.provider);

  @override
  String get query => (origin as SearchPostsProvider).query;
}

String _$searchSuggestionsHash() => r'7eb2317d31ea3e441f39e4cb03f4e025291295c5';

/// See also [searchSuggestions].
@ProviderFor(searchSuggestions)
const searchSuggestionsProvider = SearchSuggestionsFamily();

/// See also [searchSuggestions].
class SearchSuggestionsFamily extends Family<AsyncValue<List<String>>> {
  /// See also [searchSuggestions].
  const SearchSuggestionsFamily();

  /// See also [searchSuggestions].
  SearchSuggestionsProvider call(
    String query,
  ) {
    return SearchSuggestionsProvider(
      query,
    );
  }

  @override
  SearchSuggestionsProvider getProviderOverride(
    covariant SearchSuggestionsProvider provider,
  ) {
    return call(
      provider.query,
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
  String? get name => r'searchSuggestionsProvider';
}

/// See also [searchSuggestions].
class SearchSuggestionsProvider
    extends AutoDisposeFutureProvider<List<String>> {
  /// See also [searchSuggestions].
  SearchSuggestionsProvider(
    String query,
  ) : this._internal(
          (ref) => searchSuggestions(
            ref as SearchSuggestionsRef,
            query,
          ),
          from: searchSuggestionsProvider,
          name: r'searchSuggestionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchSuggestionsHash,
          dependencies: SearchSuggestionsFamily._dependencies,
          allTransitiveDependencies:
              SearchSuggestionsFamily._allTransitiveDependencies,
          query: query,
        );

  SearchSuggestionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<String>> Function(SearchSuggestionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchSuggestionsProvider._internal(
        (ref) => create(ref as SearchSuggestionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<String>> createElement() {
    return _SearchSuggestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchSuggestionsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchSuggestionsRef on AutoDisposeFutureProviderRef<List<String>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchSuggestionsProviderElement
    extends AutoDisposeFutureProviderElement<List<String>>
    with SearchSuggestionsRef {
  _SearchSuggestionsProviderElement(super.provider);

  @override
  String get query => (origin as SearchSuggestionsProvider).query;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
