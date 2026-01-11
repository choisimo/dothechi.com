package nodove.com.community.service

import nodove.com.community.dto.CategoryDto
import nodove.com.community.repository.CategoryRepository
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service

@Service
class CategoryService(
    private val categoryRepository: CategoryRepository
) {

    fun getAllCategories(): List<CategoryDto> {
        return categoryRepository.findAllByOrderBySortOrderAsc()
            .filter { it.isActive }
            .map { CategoryDto.from(it) }
    }

    fun getPopularCategories(limit: Int): List<CategoryDto> {
        val pageable = PageRequest.of(0, limit)
        return categoryRepository.findPopular(pageable).map { CategoryDto.from(it) }
    }

    fun getCategoryBySlug(slug: String): CategoryDto? {
        return categoryRepository.findBySlug(slug)?.let { CategoryDto.from(it) }
    }
}
