package nodove.com.community.repository

import nodove.com.community.domain.like.CommentLike
import nodove.com.community.domain.like.PostLike
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface PostLikeRepository : JpaRepository<PostLike, Long> {
    fun findByPostIdAndUserId(postId: Long, userId: String): PostLike?
    fun existsByPostIdAndUserId(postId: Long, userId: String): Boolean
    fun findAllByPostId(postId: Long): List<PostLike>
    fun findAllByUserId(userId: String, pageable: Pageable): Page<PostLike>
    fun deleteByPostIdAndUserId(postId: Long, userId: String)
}

@Repository
interface CommentLikeRepository : JpaRepository<CommentLike, Long> {
    fun findByCommentIdAndUserId(commentId: Long, userId: String): CommentLike?
    fun existsByCommentIdAndUserId(commentId: Long, userId: String): Boolean
    fun deleteByCommentIdAndUserId(commentId: Long, userId: String)
}
