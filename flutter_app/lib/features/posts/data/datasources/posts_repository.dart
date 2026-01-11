import '../api/posts_api.dart';
import '../dto/post_list_response.dart';
import '../dto/create_post_request.dart';
import '../../domain/models/post.dart';
import '../../domain/models/category.dart';
import '../../../auth/data/datasources/token_storage.dart';

class PostsRepository {
  final PostsApi _postsApi;
  final TokenStorage _tokenStorage;

  PostsRepository(this._postsApi, this._tokenStorage);

  Future<PostListResponse> getPosts({
    int page = 1,
    int limit = 10,
    String? category,
    String sort = 'latest',
  }) async {
    return await _postsApi.getPosts(
      page: page,
      limit: limit,
      category: category,
      sort: sort,
    );
  }

  Future<Post> getPost(int id) async {
    return await _postsApi.getPost(id);
  }

  Future<Post> createPost({
    required String title,
    required String content,
    required String category,
    required List<String> tags,
  }) async {
    final token = await _tokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    final request = CreatePostRequest(
      title: title,
      content: content,
      category: category,
      tags: tags,
    );

    return await _postsApi.createPost(request, 'Bearer $token');
  }

  Future<Post> updatePost({
    required int id,
    required String title,
    required String content,
    required String category,
    required List<String> tags,
  }) async {
    final token = await _tokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    final request = CreatePostRequest(
      title: title,
      content: content,
      category: category,
      tags: tags,
    );

    return await _postsApi.updatePost(id, request, 'Bearer $token');
  }

  Future<void> deletePost(int id) async {
    final token = await _tokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    await _postsApi.deletePost(id, 'Bearer $token');
  }

  Future<List<Post>> getRecommendedPosts({int limit = 5}) async {
    return await _postsApi.getRecommendedPosts(limit: limit);
  }

  Future<List<Post>> getLatestPosts({int limit = 10}) async {
    return await _postsApi.getLatestPosts(limit: limit);
  }

  Future<List<Category>> getCategories() async {
    return await _postsApi.getCategories();
  }

  Future<List<Category>> getPopularCategories({int limit = 5}) async {
    return await _postsApi.getPopularCategories(limit: limit);
  }
}
