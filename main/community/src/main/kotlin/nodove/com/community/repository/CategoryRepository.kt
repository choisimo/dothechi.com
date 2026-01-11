package nodove.com.community.repository

import nodove.com.community.entity.Category
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface CategoryRepository : JpaRepository<Category, Long> {

    fun findBySlug(slug: String): Category?

    fun findByIsActiveTrue(): List<Category>

    @Query("SELECT c FROM Category c WHERE c.isActive = true ORDER BY c.postCount DESC")
    fun findPopular(pageable: Pageable): List<Category>

    fun findAllByOrderBySortOrderAsc(): List<Category>
}
