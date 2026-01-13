package nodove.com.community.security

import io.jsonwebtoken.*
import io.jsonwebtoken.io.Decoders
import io.jsonwebtoken.security.Keys
import nodove.com.community.entity.User
import org.springframework.beans.factory.annotation.Value
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.stereotype.Component
import java.security.Key
import java.util.*

@Component
class JwtTokenProvider(
    @Value("\${jwt.secret}") private val jwtSecret: String,
    @Value("\${jwt.expiration}") private val jwtExpiration: Long
) {
    private val key: Key by lazy {
        Keys.hmacShaKeyFor(Decoders.BASE64.decode(jwtSecret))
    }

    fun generateToken(user: User): String {
        val now = Date()
        val expiryDate = Date(now.time + jwtExpiration)

        return Jwts.builder()
            .setSubject(user.id.toString())
            .claim("userId", user.userId)
            .claim("email", user.email)
            .claim("userNick", user.userNick)
            .claim("role", user.userRole.name)
            .setIssuedAt(now)
            .setExpiration(expiryDate)
            .signWith(key, SignatureAlgorithm.HS512)
            .compact()
    }

    fun getUserIdFromToken(token: String): Long {
        val claims = getClaims(token)
        return claims.subject.toLong()
    }

    fun getUserInfoFromToken(token: String): Map<String, Any> {
        val claims = getClaims(token)
        return mapOf(
            "id" to claims.subject.toLong(),
            "userId" to (claims["userId"] as String),
            "email" to (claims["email"] as String),
            "userNick" to (claims["userNick"] as String),
            "role" to (claims["role"] as String)
        )
    }

    fun validateToken(token: String): Boolean {
        return try {
            getClaims(token)
            true
        } catch (e: ExpiredJwtException) {
            false
        } catch (e: UnsupportedJwtException) {
            false
        } catch (e: MalformedJwtException) {
            false
        } catch (e: SignatureException) {
            false
        } catch (e: IllegalArgumentException) {
            false
        }
    }

    private fun getClaims(token: String): Claims {
        return Jwts.parserBuilder()
            .setSigningKey(key)
            .build()
            .parseClaimsJws(token)
            .body
    }
}
