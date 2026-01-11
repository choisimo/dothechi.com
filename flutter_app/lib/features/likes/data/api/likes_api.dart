import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'likes_api.g.dart';

/// Response DTO for like operations
class LikeResponse {
  final bool success;
  final int likeCount;

  LikeResponse({required this.success, required this.likeCount});

  factory LikeResponse.fromJson(Map<String, dynamic> json) {
    return LikeResponse(
      success: json['success'] as bool? ?? true,
      likeCount: json['likeCount'] as int? ?? 0,
    );
  }
}

/// Response DTO for user like info
class UserLikeInfo {
  final int userId;
  final String userName;
  final String? userAvatar;
  final DateTime likedAt;

  UserLikeInfo({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.likedAt,
  });

  factory UserLikeInfo.fromJson(Map<String, dynamic> json) {
    return UserLikeInfo(
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      likedAt: DateTime.parse(json['likedAt'] as String),
    );
  }
}

@RestApi()
abstract class LikesApi {
  factory LikesApi(Dio dio, {String baseUrl}) = _LikesApi;

  @POST('/api/posts/{postId}/like')
  Future<LikeResponse> likePost(
    @Path('postId') int postId,
    @Header('Authorization') String token,
  );

  @DELETE('/api/posts/{postId}/like')
  Future<LikeResponse> unlikePost(
    @Path('postId') int postId,
    @Header('Authorization') String token,
  );

  @GET('/api/posts/{postId}/likes')
  Future<List<UserLikeInfo>> getPostLikes(
    @Path('postId') int postId,
  );

  @GET('/api/user/liked-posts')
  Future<List<int>> getUserLikedPostIds(
    @Header('Authorization') String token,
  );
}
