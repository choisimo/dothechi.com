package nodove.com.community.repository

import nodove.com.community.domain.Post
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@Repository
interface PostRepository : JpaRepository<Post, Long> {

    // 삭제되지 않은 게시물 목록 (페이징)
    fun findByDeletedAtIsNull(pageable: Pageable): Page<Post>

    // 카테고리별 게시물 목록
    @Query("SELECT p FROM Post p WHERE p.category.id = :categoryId AND p.deletedAt IS NULL")
    fun findByCategoryId(@Param("categoryId") categoryId: Long, pageable: Pageable): Page<Post>

    // 작성자별 게시물 목록
    fun findByAuthorIdAndDeletedAtIsNull(authorId: String, pageable: Pageable): Page<Post>

    // 최신 게시물 (삭제되지 않은)
    @Query("SELECT p FROM Post p WHERE p.deletedAt IS NULL ORDER BY p.createdAt DESC")
    fun findLatestPosts(pageable: Pageable): List<Post>

    // 추천 게시물 (좋아요 많은 순)
    @Query("SELECT p FROM Post p WHERE p.deletedAt IS NULL ORDER BY p.likeCount DESC, p.viewCount DESC")
    fun findRecommendedPosts(pageable: Pageable): List<Post>

    // 인기 게시물 (조회수 많은 순)
    @Query("SELECT p FROM Post p WHERE p.deletedAt IS NULL ORDER BY p.viewCount DESC")
    fun findPopularPosts(pageable: Pageable): List<Post>

    // 검색 (제목 + 내용)
    @Query("""
        SELECT p FROM Post p
        WHERE p.deletedAt IS NULL
        AND (LOWER(p.title) LIKE LOWER(CONCAT('%', :query, '%'))
        OR LOWER(p.content) LIKE LOWER(CONCAT('%', :query, '%')))
    """)
    fun searchPosts(@Param("query") query: String, pageable: Pageable): Page<Post>

    // 카테고리별 검색
    @Query("""
        SELECT p FROM Post p
        WHERE p.deletedAt IS NULL
        AND p.category.id = :categoryId
        AND (LOWER(p.title) LIKE LOWER(CONCAT('%', :query, '%'))
        OR LOWER(p.content) LIKE LOWER(CONCAT('%', :query, '%')))
    """)
    fun searchPostsByCategory(
        @Param("query") query: String,
        @Param("categoryId") categoryId: Long,
        pageable: Pageable
    ): Page<Post>
}
