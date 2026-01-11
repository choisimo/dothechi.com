import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../api/search_api.dart';
import '../datasources/search_repository.dart';
import '../../../posts/domain/models/post.dart';
import '../../../../core/network/api_client.dart';

part 'search_providers.g.dart';

@riverpod
SearchApi searchApi(SearchApiRef ref) {
  final dio = ref.watch(communityDioProvider);
  return SearchApi(dio);
}

@riverpod
SearchRepository searchRepository(SearchRepositoryRef ref) {
  final searchApi = ref.watch(searchApiProvider);
  return SearchRepository(searchApi);
}

@riverpod
Future<List<Post>> searchPosts(SearchPostsRef ref, String query) async {
  if (query.trim().isEmpty) return [];

  final repository = ref.watch(searchRepositoryProvider);
  return repository.searchPosts(query: query.trim());
}

@riverpod
Future<List<String>> searchSuggestions(
    SearchSuggestionsRef ref, String query) async {
  if (query.trim().isEmpty) return [];

  final repository = ref.watch(searchRepositoryProvider);
  return repository.getSearchSuggestions(query: query.trim());
}
