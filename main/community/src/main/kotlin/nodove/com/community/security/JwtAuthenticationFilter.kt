package nodove.com.community.security

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import nodove.com.community.repository.UserRepository
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.stereotype.Component
import org.springframework.util.StringUtils
import org.springframework.web.filter.OncePerRequestFilter

@Component
class JwtAuthenticationFilter(
    private val jwtTokenProvider: JwtTokenProvider,
    private val userRepository: UserRepository
) : OncePerRequestFilter() {

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val token = getTokenFromRequest(request)

        if (token != null && jwtTokenProvider.validateToken(token)) {
            val userId = jwtTokenProvider.getUserIdFromToken(token)
            val userInfo = jwtTokenProvider.getUserInfoFromToken(token)

            val authorities = listOf(SimpleGrantedAuthority("ROLE_${userInfo["role"]}"))
            
            val authentication = UsernamePasswordAuthenticationToken(
                UserPrincipal(
                    id = userId,
                    userId = userInfo["userId"] as String,
                    email = userInfo["email"] as String,
                    userNick = userInfo["userNick"] as String,
                    role = userInfo["role"] as String
                ),
                null,
                authorities
            )

            SecurityContextHolder.getContext().authentication = authentication
            
            request.setAttribute("X-User-Id", userId)
            request.setAttribute("X-User-Name", userInfo["userNick"])
        }

        filterChain.doFilter(request, response)
    }

    private fun getTokenFromRequest(request: HttpServletRequest): String? {
        val bearerToken = request.getHeader("Authorization")
        return if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            bearerToken.substring(7)
        } else null
    }
}

data class UserPrincipal(
    val id: Long,
    val userId: String,
    val email: String,
    val userNick: String,
    val role: String
)
