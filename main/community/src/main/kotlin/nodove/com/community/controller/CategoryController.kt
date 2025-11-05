package nodove.com.community.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.responses.ApiResponses
import io.swagger.v3.oas.annotations.responses.ApiResponse as SwaggerApiResponse
import nodove.com.community.dto.ApiResponse
import nodove.com.community.dto.CategoryCreateRequest
import nodove.com.community.dto.CategoryListResponse
import nodove.com.community.dto.CategoryResponse
import nodove.com.community.service.CategoryService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/categories")
class CategoryController(
    private val categoryService: CategoryService
) {

    @Operation(summary = "카테고리 목록 조회", description = "활성화된 모든 카테고리를 조회합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "조회 성공"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @GetMapping
    fun getCategories(): ResponseEntity<ApiResponse<CategoryListResponse>> {
        val categories = categoryService.getCategories()
        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = "카테고리 목록 조회 성공",
            code = "CATEGORIES_GET_SUCCESS",
            data = categories
        ))
    }

    @Operation(summary = "카테고리 상세 조회", description = "특정 카테고리의 상세 정보를 조회합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "조회 성공"),
        SwaggerApiResponse(responseCode = "404", description = "카테고리를 찾을 수 없음"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @GetMapping("/{id}")
    fun getCategory(@PathVariable id: Long): ResponseEntity<ApiResponse<CategoryResponse>> {
        val category = categoryService.getCategory(id)
        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = "카테고리 조회 성공",
            code = "CATEGORY_GET_SUCCESS",
            data = category
        ))
    }

    @Operation(summary = "인기 카테고리 조회", description = "게시물이 많은 인기 카테고리를 조회합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "조회 성공"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @GetMapping("/popular")
    fun getPopularCategories(
        @RequestParam(defaultValue = "5") limit: Int
    ): ResponseEntity<ApiResponse<CategoryListResponse>> {
        val categories = categoryService.getPopularCategories(limit)
        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = "인기 카테고리 조회 성공",
            code = "POPULAR_CATEGORIES_GET_SUCCESS",
            data = categories
        ))
    }

    @Operation(summary = "카테고리 생성", description = "새로운 카테고리를 생성합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "생성 성공"),
        SwaggerApiResponse(responseCode = "400", description = "잘못된 요청"),
        SwaggerApiResponse(responseCode = "401", description = "인증 실패"),
        SwaggerApiResponse(responseCode = "403", description = "권한 없음"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @PostMapping
    fun createCategory(
        @RequestBody request: CategoryCreateRequest
    ): ResponseEntity<ApiResponse<CategoryResponse>> {
        val category = categoryService.createCategory(request)
        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = "카테고리 생성 성공",
            code = "CATEGORY_CREATE_SUCCESS",
            data = category
        ))
    }

    @Operation(summary = "카테고리 삭제", description = "카테고리를 삭제합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "삭제 성공"),
        SwaggerApiResponse(responseCode = "400", description = "잘못된 요청"),
        SwaggerApiResponse(responseCode = "401", description = "인증 실패"),
        SwaggerApiResponse(responseCode = "403", description = "권한 없음"),
        SwaggerApiResponse(responseCode = "404", description = "카테고리를 찾을 수 없음"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @DeleteMapping("/{id}")
    fun deleteCategory(@PathVariable id: Long): ResponseEntity<ApiResponse<Unit>> {
        categoryService.deleteCategory(id)
        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = "카테고리 삭제 성공",
            code = "CATEGORY_DELETE_SUCCESS"
        ))
    }

    @Operation(summary = "카테고리 활성화 토글", description = "카테고리의 활성화 상태를 변경합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "성공"),
        SwaggerApiResponse(responseCode = "401", description = "인증 실패"),
        SwaggerApiResponse(responseCode = "403", description = "권한 없음"),
        SwaggerApiResponse(responseCode = "404", description = "카테고리를 찾을 수 없음"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @PatchMapping("/{id}/toggle")
    fun toggleCategoryStatus(@PathVariable id: Long): ResponseEntity<ApiResponse<CategoryResponse>> {
        val category = categoryService.toggleCategoryStatus(id)
        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = "카테고리 상태 변경 성공",
            code = "CATEGORY_STATUS_TOGGLE_SUCCESS",
            data = category
        ))
    }
}
