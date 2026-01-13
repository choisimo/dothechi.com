package nodove.com.community.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import nodove.com.community.dto.*
import nodove.com.community.security.UserPrincipal
import nodove.com.community.service.AuthService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.*

@Tag(name = "Auth", description = "인증 관리 API")
@RestController
@RequestMapping("/api")
class AuthController(
    private val authService: AuthService
) {

    @Operation(summary = "로그인")
    @PostMapping("/auth/login")
    fun login(@RequestBody request: LoginRequest): ResponseEntity<AuthResponse> {
        val response = authService.login(request)
        return ResponseEntity.ok(response)
    }

    @Operation(summary = "회원가입")
    @PostMapping("/auth/register")
    fun register(@RequestBody request: RegisterRequest): ResponseEntity<AuthResponse> {
        val response = authService.register(request)
        return ResponseEntity.status(HttpStatus.CREATED).body(response)
    }

    @Operation(summary = "토큰 검증")
    @GetMapping("/auth/verify")
    fun verify(@AuthenticationPrincipal principal: UserPrincipal): ResponseEntity<UserDto> {
        val user = authService.verifyToken(principal.id)
        return ResponseEntity.ok(user)
    }

    @Operation(summary = "프로필 조회")
    @GetMapping("/user/profile")
    fun getProfile(@AuthenticationPrincipal principal: UserPrincipal): ResponseEntity<UserDto> {
        val user = authService.getProfile(principal.id)
        return ResponseEntity.ok(user)
    }
}
