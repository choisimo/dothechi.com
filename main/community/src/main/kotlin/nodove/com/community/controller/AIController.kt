package nodove.com.community.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import nodove.com.community.dto.*
import nodove.com.community.service.AIRecommendationService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@Tag(name = "AI Recommendations", description = "AI 기반 추천 API")
@RestController
@RequestMapping("/api/ai")
class AIController(
    private val aiRecommendationService: AIRecommendationService
) {

    @Operation(summary = "개인화 추천 게시물 조회")
    @GetMapping("/recommendations")
    fun getPersonalizedRecommendations(
        @RequestHeader("X-User-Id") userId: Long,
        @RequestParam(required = false) preferredCategories: List<String>?,
        @RequestParam(required = false) preferredTags: List<String>?,
        @RequestParam(defaultValue = "10") limit: Int
    ): ResponseEntity<List<RecommendedPostDto>> {
        val recommendations = aiRecommendationService.getPersonalizedRecommendations(
            userId, preferredCategories, preferredTags, limit
        )
        return ResponseEntity.ok(recommendations)
    }

    @Operation(summary = "유사 게시물 조회")
    @GetMapping("/posts/{postId}/similar")
    fun getSimilarPosts(
        @PathVariable postId: Long,
        @RequestParam(defaultValue = "5") limit: Int
    ): ResponseEntity<List<SimilarPostDto>> {
        val similarPosts = aiRecommendationService.getSimilarPosts(postId, limit)
        return ResponseEntity.ok(similarPosts)
    }

    @Operation(summary = "트렌딩 토픽 조회")
    @GetMapping("/trending")
    fun getTrendingTopics(): ResponseEntity<List<TrendingTopicDto>> {
        val topics = aiRecommendationService.getTrendingTopics()
        return ResponseEntity.ok(topics)
    }

    @Operation(summary = "사용자 상호작용 기록")
    @PostMapping("/interactions")
    fun recordInteraction(
        @RequestBody dto: UserInteractionDto
    ): ResponseEntity<Unit> {
        aiRecommendationService.recordInteraction(dto)
        return ResponseEntity.ok().build()
    }

    @Operation(summary = "AI 스마트 검색")
    @GetMapping("/search")
    fun smartSearch(
        @RequestParam query: String,
        @RequestParam(defaultValue = "1") page: Int,
        @RequestParam(defaultValue = "10") limit: Int
    ): ResponseEntity<AISearchResponse> {
        val response = aiRecommendationService.smartSearch(query, page, limit)
        return ResponseEntity.ok(response)
    }
}
