package com.nodove.community.nodove.controller;

import com.nodove.community.nodove.configuration.security.constructor.PrincipalDetails;
import com.nodove.community.nodove.dto.response.ApiResponseDto;
import com.nodove.community.nodove.dto.user.UserLoginRequest;
import com.nodove.community.nodove.dto.user.UserRegisterDto;
import com.nodove.community.nodove.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // 회원가입
    @Operation(summary = "회원가입", description = "회원가입을 진행합니다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "회원가입 성공"),
            @ApiResponse(responseCode = "400", description = "회원가입 실패"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @PostMapping("/auth/register")
    public ResponseEntity<?> registerUser(
            @RequestBody(required = true) UserRegisterDto userRegisterDto) {
        log.info("회원 가입을 진행합니다. email = {}", userRegisterDto.getEmail());
        return this.userService.registerUser(userRegisterDto);
    }

    @Operation(summary = "로그인", description = "로그인을 진행합니다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "로그인 성공"),
            @ApiResponse(responseCode = "400", description = "로그인 실패"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @PostMapping("/auth/login")
    public ResponseEntity<?> loginUser(
            @RequestBody(required = true) UserLoginRequest UserLoginRequest) {
        // filter 에서 처리
        return ResponseEntity.ok().body(ApiResponseDto.<Void>builder()
                .status("success")
                .message("로그인 성공")
                .code("LOGIN_SUCCESS")
                .build());
    }

    @Operation(summary = "토큰 갱신", description = "토큰을 갱신합니다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "토큰 갱신 성공"),
            @ApiResponse(responseCode = "400", description = "토큰 갱신 실패"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @PostMapping("/auth/refresh")
    public ResponseEntity<?> refreshAccessToken(HttpServletRequest request, HttpServletResponse response, @AuthenticationPrincipal PrincipalDetails principalDetails) {
        return this.userService.refreshAccessToken(request, response);
    }


    @PutMapping("/auth/logout")
    public ResponseEntity<?> logoutUser(HttpServletRequest request, HttpServletResponse response) {
        return this.userService.logoutUser(request, response);
    }

    @Operation(summary = "토큰 검증", description = "JWT 토큰의 유효성을 검증합니다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "토큰 유효"),
            @ApiResponse(responseCode = "401", description = "토큰 무효"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @GetMapping("/auth/verify")
    public ResponseEntity<?> verifyToken(@AuthenticationPrincipal PrincipalDetails principalDetails) {
        if (principalDetails != null && principalDetails.getUser() != null) {
            Map<String, Object> response = new HashMap<>();
            response.put("valid", true);
            response.put("user", Map.of(
                    "id", principalDetails.getUser().getId(),
                    "userId", principalDetails.getUser().getUserId(),
                    "email", principalDetails.getUser().getEmail(),
                    "username", principalDetails.getUser().getUsername(),
                    "userNick", principalDetails.getUser().getUserNick(),
                    "userRole", principalDetails.getUser().getUserRole().toString(),
                    "isActive", principalDetails.getUser().isActive()
            ));
            return ResponseEntity.ok(ApiResponseDto.builder()
                    .status("success")
                    .message("토큰이 유효합니다.")
                    .code("TOKEN_VALID")
                    .data(response)
                    .build());
        }
        return ResponseEntity.status(401).body(ApiResponseDto.builder()
                .status("error")
                .message("토큰이 유효하지 않습니다.")
                .code("TOKEN_INVALID")
                .build());
    }

    @Operation(summary = "프로필 조회", description = "현재 로그인한 사용자의 프로필을 조회합니다.")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "프로필 조회 성공"),
            @ApiResponse(responseCode = "401", description = "인증 실패"),
            @ApiResponse(responseCode = "500", description = "서버 오류")
    })
    @GetMapping("/user/profile")
    public ResponseEntity<?> getUserProfile(@AuthenticationPrincipal PrincipalDetails principalDetails) {
        if (principalDetails != null && principalDetails.getUser() != null) {
            Map<String, Object> userProfile = new HashMap<>();
            userProfile.put("id", principalDetails.getUser().getId());
            userProfile.put("userId", principalDetails.getUser().getUserId());
            userProfile.put("email", principalDetails.getUser().getEmail());
            userProfile.put("username", principalDetails.getUser().getUsername());
            userProfile.put("userNick", principalDetails.getUser().getUserNick());
            userProfile.put("userRole", principalDetails.getUser().getUserRole().toString());
            userProfile.put("isActive", principalDetails.getUser().isActive());
            userProfile.put("createdAt", principalDetails.getUser().getCreatedAt());
            userProfile.put("updatedAt", principalDetails.getUser().getUpdatedAt());

            return ResponseEntity.ok(ApiResponseDto.builder()
                    .status("success")
                    .message("프로필 조회 성공")
                    .code("PROFILE_GET_SUCCESS")
                    .data(userProfile)
                    .build());
        }
        return ResponseEntity.status(401).body(ApiResponseDto.builder()
                .status("error")
                .message("인증되지 않은 사용자입니다.")
                .code("UNAUTHORIZED")
                .build());
    }

}