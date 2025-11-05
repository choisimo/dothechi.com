package nodove.com.community.service

import nodove.com.community.domain.Category
import nodove.com.community.dto.CategoryCreateRequest
import nodove.com.community.dto.CategoryListResponse
import nodove.com.community.dto.CategoryResponse
import nodove.com.community.repository.CategoryRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class CategoryService(
    private val categoryRepository: CategoryRepository
) {

    @Transactional
    fun createCategory(request: CategoryCreateRequest): CategoryResponse {
        // 중복 체크
        categoryRepository.findByName(request.name)?.let {
            throw IllegalArgumentException("이미 존재하는 카테고리 이름입니다.")
        }

        val category = Category(
            name = request.name,
            description = request.description
        )

        val savedCategory = categoryRepository.save(category)
        return CategoryResponse.fromEntity(savedCategory)
    }

    fun getCategories(): CategoryListResponse {
        val categories = categoryRepository.findByIsActiveTrue()
            .map { CategoryResponse.fromEntity(it) }
        return CategoryListResponse(categories)
    }

    fun getCategory(categoryId: Long): CategoryResponse {
        val category = categoryRepository.findById(categoryId)
            .orElseThrow { IllegalArgumentException("카테고리를 찾을 수 없습니다.") }
        return CategoryResponse.fromEntity(category)
    }

    fun getPopularCategories(limit: Int): CategoryListResponse {
        val categories = categoryRepository.findPopularCategories()
            .take(limit)
            .map { CategoryResponse.fromEntity(it) }
        return CategoryListResponse(categories)
    }

    @Transactional
    fun deleteCategory(categoryId: Long) {
        val category = categoryRepository.findById(categoryId)
            .orElseThrow { IllegalArgumentException("카테고리를 찾을 수 없습니다.") }

        if (category.postCount > 0) {
            throw IllegalArgumentException("게시물이 있는 카테고리는 삭제할 수 없습니다.")
        }

        categoryRepository.delete(category)
    }

    @Transactional
    fun toggleCategoryStatus(categoryId: Long): CategoryResponse {
        val category = categoryRepository.findById(categoryId)
            .orElseThrow { IllegalArgumentException("카테고리를 찾을 수 없습니다.") }

        category.isActive = !category.isActive
        val updatedCategory = categoryRepository.save(category)
        return CategoryResponse.fromEntity(updatedCategory)
    }
}
