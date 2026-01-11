package nodove.com.community.entity

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import org.springframework.data.mongodb.core.index.Indexed
import java.time.LocalDateTime

@Document(collection = "user_interactions")
data class UserInteraction(
    @Id
    val id: String? = null,
    
    @Indexed
    val userId: Long,
    
    @Indexed
    val postId: Long,
    
    val action: String,
    
    val category: String?,
    
    val tags: List<String>?,
    
    val createdAt: LocalDateTime = LocalDateTime.now()
)

@Document(collection = "user_preferences")
data class UserPreference(
    @Id
    val id: String? = null,
    
    @Indexed(unique = true)
    val userId: Long,
    
    val categoryScores: Map<String, Double> = emptyMap(),
    
    val tagScores: Map<String, Double> = emptyMap(),
    
    val viewedPostIds: List<Long> = emptyList(),
    
    val likedPostIds: List<Long> = emptyList(),
    
    val updatedAt: LocalDateTime = LocalDateTime.now()
)
