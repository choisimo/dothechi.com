package nodove.com.community.service

import jakarta.transaction.Transactional
import nodove.com.community.domain.category.Category
import nodove.com.community.dto.response.CategoryResponse
import nodove.com.community.exception.ResourceNotFoundException
import nodove.com.community.repository.CategoryRepository
import nodove.com.community.repository.PostRepository
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service

@Service
@Transactional
class CategoryService(
    private val categoryRepository: CategoryRepository,
    private val postRepository: PostRepository
) {
    fun getCategories(): List<CategoryResponse> {
        return categoryRepository.findAllByIsActiveTrue().map { category ->
            CategoryResponse.from(category)
        }
    }

    fun getPopularCategories(limit: Int): List<CategoryResponse> {
        return categoryRepository.findPopularCategories(PageRequest.of(0, limit)).map { category ->
            CategoryResponse.from(category)
        }
    }

    fun getOrCreateCategory(name: String): Category {
        return categoryRepository.findByNameIgnoreCase(name)
            ?: categoryRepository.save(Category(name = name, description = name))
    }

    fun findById(id: Long): Category {
        return categoryRepository.findById(id).orElseThrow {
            ResourceNotFoundException("카테고리를 찾을 수 없습니다. id=$id")
        }
    }
}
