package nodove.com.community.repository

import nodove.com.community.domain.category.Category
import nodove.com.community.domain.post.Post
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface PostRepository : JpaRepository<Post, Long> {
    fun findByIdAndDeletedAtIsNull(id: Long): Post?
    fun findAllByDeletedAtIsNullAndCategory(category: Category, pageable: Pageable): Page<Post>
    fun findAllByDeletedAtIsNull(pageable: Pageable): Page<Post>

    @Query("SELECT p FROM Post p WHERE p.deletedAt IS NULL AND (LOWER(p.title) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(p.content) LIKE LOWER(CONCAT('%', :query, '%')))")
    fun searchByTitleOrContent(query: String, pageable: Pageable): Page<Post>

    @Query("SELECT p FROM Post p WHERE p.deletedAt IS NULL AND p.category = :category AND (LOWER(p.title) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(p.content) LIKE LOWER(CONCAT('%', :query, '%')))")
    fun searchByTitleOrContentAndCategory(query: String, category: Category, pageable: Pageable): Page<Post>

    @Query("SELECT p FROM Post p WHERE p.deletedAt IS NULL ORDER BY p.likeCount DESC, p.viewCount DESC")
    fun findRecommendedPosts(pageable: Pageable): List<Post>

    @Query("SELECT p FROM Post p WHERE p.deletedAt IS NULL ORDER BY p.createdAt DESC")
    fun findLatestPosts(pageable: Pageable): List<Post>

    @Modifying
    @Query("UPDATE Post p SET p.viewCount = p.viewCount + 1 WHERE p.id = :id")
    fun incrementViewCount(id: Long)

    @Modifying
    @Query("UPDATE Post p SET p.likeCount = p.likeCount + 1 WHERE p.id = :id")
    fun incrementLikeCount(id: Long)

    @Modifying
    @Query("UPDATE Post p SET p.likeCount = p.likeCount - 1 WHERE p.id = :id AND p.likeCount > 0")
    fun decrementLikeCount(id: Long)

    @Modifying
    @Query("UPDATE Post p SET p.commentCount = p.commentCount + 1 WHERE p.id = :id")
    fun incrementCommentCount(id: Long)

    @Modifying
    @Query("UPDATE Post p SET p.commentCount = p.commentCount - 1 WHERE p.id = :id AND p.commentCount > 0")
    fun decrementCommentCount(id: Long)

    @Query("SELECT DISTINCT p.title FROM Post p WHERE p.deletedAt IS NULL AND LOWER(p.title) LIKE LOWER(CONCAT('%', :query, '%')) ORDER BY p.title")
    fun findTitleSuggestions(query: String, pageable: Pageable): List<String>
}
