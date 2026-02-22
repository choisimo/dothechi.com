package nodove.com.community.service

import jakarta.transaction.Transactional
import nodove.com.community.domain.like.PostLike
import nodove.com.community.dto.response.PostResponse
import nodove.com.community.exception.ResourceNotFoundException
import nodove.com.community.repository.PostLikeRepository
import nodove.com.community.repository.PostRepository
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service

@Service
@Transactional
class LikeService(
    private val postLikeRepository: PostLikeRepository,
    private val postRepository: PostRepository
) {
    fun likePost(postId: Long, userId: String) {
        postRepository.findByIdAndDeletedAtIsNull(postId)
            ?: throw ResourceNotFoundException("게시물을 찾을 수 없습니다. id=$postId")
        if (postLikeRepository.existsByPostIdAndUserId(postId, userId)) return
        postLikeRepository.save(PostLike(postId = postId, userId = userId))
        postRepository.incrementLikeCount(postId)
    }

    fun unlikePost(postId: Long, userId: String) {
        if (!postLikeRepository.existsByPostIdAndUserId(postId, userId)) return
        postLikeRepository.deleteByPostIdAndUserId(postId, userId)
        postRepository.decrementLikeCount(postId)
    }

    fun getPostLikes(postId: Long): List<String> {
        return postLikeRepository.findAllByPostId(postId).map { it.userId }
    }

    fun getUserLikedPosts(userId: String, page: Int, limit: Int): List<PostResponse> {
        val pageable = PageRequest.of(page - 1, limit)
        val likedPostIds = postLikeRepository.findAllByUserId(userId, pageable).map { it.postId }
        return likedPostIds.mapNotNull { postId ->
            postRepository.findByIdAndDeletedAtIsNull(postId)?.let {
                PostResponse.from(it, true)
            }
        }
    }
}
