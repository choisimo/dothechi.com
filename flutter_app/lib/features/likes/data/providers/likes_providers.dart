import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../api/likes_api.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/providers/auth_providers.dart';

part 'likes_providers.g.dart';

@riverpod
LikesApi likesApi(LikesApiRef ref) {
  final dio = ref.watch(communityDioProvider);
  return LikesApi(dio);
}

@riverpod
class LikeNotifier extends _$LikeNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<LikeResponse?> toggleLike(int postId, bool currentlyLiked) async {
    state = const AsyncValue.loading();

    try {
      final tokenStorage = ref.read(tokenStorageProvider);
      final token = await tokenStorage.getAccessToken();

      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }

      final likesApi = ref.read(likesApiProvider);
      LikeResponse response;

      if (currentlyLiked) {
        response = await likesApi.unlikePost(postId, 'Bearer $token');
      } else {
        response = await likesApi.likePost(postId, 'Bearer $token');
      }

      state = const AsyncValue.data(null);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

@riverpod
Future<List<UserLikeInfo>> postLikes(PostLikesRef ref, int postId) async {
  final likesApi = ref.watch(likesApiProvider);
  return likesApi.getPostLikes(postId);
}

@riverpod
Future<List<int>> userLikedPostIds(UserLikedPostIdsRef ref) async {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final token = await tokenStorage.getAccessToken();

  if (token == null) {
    return [];
  }

  final likesApi = ref.watch(likesApiProvider);
  return likesApi.getUserLikedPostIds('Bearer $token');
}
