package nodove.com.community.dto

import nodove.com.community.entity.Category

data class CategoryDto(
    val id: Long,
    val slug: String,
    val name: String,
    val description: String?,
    val postCount: Int
) {
    companion object {
        fun from(category: Category): CategoryDto = CategoryDto(
            id = category.id,
            slug = category.slug,
            name = category.name,
            description = category.description,
            postCount = category.postCount
        )
    }
}
