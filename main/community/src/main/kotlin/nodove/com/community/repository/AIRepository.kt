package nodove.com.community.repository

import nodove.com.community.entity.UserInteraction
import nodove.com.community.entity.UserPreference
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.data.mongodb.repository.Query
import org.springframework.stereotype.Repository
import java.time.LocalDateTime

@Repository
interface UserInteractionRepository : MongoRepository<UserInteraction, String> {
    fun findByUserId(userId: Long): List<UserInteraction>
    
    fun findByUserIdAndAction(userId: Long, action: String): List<UserInteraction>
    
    fun findByPostId(postId: Long): List<UserInteraction>
    
    fun findByUserIdAndCreatedAtAfter(userId: Long, after: LocalDateTime): List<UserInteraction>
    
    @Query("{ 'userId': ?0, 'action': 'view' }")
    fun findViewsByUserId(userId: Long): List<UserInteraction>
    
    @Query("{ 'userId': ?0, 'action': 'like' }")
    fun findLikesByUserId(userId: Long): List<UserInteraction>
}

@Repository
interface UserPreferenceRepository : MongoRepository<UserPreference, String> {
    fun findByUserId(userId: Long): UserPreference?
}
