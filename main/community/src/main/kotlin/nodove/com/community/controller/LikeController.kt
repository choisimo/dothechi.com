package nodove.com.community.controller

import jakarta.servlet.http.HttpServletRequest
import nodove.com.community.dto.response.ApiResponse
import nodove.com.community.service.LikeService
import nodove.com.community.util.JwtTokenUtil
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api")
class LikeController(
    private val likeService: LikeService,
    private val jwtTokenUtil: JwtTokenUtil
) {
    @PostMapping("/posts/{postId}/like")
    fun likePost(
        @PathVariable postId: Long,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Unit>> {
        val claims = request.extractClaims(jwtTokenUtil)
        likeService.likePost(postId, claims.userId)
        return ResponseEntity.ok(ApiResponse.ok(Unit, "게시물에 좋아요를 눌렀습니다."))
    }

    @DeleteMapping("/posts/{postId}/like")
    fun unlikePost(
        @PathVariable postId: Long,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Unit>> {
        val claims = request.extractClaims(jwtTokenUtil)
        likeService.unlikePost(postId, claims.userId)
        return ResponseEntity.ok(ApiResponse.ok(Unit, "게시물 좋아요를 취소했습니다."))
    }

    @GetMapping("/posts/{postId}/likes")
    fun getPostLikes(
        @PathVariable postId: Long,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Any>> {
        request.extractClaims(jwtTokenUtil) // auth check
        val result = likeService.getPostLikes(postId)
        return ResponseEntity.ok(ApiResponse.ok(result))
    }

    @GetMapping("/user/liked-posts")
    fun getUserLikedPosts(
        @RequestParam(defaultValue = "1") page: Int,
        @RequestParam(defaultValue = "10") limit: Int,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Any>> {
        val claims = request.extractClaims(jwtTokenUtil)
        val result = likeService.getUserLikedPosts(claims.userId, page, limit)
        return ResponseEntity.ok(ApiResponse.ok(result))
    }
}
