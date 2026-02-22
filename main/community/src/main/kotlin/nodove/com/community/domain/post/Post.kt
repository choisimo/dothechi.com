package nodove.com.community.domain.post

import jakarta.persistence.*
import nodove.com.community.domain.category.Category
import java.time.LocalDateTime

@Entity
@Table(name = "posts", indexes = [
    Index(name = "idx_posts_author_id", columnList = "author_id"),
    Index(name = "idx_posts_category_id", columnList = "category_id"),
    Index(name = "idx_posts_created_at", columnList = "created_at"),
    Index(name = "idx_posts_deleted_at", columnList = "deleted_at")
])
class Post(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(nullable = false, length = 200)
    var title: String,

    @Column(nullable = false, columnDefinition = "TEXT")
    var content: String,

    @Column(length = 500)
    var excerpt: String? = null,

    @Column(name = "author_id", nullable = false)
    val authorId: String,

    @Column(name = "author_nick", nullable = false, length = 50)
    val authorNick: String,

    @Column(name = "author_email", nullable = false, length = 255)
    val authorEmail: String,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    var category: Category,

    @ElementCollection
    @CollectionTable(name = "post_tags", joinColumns = [JoinColumn(name = "post_id")])
    @Column(name = "tag", length = 50)
    var tags: MutableList<String> = mutableListOf(),

    @Column(name = "view_count", nullable = false)
    var viewCount: Long = 0,

    @Column(name = "like_count", nullable = false)
    var likeCount: Long = 0,

    @Column(name = "comment_count", nullable = false)
    var commentCount: Long = 0,

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
