package nodove.com.community.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import nodove.com.community.dto.*
import nodove.com.community.service.PostService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@Tag(name = "Posts", description = "게시물 관리 API")
@RestController
@RequestMapping("/api/posts")
class PostController(
    private val postService: PostService
) {

    @Operation(summary = "게시물 목록 조회")
    @GetMapping
    fun getPosts(
        @RequestParam(defaultValue = "1") page: Int,
        @RequestParam(defaultValue = "10") limit: Int,
        @RequestParam(required = false) category: String?,
        @RequestParam(defaultValue = "latest") sort: String
    ): ResponseEntity<PostListResponse> {
        val response = postService.getPosts(page, limit, category, sort)
        return ResponseEntity.ok(response)
    }

    @Operation(summary = "게시물 상세 조회")
    @GetMapping("/{id}")
    fun getPost(@PathVariable id: Long): ResponseEntity<PostDto> {
        val post = postService.getPost(id)
        return ResponseEntity.ok(post)
    }

    @Operation(summary = "게시물 작성")
    @PostMapping
    fun createPost(
        @RequestBody request: CreatePostRequest,
        @RequestHeader("X-User-Id") userId: Long,
        @RequestHeader("X-User-Name") userName: String,
        @RequestHeader("X-User-Avatar", required = false) userAvatar: String?
    ): ResponseEntity<PostDto> {
        val post = postService.createPost(request, userId, userName, userAvatar)
        return ResponseEntity.status(HttpStatus.CREATED).body(post)
    }

    @Operation(summary = "게시물 수정")
    @PutMapping("/{id}")
    fun updatePost(
        @PathVariable id: Long,
        @RequestBody request: UpdatePostRequest,
        @RequestHeader("X-User-Id") userId: Long
    ): ResponseEntity<PostDto> {
        val post = postService.updatePost(id, request, userId)
        return ResponseEntity.ok(post)
    }

    @Operation(summary = "게시물 삭제")
    @DeleteMapping("/{id}")
    fun deletePost(
        @PathVariable id: Long,
        @RequestHeader("X-User-Id") userId: Long
    ): ResponseEntity<Unit> {
        postService.deletePost(id, userId)
        return ResponseEntity.noContent().build()
    }

    @Operation(summary = "추천 게시물 조회")
    @GetMapping("/recommended")
    fun getRecommendedPosts(
        @RequestParam(defaultValue = "5") limit: Int
    ): ResponseEntity<List<PostDto>> {
        val posts = postService.getRecommendedPosts(limit)
        return ResponseEntity.ok(posts)
    }

    @Operation(summary = "최신 게시물 조회")
    @GetMapping("/latest")
    fun getLatestPosts(
        @RequestParam(defaultValue = "10") limit: Int
    ): ResponseEntity<List<PostDto>> {
        val posts = postService.getLatestPosts(limit)
        return ResponseEntity.ok(posts)
    }

    @Operation(summary = "게시물 검색")
    @GetMapping("/search")
    fun searchPosts(
        @RequestParam keyword: String,
        @RequestParam(defaultValue = "1") page: Int,
        @RequestParam(defaultValue = "10") limit: Int
    ): ResponseEntity<PostListResponse> {
        val response = postService.searchPosts(keyword, page, limit)
        return ResponseEntity.ok(response)
    }

    @Operation(summary = "게시물 좋아요")
    @PostMapping("/{id}/like")
    fun likePost(@PathVariable id: Long): ResponseEntity<Unit> {
        postService.likePost(id)
        return ResponseEntity.ok().build()
    }

    @Operation(summary = "게시물 좋아요 취소")
    @DeleteMapping("/{id}/like")
    fun unlikePost(@PathVariable id: Long): ResponseEntity<Unit> {
        postService.unlikePost(id)
        return ResponseEntity.noContent().build()
    }
}
