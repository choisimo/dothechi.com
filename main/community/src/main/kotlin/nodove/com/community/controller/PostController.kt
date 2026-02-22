package nodove.com.community.controller

import jakarta.servlet.http.HttpServletRequest
import nodove.com.community.dto.request.CreatePostRequest
import nodove.com.community.dto.request.UpdatePostRequest
import nodove.com.community.dto.response.ApiResponse
import nodove.com.community.service.CategoryService
import nodove.com.community.service.PostService
import nodove.com.community.util.JwtTokenUtil
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api")
class PostController(
    private val postService: PostService,
    private val categoryService: CategoryService,
    private val jwtTokenUtil: JwtTokenUtil
) {
    @GetMapping("/posts")
    fun getPosts(
        @RequestParam(defaultValue = "1") page: Int,
        @RequestParam(defaultValue = "10") limit: Int,
        @RequestParam category: String?,
        @RequestParam(defaultValue = "latest") sort: String,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Any>> {
        val userId = request.extractUserIdOrNull(jwtTokenUtil)
        val result = postService.getPosts(page, limit, category, sort, userId)
        return ResponseEntity.ok(ApiResponse.ok(result))
    }

    @GetMapping("/posts/recommended")
    fun getRecommendedPosts(
        @RequestParam(defaultValue = "5") limit: Int,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Any>> {
        val userId = request.extractUserIdOrNull(jwtTokenUtil)
        val result = postService.getRecommendedPosts(limit, userId)
        return ResponseEntity.ok(ApiResponse.ok(result))
    }

    @GetMapping("/posts/latest")
    fun getLatestPosts(
        @RequestParam(defaultValue = "10") limit: Int,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Any>> {
        val userId = request.extractUserIdOrNull(jwtTokenUtil)
        val result = postService.getLatestPosts(limit, userId)
        return ResponseEntity.ok(ApiResponse.ok(result))
    }

    @GetMapping("/posts/{id}")
    fun getPost(
        @PathVariable id: Long,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Any>> {
        val userId = request.extractUserIdOrNull(jwtTokenUtil)
        val result = postService.getPost(id, userId)
        return ResponseEntity.ok(ApiResponse.ok(result))
    }

    @PostMapping("/posts")
    fun createPost(
        @RequestBody body: CreatePostRequest,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Any>> {
        val claims = request.extractClaims(jwtTokenUtil)
        val result = postService.createPost(body, claims.userId, claims.userNick, claims.email)
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(result, "게시물이 작성되었습니다."))
    }

    @PutMapping("/posts/{id}")
    fun updatePost(
        @PathVariable id: Long,
        @RequestBody body: UpdatePostRequest,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Any>> {
        val claims = request.extractClaims(jwtTokenUtil)
        val result = postService.updatePost(id, body, claims.userId)
        return ResponseEntity.ok(ApiResponse.ok(result, "게시물이 수정되었습니다."))
    }

    @DeleteMapping("/posts/{id}")
    fun deletePost(
        @PathVariable id: Long,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Unit>> {
        val claims = request.extractClaims(jwtTokenUtil)
        postService.deletePost(id, claims.userId)
        return ResponseEntity.ok(ApiResponse.ok(Unit, "게시물이 삭제되었습니다."))
    }

    @GetMapping("/categories")
    fun getCategories(): ResponseEntity<ApiResponse<Any>> {
        val result = categoryService.getCategories()
        return ResponseEntity.ok(ApiResponse.ok(result))
    }

    @GetMapping("/categories/popular")
    fun getPopularCategories(
        @RequestParam(defaultValue = "5") limit: Int
    ): ResponseEntity<ApiResponse<Any>> {
        val result = categoryService.getPopularCategories(limit)
        return ResponseEntity.ok(ApiResponse.ok(result))
    }
}
