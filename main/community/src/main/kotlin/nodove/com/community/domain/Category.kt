package nodove.com.community.domain

import jakarta.persistence.*
import org.hibernate.annotations.CreationTimestamp
import org.hibernate.annotations.UpdateTimestamp
import java.time.LocalDateTime

@Entity
@Table(name = "categories")
data class Category(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,

    @Column(nullable = false, unique = true, length = 50)
    val name: String,

    @Column(length = 500)
    val description: String? = null,

    @Column(nullable = false)
    var postCount: Int = 0,

    @Column(nullable = false)
    var isActive: Boolean = true,

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    val createdAt: LocalDateTime? = null,

    @UpdateTimestamp
    @Column(nullable = false)
    val updatedAt: LocalDateTime? = null
)
