import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../domain/models/ai_models.dart';

part 'ai_api.g.dart';

@RestApi()
abstract class AIApi {
  factory AIApi(Dio dio, {String baseUrl}) = _AIApi;

  /// 개인화 추천 게시물 조회
  @GET('/api/ai/recommendations')
  Future<List<RecommendedPost>> getPersonalizedRecommendations({
    @Header('X-User-Id') required int userId,
    @Query('preferredCategories') List<String>? preferredCategories,
    @Query('preferredTags') List<String>? preferredTags,
    @Query('limit') int limit = 10,
  });

  /// 유사 게시물 조회
  @GET('/api/ai/posts/{postId}/similar')
  Future<List<SimilarPost>> getSimilarPosts(
    @Path('postId') int postId, {
    @Query('limit') int limit = 5,
  });

  /// 트렌딩 토픽 조회
  @GET('/api/ai/trending')
  Future<List<TrendingTopic>> getTrendingTopics();

  /// 사용자 상호작용 기록
  @POST('/api/ai/interactions')
  Future<void> recordInteraction(@Body() UserInteraction interaction);

  /// AI 스마트 검색
  @GET('/api/ai/search')
  Future<AISearchResponse> smartSearch({
    @Query('query') required String query,
    @Query('page') int page = 1,
    @Query('limit') int limit = 10,
  });
}
