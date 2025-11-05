package nodove.com.community.util

import io.jsonwebtoken.Claims
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import javax.crypto.SecretKey

@Component
class JwtUtil {

    @Value("\${jwt.secret:mySecretKeyForJWTTokenGenerationAndValidation1234567890}")
    private lateinit var secretKey: String

    private fun getSigningKey(): SecretKey {
        return Keys.hmacShaKeyFor(secretKey.toByteArray())
    }

    fun extractAllClaims(token: String): Claims {
        return Jwts.parser()
            .verifyWith(getSigningKey())
            .build()
            .parseSignedClaims(token)
            .payload
    }

    fun extractUserId(token: String): String? {
        return try {
            val claims = extractAllClaims(token)
            claims["userId"] as? String ?: claims.subject
        } catch (e: Exception) {
            null
        }
    }

    fun extractUserNickname(token: String): String? {
        return try {
            val claims = extractAllClaims(token)
            claims["userNick"] as? String
        } catch (e: Exception) {
            null
        }
    }

    fun validateToken(token: String): Boolean {
        return try {
            extractAllClaims(token)
            true
        } catch (e: Exception) {
            false
        }
    }
}
