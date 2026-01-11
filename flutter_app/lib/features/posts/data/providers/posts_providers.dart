import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../api/posts_api.dart';
import '../datasources/posts_repository.dart';
import '../../domain/models/post.dart';
import '../../domain/models/category.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/providers/auth_providers.dart';

part 'posts_providers.g.dart';

@riverpod
PostsApi postsApi(PostsApiRef ref) {
  final dio = ref.watch(communityDioProvider);
  return PostsApi(dio);
}

@riverpod
PostsRepository postsRepository(PostsRepositoryRef ref) {
  final postsApi = ref.watch(postsApiProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return PostsRepository(postsApi, tokenStorage);
}

@riverpod
Future<List<Post>> latestPosts(LatestPostsRef ref, {int limit = 10}) async {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.getLatestPosts(limit: limit);
}

@riverpod
Future<List<Post>> recommendedPosts(RecommendedPostsRef ref,
    {int limit = 5}) async {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.getRecommendedPosts(limit: limit);
}

@riverpod
Future<List<Category>> categories(CategoriesRef ref) async {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.getCategories();
}

@riverpod
Future<List<Category>> popularCategories(PopularCategoriesRef ref,
    {int limit = 5}) async {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.getPopularCategories(limit: limit);
}

@riverpod
Future<Post> post(PostRef ref, int id) async {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.getPost(id);
}
