package nodove.com.community.dto

import java.time.LocalDateTime

data class UserInteractionDto(
    val userId: Long,
    val postId: Long,
    val action: String,
    val category: String?,
    val tags: List<String>?,
    val timestamp: LocalDateTime = LocalDateTime.now()
)

data class PersonalizedRecommendationRequest(
    val preferredCategories: List<String>?,
    val preferredTags: List<String>?,
    val limit: Int = 10
)

data class RecommendedPostDto(
    val id: Long,
    val title: String,
    val content: String,
    val excerpt: String?,
    val category: String,
    val authorId: Long,
    val authorName: String,
    val viewCount: Int,
    val likeCount: Int,
    val createdAt: LocalDateTime,
    val isRecommended: Boolean = true,
    val recommendationScore: Double,
    val recommendationReason: String?
)

data class SimilarPostDto(
    val id: Long,
    val title: String,
    val excerpt: String,
    val similarity: Double
)

data class TrendingTopicDto(
    val topic: String,
    val count: Int,
    val growth: Double,
    val description: String?
)

data class AISearchRequest(
    val query: String,
    val page: Int = 1,
    val limit: Int = 10
)

data class AISearchResponse(
    val posts: List<PostDto>,
    val relatedTopics: List<String>,
    val suggestedQueries: List<String>,
    val totalCount: Long
)
