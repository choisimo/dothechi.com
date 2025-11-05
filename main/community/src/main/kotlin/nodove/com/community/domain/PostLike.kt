package nodove.com.community.domain

import jakarta.persistence.*
import org.hibernate.annotations.CreationTimestamp
import java.time.LocalDateTime

@Entity
@Table(name = "post_likes",
    uniqueConstraints = [UniqueConstraint(columnNames = ["post_id", "user_id"])],
    indexes = [
        Index(name = "idx_user_id", columnList = "user_id"),
        Index(name = "idx_post_id", columnList = "post_id")
    ]
)
data class PostLike(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,

    @Column(name = "post_id", nullable = false)
    val postId: Long,

    @Column(name = "user_id", nullable = false)
    val userId: String, // Auth Service의 User ID 참조

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    val createdAt: LocalDateTime? = null
)
