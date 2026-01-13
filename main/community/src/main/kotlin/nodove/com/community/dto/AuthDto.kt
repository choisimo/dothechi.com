package nodove.com.community.dto

import nodove.com.community.entity.User
import nodove.com.community.entity.UserRole
import java.time.LocalDateTime

data class LoginRequest(
    val email: String,
    val password: String
)

data class RegisterRequest(
    val email: String,
    val password: String,
    val userNick: String,
    val username: String? = null,
    val userRole: UserRole = UserRole.USER,
    val isActive: Boolean = true
)

data class AuthResponse(
    val token: String,
    val user: UserDto
)

data class UserDto(
    val id: String,
    val userId: String,
    val username: String?,
    val email: String,
    val userNick: String,
    val avatarUrl: String?,
    val userRole: UserRole,
    val isActive: Boolean,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime,
    val deletedAt: LocalDateTime?
) {
    companion object {
        fun from(user: User): UserDto {
            return UserDto(
                id = user.id.toString(),
                userId = user.userId,
                username = user.username,
                email = user.email,
                userNick = user.userNick,
                avatarUrl = user.avatarUrl,
                userRole = user.userRole,
                isActive = user.isActive,
                createdAt = user.createdAt,
                updatedAt = user.updatedAt,
                deletedAt = user.deletedAt
            )
        }
    }
}

data class ErrorResponse(
    val error: String,
    val message: String,
    val timestamp: LocalDateTime = LocalDateTime.now()
)
