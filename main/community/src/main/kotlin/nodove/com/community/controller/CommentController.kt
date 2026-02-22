package nodove.com.community.controller

import jakarta.servlet.http.HttpServletRequest
import nodove.com.community.dto.request.CreateCommentRequest
import nodove.com.community.dto.request.UpdateCommentRequest
import nodove.com.community.dto.response.ApiResponse
import nodove.com.community.service.CommentService
import nodove.com.community.util.JwtTokenUtil
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api")
class CommentController(
    private val commentService: CommentService,
    private val jwtTokenUtil: JwtTokenUtil
) {
    @GetMapping("/posts/{postId}/comments")
    fun getComments(
        @PathVariable postId: Long,
        @RequestParam(defaultValue = "1") page: Int,
        @RequestParam(defaultValue = "20") limit: Int,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Any>> {
        val userId = request.extractUserIdOrNull(jwtTokenUtil)
        val result = commentService.getComments(postId, page, limit, userId)
        return ResponseEntity.ok(ApiResponse.ok(result))
    }

    @PostMapping("/posts/{postId}/comments")
    fun createComment(
        @PathVariable postId: Long,
        @RequestBody body: CreateCommentRequest,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Any>> {
        val claims = request.extractClaims(jwtTokenUtil)
        val result = commentService.createComment(postId, body, claims.userId, claims.userNick, claims.email)
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(result, "댓글이 작성되었습니다."))
    }

    @PostMapping("/comments/{commentId}/reply")
    fun replyToComment(
        @PathVariable commentId: Long,
        @RequestBody body: CreateCommentRequest,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Any>> {
        val claims = request.extractClaims(jwtTokenUtil)
        val result = commentService.replyToComment(commentId, body, claims.userId, claims.userNick, claims.email)
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(result, "대댓글이 작성되었습니다."))
    }

    @PutMapping("/comments/{commentId}")
    fun updateComment(
        @PathVariable commentId: Long,
        @RequestBody body: UpdateCommentRequest,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Any>> {
        val claims = request.extractClaims(jwtTokenUtil)
        val result = commentService.updateComment(commentId, body, claims.userId)
        return ResponseEntity.ok(ApiResponse.ok(result, "댓글이 수정되었습니다."))
    }

    @DeleteMapping("/comments/{commentId}")
    fun deleteComment(
        @PathVariable commentId: Long,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Unit>> {
        val claims = request.extractClaims(jwtTokenUtil)
        commentService.deleteComment(commentId, claims.userId)
        return ResponseEntity.ok(ApiResponse.ok(Unit, "댓글이 삭제되었습니다."))
    }

    @PostMapping("/comments/{commentId}/like")
    fun likeComment(
        @PathVariable commentId: Long,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Unit>> {
        val claims = request.extractClaims(jwtTokenUtil)
        commentService.likeComment(commentId, claims.userId)
        return ResponseEntity.ok(ApiResponse.ok(Unit, "댓글에 좋아요를 눌렀습니다."))
    }

    @DeleteMapping("/comments/{commentId}/like")
    fun unlikeComment(
        @PathVariable commentId: Long,
        request: HttpServletRequest
    ): ResponseEntity<ApiResponse<Unit>> {
        val claims = request.extractClaims(jwtTokenUtil)
        commentService.unlikeComment(commentId, claims.userId)
        return ResponseEntity.ok(ApiResponse.ok(Unit, "댓글 좋아요를 취소했습니다."))
    }
}
