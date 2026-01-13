package nodove.com.community.repository

import nodove.com.community.entity.User
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.Optional

@Repository
interface UserRepository : JpaRepository<User, Long> {
    fun findByEmail(email: String): Optional<User>
    fun findByUserId(userId: String): Optional<User>
    fun existsByEmail(email: String): Boolean
    fun existsByUserId(userId: String): Boolean
    fun existsByUserNick(userNick: String): Boolean
}
