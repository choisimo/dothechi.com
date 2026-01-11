package nodove.com.community.service

import nodove.com.community.dto.*
import nodove.com.community.entity.Post
import nodove.com.community.entity.UserInteraction
import nodove.com.community.entity.UserPreference
import nodove.com.community.repository.PostRepository
import nodove.com.community.repository.UserInteractionRepository
import nodove.com.community.repository.UserPreferenceRepository
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Sort
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime
import kotlin.math.min

@Service
class AIRecommendationService(
    private val postRepository: PostRepository,
    private val userInteractionRepository: UserInteractionRepository,
    private val userPreferenceRepository: UserPreferenceRepository
) {
    
    fun getPersonalizedRecommendations(
        userId: Long,
        preferredCategories: List<String>?,
        preferredTags: List<String>?,
        limit: Int
    ): List<RecommendedPostDto> {
        val userPreference = userPreferenceRepository.findByUserId(userId)
        
        val categoryScores = userPreference?.categoryScores ?: emptyMap()
        val tagScores = userPreference?.tagScores ?: emptyMap()
        val viewedPostIds = userPreference?.viewedPostIds ?: emptyList()
        
        val topCategories = (preferredCategories ?: categoryScores.entries
            .sortedByDescending { it.value }
            .take(3)
            .map { it.key })
        
        val posts = if (topCategories.isNotEmpty()) {
            postRepository.findByCategoryIn(topCategories, PageRequest.of(0, limit * 2))
        } else {
            postRepository.findAll(PageRequest.of(0, limit * 2, Sort.by(Sort.Direction.DESC, "viewCount")))
        }
        
        return posts.content
            .filter { it.id !in viewedPostIds }
            .take(limit)
            .map { post ->
                val score = calculateRecommendationScore(post, categoryScores, tagScores)
                val reason = generateRecommendationReason(post, categoryScores)
                
                RecommendedPostDto(
                    id = post.id,
                    title = post.title,
                    content = post.content,
                    excerpt = post.content.take(150) + if (post.content.length > 150) "..." else "",
                    category = post.category,
                    authorId = post.authorId,
                    authorName = post.authorName,
                    viewCount = post.viewCount,
                    likeCount = post.likeCount,
                    createdAt = post.createdAt,
                    isRecommended = true,
                    recommendationScore = score,
                    recommendationReason = reason
                )
            }
    }
    
    fun getSimilarPosts(postId: Long, limit: Int = 5): List<SimilarPostDto> {
        val post = postRepository.findById(postId).orElse(null) ?: return emptyList()
        
        val similarPosts = postRepository.findByCategory(post.category, PageRequest.of(0, limit + 1))
            .filter { it.id != postId }
            .take(limit)
        
        return similarPosts.map { similar ->
            val similarity = calculateSimilarity(post, similar)
            SimilarPostDto(
                id = similar.id,
                title = similar.title,
                excerpt = similar.content.take(100) + "...",
                similarity = similarity
            )
        }
    }
    
    fun getTrendingTopics(): List<TrendingTopicDto> {
        val recentInteractions = userInteractionRepository
            .findByUserIdAndCreatedAtAfter(0, LocalDateTime.now().minusDays(7))
        
        val categoryTrends = postRepository.findAll(PageRequest.of(0, 100))
            .groupBy { it.category }
            .map { (category, posts) ->
                TrendingTopicDto(
                    topic = category,
                    count = posts.size,
                    growth = calculateGrowth(category),
                    description = getCategoryDescription(category)
                )
            }
            .sortedByDescending { it.count }
            .take(10)
        
        return categoryTrends
    }
    
    @Transactional
    fun recordInteraction(dto: UserInteractionDto) {
        val interaction = UserInteraction(
            userId = dto.userId,
            postId = dto.postId,
            action = dto.action,
            category = dto.category,
            tags = dto.tags,
            createdAt = dto.timestamp
        )
        userInteractionRepository.save(interaction)
        
        updateUserPreference(dto)
    }
    
    private fun updateUserPreference(dto: UserInteractionDto) {
        val existing = userPreferenceRepository.findByUserId(dto.userId)
        val weight = when (dto.action) {
            "view" -> 1.0
            "like" -> 3.0
            "comment" -> 2.0
            "share" -> 4.0
            else -> 0.5
        }
        
        val updatedCategoryScores = existing?.categoryScores?.toMutableMap() ?: mutableMapOf()
        dto.category?.let { category ->
            updatedCategoryScores[category] = (updatedCategoryScores[category] ?: 0.0) + weight
        }
        
        val updatedTagScores = existing?.tagScores?.toMutableMap() ?: mutableMapOf()
        dto.tags?.forEach { tag ->
            updatedTagScores[tag] = (updatedTagScores[tag] ?: 0.0) + weight
        }
        
        val updatedViewedPosts = (existing?.viewedPostIds?.toMutableList() ?: mutableListOf()).also {
            if (dto.action == "view" && dto.postId !in it) {
                it.add(dto.postId)
                if (it.size > 100) it.removeAt(0)
            }
        }
        
        val updatedLikedPosts = (existing?.likedPostIds?.toMutableList() ?: mutableListOf()).also {
            if (dto.action == "like" && dto.postId !in it) {
                it.add(dto.postId)
            }
        }
        
        val preference = UserPreference(
            id = existing?.id,
            userId = dto.userId,
            categoryScores = updatedCategoryScores,
            tagScores = updatedTagScores,
            viewedPostIds = updatedViewedPosts,
            likedPostIds = updatedLikedPosts,
            updatedAt = LocalDateTime.now()
        )
        
        userPreferenceRepository.save(preference)
    }
    
    fun smartSearch(query: String, page: Int, limit: Int): AISearchResponse {
        val searchResult = postRepository.searchByKeyword(query, PageRequest.of(page - 1, limit))
        
        val relatedTopics = extractRelatedTopics(query)
        val suggestedQueries = generateSuggestedQueries(query)
        
        return AISearchResponse(
            posts = searchResult.content.map { PostDto.from(it) },
            relatedTopics = relatedTopics,
            suggestedQueries = suggestedQueries,
            totalCount = searchResult.totalElements
        )
    }
    
    private fun calculateRecommendationScore(
        post: Post,
        categoryScores: Map<String, Double>,
        tagScores: Map<String, Double>
    ): Double {
        var score = 0.5
        
        score += (categoryScores[post.category] ?: 0.0) * 0.3
        score += (post.likeCount / 100.0).coerceAtMost(0.2)
        score += (post.viewCount / 1000.0).coerceAtMost(0.1)
        
        val daysSinceCreation = java.time.Duration.between(post.createdAt, LocalDateTime.now()).toDays()
        score -= (daysSinceCreation / 30.0).coerceAtMost(0.1)
        
        return score.coerceIn(0.0, 1.0)
    }
    
    private fun generateRecommendationReason(post: Post, categoryScores: Map<String, Double>): String {
        return when {
            categoryScores.containsKey(post.category) -> 
                "${post.category} 카테고리에 관심이 많으시네요"
            post.likeCount > 50 -> 
                "많은 사람들이 좋아하는 인기 글입니다"
            post.viewCount > 500 -> 
                "조회수가 높은 인기 콘텐츠입니다"
            else -> 
                "새롭게 추천드리는 콘텐츠입니다"
        }
    }
    
    private fun calculateSimilarity(post1: Post, post2: Post): Double {
        var similarity = 0.0
        
        if (post1.category == post2.category) similarity += 0.5
        
        val words1 = post1.title.lowercase().split(" ").toSet()
        val words2 = post2.title.lowercase().split(" ").toSet()
        val commonWords = words1.intersect(words2)
        similarity += (commonWords.size.toDouble() / maxOf(words1.size, words2.size)) * 0.3
        
        similarity += 0.2
        
        return similarity.coerceIn(0.0, 1.0)
    }
    
    private fun calculateGrowth(category: String): Double = 0.1 + (Math.random() * 0.4)
    
    private fun getCategoryDescription(category: String): String {
        return when (category) {
            "tech" -> "기술 관련 토론과 정보"
            "life" -> "일상 이야기와 팁"
            "news" -> "최신 뉴스와 소식"
            else -> "$category 관련 콘텐츠"
        }
    }
    
    private fun extractRelatedTopics(query: String): List<String> {
        val keywords = query.split(" ").filter { it.length > 1 }
        return keywords.take(3)
    }
    
    private fun generateSuggestedQueries(query: String): List<String> {
        return listOf(
            "$query 시작하기",
            "$query 심화",
            "$query 실전 예제"
        )
    }
}
