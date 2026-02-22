package nodove.com.community.controller

import jakarta.servlet.http.HttpServletRequest
import nodove.com.community.dto.response.ApiResponse
import nodove.com.community.service.PostService
import nodove.com.community.util.JwtTokenUtil
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/search")
class SearchController(
    private val postService: PostService,
    private val jwtTokenUtil: JwtTokenUtil
) {
    @GetMapping
    fun searchPosts(
        @RequestParam query: String,
        @RequestParam(defaultValue = "1") page: Int,
        @RequestParam(defaultValue = "10") limit: Int,
        @RequestParam category: String?,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Any>> {
        val userId = request.extractUserIdOrNull(jwtTokenUtil)
        val result = postService.searchPosts(query, page, limit, category, userId)
        return ResponseEntity.ok(ApiResponse.ok(result))
    }

    @GetMapping("/suggestions")
    fun getSearchSuggestions(
        @RequestParam query: String,
        @RequestParam(defaultValue = "5") limit: Int
    ): ResponseEntity<ApiResponse<Any>> {
        val result = postService.getSearchSuggestions(query, limit)
        return ResponseEntity.ok(ApiResponse.ok(result))
    }
}
