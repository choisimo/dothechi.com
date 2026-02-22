package nodove.com.community.repository

import nodove.com.community.domain.comment.Comment
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface CommentRepository : JpaRepository<Comment, Long> {
    fun findByIdAndDeletedAtIsNull(id: Long): Comment?
    fun findAllByPostIdAndDeletedAtIsNullAndParentIdIsNull(postId: Long, pageable: Pageable): Page<Comment>
    fun findAllByParentIdAndDeletedAtIsNull(parentId: Long): List<Comment>

    @Modifying
    @Query("UPDATE Comment c SET c.likeCount = c.likeCount + 1 WHERE c.id = :id")
    fun incrementLikeCount(id: Long)

    @Modifying
    @Query("UPDATE Comment c SET c.likeCount = c.likeCount - 1 WHERE c.id = :id AND c.likeCount > 0")
    fun decrementLikeCount(id: Long)
}
