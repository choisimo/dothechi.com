package nodove.com.community.repository

import nodove.com.community.domain.Category
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface CategoryRepository : JpaRepository<Category, Long> {

    // 활성화된 카테고리 목록
    fun findByIsActiveTrue(): List<Category>

    // 이름으로 카테고리 찾기
    fun findByName(name: String): Category?

    // 인기 카테고리 (게시물 수 많은 순)
    @Query("SELECT c FROM Category c WHERE c.isActive = true ORDER BY c.postCount DESC")
    fun findPopularCategories(): List<Category>
}
