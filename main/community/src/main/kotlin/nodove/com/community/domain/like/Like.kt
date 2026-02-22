package nodove.com.community.domain.like

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(
    name = "post_likes",
    uniqueConstraints = [UniqueConstraint(name = "uk_post_likes_post_user", columnNames = ["post_id", "user_id"])]
)
class PostLike(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(name = "post_id", nullable = false)
    val postId: Long,

    @Column(name = "user_id", nullable = false)
    val userId: String,

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now()
)

@Entity
@Table(
    name = "comment_likes",
    uniqueConstraints = [UniqueConstraint(name = "uk_comment_likes_comment_user", columnNames = ["comment_id", "user_id"])]
)
class CommentLike(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(name = "comment_id", nullable = false)
    val commentId: Long,

    @Column(name = "user_id", nullable = false)
    val userId: String,

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now()
)
