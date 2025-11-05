package nodove.com.community.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.responses.ApiResponses
import io.swagger.v3.oas.annotations.responses.ApiResponse as SwaggerApiResponse
import jakarta.servlet.http.HttpServletRequest
import nodove.com.community.dto.*
import nodove.com.community.service.PostService
import nodove.com.community.util.JwtUtil
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/posts")
class PostController(
    private val postService: PostService,
    private val jwtUtil: JwtUtil
) {

    @Operation(summary = "게시물 목록 조회", description = "게시물 목록을 페이징하여 조회합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "조회 성공"),
        SwaggerApiResponse(responseCode = "400", description = "잘못된 요청"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @GetMapping
    fun getPosts(
        @RequestParam(defaultValue = "1") page: Int,
        @RequestParam(defaultValue = "10") limit: Int,
        @RequestParam(required = false) category: Long?,
        @RequestParam(defaultValue = "latest") sort: String
    ): ResponseEntity<ApiResponse<PostListResponse>> {
        val result = postService.getPosts(page, limit, category, sort)
        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = "게시물 목록 조회 성공",
            code = "POSTS_GET_SUCCESS",
            data = result
        ))
    }

    @Operation(summary = "게시물 상세 조회", description = "특정 게시물의 상세 정보를 조회합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "조회 성공"),
        SwaggerApiResponse(responseCode = "404", description = "게시물을 찾을 수 없음"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @GetMapping("/{id}")
    fun getPost(
        @PathVariable id: Long,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<PostResponse>> {
        val userId = extractUserId(request)

        // 조회수 증가
        postService.incrementViewCount(id)

        val post = postService.getPost(id, userId)
        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = "게시물 조회 성공",
            code = "POST_GET_SUCCESS",
            data = post
        ))
    }

    @Operation(summary = "게시물 작성", description = "새로운 게시물을 작성합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "작성 성공"),
        SwaggerApiResponse(responseCode = "400", description = "잘못된 요청"),
        SwaggerApiResponse(responseCode = "401", description = "인증 실패"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @PostMapping
    fun createPost(
        @RequestBody postRequest: PostCreateRequest,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<PostResponse>> {
        val userId = extractUserId(request)
            ?: return ResponseEntity.status(401).body(ApiResponse(
                status = "error",
                message = "인증이 필요합니다.",
                code = "UNAUTHORIZED"
            ))

        val userNickname = extractUserNickname(request) ?: "익명"

        val post = postService.createPost(postRequest, userId, userNickname)
        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = "게시물 작성 성공",
            code = "POST_CREATE_SUCCESS",
            data = post
        ))
    }

    @Operation(summary = "게시물 수정", description = "기존 게시물을 수정합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "수정 성공"),
        SwaggerApiResponse(responseCode = "400", description = "잘못된 요청"),
        SwaggerApiResponse(responseCode = "401", description = "인증 실패"),
        SwaggerApiResponse(responseCode = "403", description = "권한 없음"),
        SwaggerApiResponse(responseCode = "404", description = "게시물을 찾을 수 없음"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @PutMapping("/{id}")
    fun updatePost(
        @PathVariable id: Long,
        @RequestBody updateRequest: PostUpdateRequest,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<PostResponse>> {
        val userId = extractUserId(request)
            ?: return ResponseEntity.status(401).body(ApiResponse(
                status = "error",
                message = "인증이 필요합니다.",
                code = "UNAUTHORIZED"
            ))

        val post = postService.updatePost(id, updateRequest, userId)
        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = "게시물 수정 성공",
            code = "POST_UPDATE_SUCCESS",
            data = post
        ))
    }

    @Operation(summary = "게시물 삭제", description = "게시물을 삭제합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "삭제 성공"),
        SwaggerApiResponse(responseCode = "401", description = "인증 실패"),
        SwaggerApiResponse(responseCode = "403", description = "권한 없음"),
        SwaggerApiResponse(responseCode = "404", description = "게시물을 찾을 수 없음"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @DeleteMapping("/{id}")
    fun deletePost(
        @PathVariable id: Long,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Unit>> {
        val userId = extractUserId(request)
            ?: return ResponseEntity.status(401).body(ApiResponse(
                status = "error",
                message = "인증이 필요합니다.",
                code = "UNAUTHORIZED"
            ))

        postService.deletePost(id, userId)
        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = "게시물 삭제 성공",
            code = "POST_DELETE_SUCCESS"
        ))
    }

    @Operation(summary = "최신 게시물 조회", description = "최신 게시물 목록을 조회합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "조회 성공"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @GetMapping("/latest")
    fun getLatestPosts(
        @RequestParam(defaultValue = "10") limit: Int
    ): ResponseEntity<ApiResponse<Map<String, List<PostSummaryResponse>>>> {
        val posts = postService.getLatestPosts(limit)
        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = "최신 게시물 조회 성공",
            code = "LATEST_POSTS_GET_SUCCESS",
            data = mapOf("posts" to posts)
        ))
    }

    @Operation(summary = "추천 게시물 조회", description = "추천 게시물 목록을 조회합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "조회 성공"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @GetMapping("/recommended")
    fun getRecommendedPosts(
        @RequestParam(defaultValue = "5") limit: Int
    ): ResponseEntity<ApiResponse<Map<String, List<PostSummaryResponse>>>> {
        val posts = postService.getRecommendedPosts(limit)
        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = "추천 게시물 조회 성공",
            code = "RECOMMENDED_POSTS_GET_SUCCESS",
            data = mapOf("posts" to posts)
        ))
    }

    @Operation(summary = "게시물 좋아요 토글", description = "게시물 좋아요를 추가하거나 취소합니다.")
    @ApiResponses(value = [
        SwaggerApiResponse(responseCode = "200", description = "성공"),
        SwaggerApiResponse(responseCode = "401", description = "인증 실패"),
        SwaggerApiResponse(responseCode = "404", description = "게시물을 찾을 수 없음"),
        SwaggerApiResponse(responseCode = "500", description = "서버 오류")
    ])
    @PostMapping("/{id}/like")
    fun toggleLike(
        @PathVariable id: Long,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Map<String, Boolean>>> {
        val userId = extractUserId(request)
            ?: return ResponseEntity.status(401).body(ApiResponse(
                status = "error",
                message = "인증이 필요합니다.",
                code = "UNAUTHORIZED"
            ))

        val isLiked = postService.toggleLike(id, userId)
        return ResponseEntity.ok(ApiResponse(
            status = "success",
            message = if (isLiked) "좋아요 추가" else "좋아요 취소",
            code = if (isLiked) "LIKE_ADDED" else "LIKE_REMOVED",
            data = mapOf("isLiked" to isLiked)
        ))
    }

    private fun extractUserId(request: HttpServletRequest): String? {
        val authHeader = request.getHeader("Authorization") ?: return null
        if (!authHeader.startsWith("Bearer ")) return null
        val token = authHeader.substring(7)
        return jwtUtil.extractUserId(token)
    }

    private fun extractUserNickname(request: HttpServletRequest): String? {
        val authHeader = request.getHeader("Authorization") ?: return null
        if (!authHeader.startsWith("Bearer ")) return null
        val token = authHeader.substring(7)
        return jwtUtil.extractUserNickname(token)
    }
}
