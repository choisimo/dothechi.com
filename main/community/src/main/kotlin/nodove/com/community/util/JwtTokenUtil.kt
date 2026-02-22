package nodove.com.community.util

import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component

@Component
class JwtTokenUtil(
    @Value("\${jwt.secret-key.access}") private val accessSecret: String
) {
    private val accessKey by lazy { Keys.hmacShaKeyFor(accessSecret.toByteArray()) }

    data class TokenClaims(
        val userId: String,
        val email: String,
        val role: String,
        val userNick: String
    )

    fun parseAccessToken(token: String): TokenClaims? {
        return try {
            val claims = Jwts.parserBuilder()
                .setSigningKey(accessKey)
                .build()
                .parseClaimsJws(token)
                .body

            val userId = claims.get("userId", String::class.java)
            val email = claims.get("email", String::class.java)
            @Suppress("UNCHECKED_CAST")
            val roles = claims.get("role", List::class.java) as? List<String>
            val role = roles?.firstOrNull() ?: "USER"
            val userNick = claims.get("userNick", String::class.java) ?: email

            TokenClaims(userId, email, role, userNick)
        } catch (e: Exception) {
            null
        }
    }
}
