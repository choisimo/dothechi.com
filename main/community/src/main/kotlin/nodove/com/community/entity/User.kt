package nodove.com.community.entity

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "users")
data class User(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(name = "user_id", nullable = false, unique = true, length = 50)
    val userId: String,

    @Column(nullable = false, unique = true, length = 100)
    val email: String,

    @Column(nullable = false, length = 255)
    var password: String,

    @Column(length = 50)
    var username: String? = null,

    @Column(name = "user_nick", nullable = false, length = 50)
    var userNick: String,

    @Column(name = "avatar_url", length = 500)
    var avatarUrl: String? = null,

    @Enumerated(EnumType.STRING)
    @Column(name = "user_role", nullable = false, length = 20)
    var userRole: UserRole = UserRole.USER,

    @Column(name = "is_active", nullable = false)
    var isActive: Boolean = true,

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),

    @Column(name = "updated_at", nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now(),

    @Column(name = "deleted_at")
    var deletedAt: LocalDateTime? = null
) {
    @PreUpdate
    fun preUpdate() {
        updatedAt = LocalDateTime.now()
    }
}

enum class UserRole {
    USER,
    ADMIN,
    MODERATOR
}
