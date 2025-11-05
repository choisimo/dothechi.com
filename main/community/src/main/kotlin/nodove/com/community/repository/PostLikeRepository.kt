package nodove.com.community.repository

import nodove.com.community.domain.PostLike
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface PostLikeRepository : JpaRepository<PostLike, Long> {

    // 사용자가 특정 게시물을 좋아요 했는지 확인
    fun existsByPostIdAndUserId(postId: Long, userId: String): Boolean

    // 특정 게시물의 사용자 좋아요 찾기
    fun findByPostIdAndUserId(postId: Long, userId: String): PostLike?

    // 사용자가 좋아요한 게시물 ID 목록
    fun findAllByUserId(userId: String): List<PostLike>

    // 특정 게시물의 좋아요 수
    fun countByPostId(postId: Long): Long

    // 사용자가 좋아요한 게시물 목록 (postId만)
    fun findPostIdsByUserId(userId: String): List<Long>
}
