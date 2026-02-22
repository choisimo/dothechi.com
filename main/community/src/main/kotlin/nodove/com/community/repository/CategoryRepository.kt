package nodove.com.community.repository

import nodove.com.community.domain.category.Category
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface CategoryRepository : JpaRepository<Category, Long> {
    fun findByNameIgnoreCase(name: String): Category?
    fun findAllByIsActiveTrue(): List<Category>

    @Query("SELECT c FROM Category c WHERE c.isActive = true ORDER BY (SELECT COUNT(p) FROM Post p WHERE p.category = c AND p.deletedAt IS NULL) DESC")
    fun findPopularCategories(pageable: org.springframework.data.domain.Pageable): List<Category>
}
