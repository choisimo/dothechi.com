package nodove.com.community.dto

import nodove.com.community.domain.Category
import java.time.LocalDateTime

data class CategoryResponse(
    val id: Long,
    val name: String,
    val description: String?,
    val postCount: Int,
    val isActive: Boolean,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
) {
    companion object {
        fun fromEntity(category: Category): CategoryResponse {
            return CategoryResponse(
                id = category.id!!,
                name = category.name,
                description = category.description,
                postCount = category.postCount,
                isActive = category.isActive,
                createdAt = category.createdAt!!,
                updatedAt = category.updatedAt!!
            )
        }
    }
}

data class CategoryCreateRequest(
    val name: String,
    val description: String?
)

data class CategoryListResponse(
    val categories: List<CategoryResponse>
)
