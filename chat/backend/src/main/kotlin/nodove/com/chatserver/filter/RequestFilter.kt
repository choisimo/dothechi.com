package nodove.com.chatserver.filter

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import nodove.com.chatserver.constants.SecurityEnum
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.web.filter.OncePerRequestFilter

class RequestFilter : OncePerRequestFilter()
{
    override fun doFilterInternal(request: HttpServletRequest, response: HttpServletResponse, filterChain: FilterChain) {
        val token: String? = request.getHeader("Authorization")

        if (token == null || !token.startsWith(SecurityEnum.ACCESS_TOKEN_HEADER.s2)) {
            filterChain.doFilter(request, response)
            return
        }

        val authToken = token.substring(7)
        val auth = UsernamePasswordAuthenticationToken(authToken, null, emptyList())
        SecurityContextHolder.getContext().authentication = auth
        filterChain.doFilter(request, response)
    }
}
