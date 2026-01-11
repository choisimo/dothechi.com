import '../api/search_api.dart';
import '../../../posts/domain/models/post.dart';

class SearchRepository {
  final SearchApi _searchApi;

  SearchRepository(this._searchApi);

  Future<List<Post>> searchPosts({
    required String query,
    int page = 1,
    int limit = 10,
    String? category,
  }) async {
    final response = await _searchApi.searchPosts(
      query,
      page,
      limit,
      category,
    );
    return response.posts;
  }

  Future<List<String>> getSearchSuggestions({
    required String query,
    int limit = 5,
  }) async {
    return await _searchApi.getSearchSuggestions(
      query,
      limit,
    );
  }
}
