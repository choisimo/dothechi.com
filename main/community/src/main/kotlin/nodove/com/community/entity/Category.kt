package nodove.com.community.entity

import jakarta.persistence.*

@Entity
@Table(name = "categories")
data class Category(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(nullable = false, unique = true, length = 50)
    val slug: String,

    @Column(nullable = false, length = 100)
    var name: String,

    @Column(length = 255)
    var description: String? = null,

    @Column(name = "post_count", nullable = false)
    var postCount: Int = 0,

    @Column(name = "sort_order", nullable = false)
    var sortOrder: Int = 0,

    @Column(name = "is_active", nullable = false)
    var isActive: Boolean = true
)
