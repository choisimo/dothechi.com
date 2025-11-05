package nodove.com.community.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.responses.ApiResponses
import io.swagger.v3.oas.annotations.responses.ApiResponse as SwaggerApiResponse
import nodove.com.community.dto.ApiResponse
import nodove.com.community.dto.PostListResponse
import nodove.com.community.service.PostService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/search")
class SearchController(
    private val postService: PostService
) {

    @Operation(summary = "게시물 검색", description = "키워드로 게시물을 검색합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "검색 성공"),
        SwaggerApiResponse(responseCode = "400", description = "잘못된 요청"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @GetMapping
    fun searchPosts(
        @RequestParam query: String,
        @RequestParam(defaultValue = "1") page: Int,
        @RequestParam(defaultValue = "10") limit: Int,
        @RequestParam(required = false) category: Long?
    ): ResponseEntity<ApiResponse<Map<String, Any>>> {
        if (query.isBlank()) {
            return ResponseEntity.badRequest().body(ApiResponse(
                status = "error",
                message = "검색어를 입력해주세요.",
                code = "EMPTY_QUERY"
            ))
        }

        val result = postService.searchPosts(query, page, limit, category)

        val response = mapOf(
            "results" to result.posts,
            "pagination" to result.pagination,
            "searchQuery" to query
        )

        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = "검색 완료",
            code = "SEARCH_SUCCESS",
            data = response
        ))
    }
}
