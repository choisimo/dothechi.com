package nodove.com.community.service

import nodove.com.community.dto.*
import nodove.com.community.entity.User
import nodove.com.community.entity.UserRole
import nodove.com.community.repository.UserRepository
import nodove.com.community.security.JwtTokenProvider
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
class AuthService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder,
    private val jwtTokenProvider: JwtTokenProvider
) {

    @Transactional
    fun register(request: RegisterRequest): AuthResponse {
        if (userRepository.existsByEmail(request.email)) {
            throw IllegalArgumentException("Email already exists")
        }

        if (userRepository.existsByUserNick(request.userNick)) {
            throw IllegalArgumentException("User nick already exists")
        }

        val user = User(
            userId = UUID.randomUUID().toString(),
            email = request.email,
            password = passwordEncoder.encode(request.password),
            username = request.username,
            userNick = request.userNick,
            userRole = request.userRole,
            isActive = request.isActive
        )

        val savedUser = userRepository.save(user)
        val token = jwtTokenProvider.generateToken(savedUser)

        return AuthResponse(
            token = token,
            user = UserDto.from(savedUser)
        )
    }

    @Transactional(readOnly = true)
    fun login(request: LoginRequest): AuthResponse {
        val user = userRepository.findByEmail(request.email)
            .orElseThrow { IllegalArgumentException("Invalid email or password") }

        if (!user.isActive) {
            throw IllegalArgumentException("Account is not active")
        }

        if (!passwordEncoder.matches(request.password, user.password)) {
            throw IllegalArgumentException("Invalid email or password")
        }

        val token = jwtTokenProvider.generateToken(user)

        return AuthResponse(
            token = token,
            user = UserDto.from(user)
        )
    }

    @Transactional(readOnly = true)
    fun verifyToken(userId: Long): UserDto {
        val user = userRepository.findById(userId)
            .orElseThrow { IllegalArgumentException("User not found") }

        if (!user.isActive) {
            throw IllegalArgumentException("Account is not active")
        }

        return UserDto.from(user)
    }

    @Transactional(readOnly = true)
    fun getProfile(userId: Long): UserDto {
        val user = userRepository.findById(userId)
            .orElseThrow { IllegalArgumentException("User not found") }

        return UserDto.from(user)
    }
}
