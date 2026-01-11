package nodove.com.community.repository

import nodove.com.community.entity.Post
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface PostRepository : JpaRepository<Post, Long> {

    fun findByCategory(category: String, pageable: Pageable): Page<Post>
    
    fun findByCategoryIn(categories: List<String>, pageable: Pageable): Page<Post>

    @Query("SELECT p FROM Post p ORDER BY p.viewCount DESC, p.likeCount DESC")
    fun findRecommended(pageable: Pageable): List<Post>

    @Query("SELECT p FROM Post p ORDER BY p.createdAt DESC")
    fun findLatest(pageable: Pageable): List<Post>

    fun findByAuthorId(authorId: Long, pageable: Pageable): Page<Post>

    @Query("SELECT p FROM Post p WHERE p.title LIKE %:keyword% OR p.content LIKE %:keyword%")
    fun searchByKeyword(keyword: String, pageable: Pageable): Page<Post>

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
}
