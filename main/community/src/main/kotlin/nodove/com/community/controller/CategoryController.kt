package nodove.com.community.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import nodove.com.community.dto.CategoryDto
import nodove.com.community.service.CategoryService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@Tag(name = "Categories", description = "카테고리 관리 API")
@RestController
@RequestMapping("/api/categories")
class CategoryController(
    private val categoryService: CategoryService
) {

    @Operation(summary = "전체 카테고리 조회")
    @GetMapping
    fun getAllCategories(): ResponseEntity<List<CategoryDto>> {
        val categories = categoryService.getAllCategories()
        return ResponseEntity.ok(categories)
    }

    @Operation(summary = "인기 카테고리 조회")
    @GetMapping("/popular")
    fun getPopularCategories(
        @RequestParam(defaultValue = "5") limit: Int
    ): ResponseEntity<List<CategoryDto>> {
        val categories = categoryService.getPopularCategories(limit)
        return ResponseEntity.ok(categories)
    }

    @Operation(summary = "카테고리 상세 조회")
    @GetMapping("/{slug}")
    fun getCategoryBySlug(@PathVariable slug: String): ResponseEntity<CategoryDto> {
        val category = categoryService.getCategoryBySlug(slug)
            ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(category)
    }
}
