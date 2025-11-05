package nodove.com.community.domain

import jakarta.persistence.*
import org.hibernate.annotations.CreationTimestamp
import org.hibernate.annotations.UpdateTimestamp
import java.time.LocalDateTime

@Entity
@Table(name = "posts", indexes = [
    Index(name = "idx_author_id", columnList = "authorId"),
    Index(name = "idx_category_id", columnList = "category_id"),
    Index(name = "idx_created_at", columnList = "createdAt")
])
data class Post(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,

    @Column(nullable = false, length = 500)
    var title: String,

    @Column(nullable = false, columnDefinition = "TEXT")
    var content: String,

    @Column(length = 1000)
    var excerpt: String? = null,

    @Column(nullable = false)
    val authorId: String, // Auth Service의 User ID 참조

    @Column(nullable = false)
    val authorNickname: String, // 캐싱용

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    var category: Category,

    @ElementCollection
    @CollectionTable(name = "post_tags", joinColumns = [JoinColumn(name = "post_id")])
    @Column(name = "tag", length = 50)
    var tags: MutableList<String> = mutableListOf(),

    @Column(nullable = false)
    var viewCount: Int = 0,

    @Column(nullable = false)
    var likeCount: Int = 0,

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    val createdAt: LocalDateTime? = null,

    @UpdateTimestamp
    @Column(nullable = false)
    val updatedAt: LocalDateTime? = null,

    @Column
    var deletedAt: LocalDateTime? = null
) {
    fun incrementViewCount() {
        viewCount++
    }

    fun incrementLikeCount() {
        likeCount++
    }

    fun decrementLikeCount() {
        if (likeCount > 0) {
            likeCount--
        }
    }

    fun softDelete() {
        deletedAt = LocalDateTime.now()
    }
}
