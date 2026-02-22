package nodove.com.community.domain.comment

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "comments", indexes = [
    Index(name = "idx_comments_post_id", columnList = "post_id"),
    Index(name = "idx_comments_author_id", columnList = "author_id"),
    Index(name = "idx_comments_parent_id", columnList = "parent_id")
])
class Comment(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(nullable = false, columnDefinition = "TEXT")
    var content: String,

    @Column(name = "author_id", nullable = false)
    val authorId: String,

    @Column(name = "author_nick", nullable = false, length = 50)
    val authorNick: String,

    @Column(name = "author_email", nullable = false, length = 255)
    val authorEmail: String,

    @Column(name = "post_id", nullable = false)
    val postId: Long,

    @Column(name = "parent_id")
    val parentId: Long? = null,

    @Column(name = "like_count", nullable = false)
    var likeCount: Long = 0,

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),

    @Column(name = "updated_at", nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now(),

    @Column(name = "deleted_at")
    var deletedAt: LocalDateTime? = null
) {
    @PreUpdate
    fun onUpdate() {
        updatedAt = LocalDateTime.now()
    }

    fun softDelete() {
        deletedAt = LocalDateTime.now()
    }

    val isDeleted: Boolean get() = deletedAt != null
}
