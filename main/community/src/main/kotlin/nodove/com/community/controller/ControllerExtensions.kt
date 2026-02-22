package nodove.com.community.controller

import jakarta.servlet.http.HttpServletRequest
import nodove.com.community.exception.UnauthorizedException
import nodove.com.community.util.JwtTokenUtil

fun HttpServletRequest.extractUserIdOrNull(jwtTokenUtil: JwtTokenUtil): String? {
    val header = getHeader("Authorization") ?: return null
    if (!header.startsWith("Bearer ")) return null
    val token = header.substring(7)
    return jwtTokenUtil.parseAccessToken(token)?.userId
}

fun HttpServletRequest.extractUserIdOrThrow(jwtTokenUtil: JwtTokenUtil): String {
    return extractUserIdOrNull(jwtTokenUtil)
        ?: throw UnauthorizedException("유효한 인증 토큰이 필요합니다.")
}

fun HttpServletRequest.extractClaims(jwtTokenUtil: JwtTokenUtil): JwtTokenUtil.TokenClaims {
    val header = getHeader("Authorization") ?: throw UnauthorizedException()
    if (!header.startsWith("Bearer ")) throw UnauthorizedException()
    val token = header.substring(7)
    return jwtTokenUtil.parseAccessToken(token) ?: throw UnauthorizedException("토큰이 유효하지 않습니다.")
}
