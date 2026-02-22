package com.nodove.community.nodove.service;

import com.nodove.community.nodove.configuration.security.JWT.JwtUtilityManager;
import com.nodove.community.nodove.domain.security.Token;
import com.nodove.community.nodove.domain.users.User;
import com.nodove.community.nodove.domain.users.UserLoginHistory;
import com.nodove.community.nodove.dto.response.ApiResponseDto;
import com.nodove.community.nodove.dto.response.ResponseStatusManager;
import com.nodove.community.nodove.dto.security.Redis_Refresh_Token;
import com.nodove.community.nodove.dto.security.TokenDto;
import com.nodove.community.nodove.dto.user.UserLoginRequest;
import com.nodove.community.nodove.dto.user.UserRegisterDto;
import com.nodove.community.nodove.repository.users.UserLoginHistoryRepository;
import com.nodove.community.nodove.repository.users.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService implements UserServiceManager{

    private final UserRepository userRepository;
    private final UserLoginHistoryRepository userLoginHistoryRepository;
    private final RedisServiceManager redisService;
    private final JwtUtilityManager jwtUtility;
    private final SmtpServiceManager smtpService;
    private final PasswordEncoder passwordEncoder;
    private final ResponseStatusManager responseStatusManager;

    private boolean isEmailExist(String email) {
        if (redisService.UserEmailExists(email)) {
            return true;
        }
        if (userRepository.findByEmail(email).isPresent()) {
            saveUserEmail(email);
            return true;
        }
        return false;
    }

    private boolean isUserIdExist(String userId) {
        if (redisService.UserIdExists(userId)) {
            return true;
        }
        if (userRepository.findByUserId(userId).isPresent()) {
            saveUserId(userId);
            return true;
        }
        return false;
    }

    private boolean isUserNickExist(String userNick) {
        if (redisService.UserNickExists(userNick)) {
            return true;
        }
        if (userRepository.findByUserNick(userNick).isPresent()) {
            saveUserNick(userNick);
            return true;
        }
        return false;
    }

    private void saveUserNick(String userNick) {
        redisService.saveUserNick(userNick);
    }

    private void saveUserId(String userId) {
        redisService.saveUserId(userId);
    }

    private void saveUserEmail(String email) {
        redisService.saveUserEmail(email);
    }

    private boolean checkEmailCode(String email, String code) {
        return redisService.getEmailCode(email).equals(code);
    }

    private void saveEmailCode(String email, String code) {
        redisService.saveEmailCode(email, code);
    }


    @Transactional
    @Override
    public User findByUserId(String userId) {
        return userRepository.findByUserId(userId).orElseThrow(() -> new IllegalArgumentException("해당 사용자가 없습니다."));
    }

    @Transactional
    @Override
    public void saveLoginHistory(UserLoginRequest userLoginRequest, HttpServletRequest request) {
        User user = userRepository.findByEmail(userLoginRequest.getEmail()).orElseThrow(() -> new IllegalArgumentException("해당 사용자가 없습니다."));
        String ip = request.getRemoteAddr();
        String userAgent = request.getHeader("User-Agent");

        UserLoginHistory userLoginHistory = UserLoginHistory.builder()
                .user(user)
                .loginTime(LocalDateTime.now())
                .ipAddress(ip)
                .device(UUID.randomUUID().toString())
                .isSuccess(true)
                .build();

        userLoginHistoryRepository.save(userLoginHistory);
    }

    @Transactional
    @Override
    public ResponseEntity<?> registerUser(UserRegisterDto userRegisterDto) {
        String userId = String.valueOf(System.currentTimeMillis());

        if  (isEmailExist(userRegisterDto.getEmail())) {
            return ResponseEntity.badRequest().body("이미 존재하는 이메일입니다.");
        }
        if (isUserIdExist(userId)) {
            return ResponseEntity.badRequest().body("이미 존재하는 아이디입니다.");
        }
        if (isUserNickExist(userRegisterDto.getUserNick())) {
            return ResponseEntity.badRequest().body("이미 존재하는 닉네임입니다.");
        }

        User user = User.builder()
                .userId(userId)
                .email(userRegisterDto.getEmail())
                .userNick(userRegisterDto.getUserNick())
                .username(userRegisterDto.getUsername() != null ? userRegisterDto.getUsername() : UUID.randomUUID().toString())
                .password(passwordEncoder.encode(userRegisterDto.getPassword()))
                .isActive(false)
                .build();

        userRepository.save(user);
        smtpService.sendJoinMail(userRegisterDto.getEmail());

        return ResponseEntity.ok().body(ApiResponseDto.builder()
                .code("CREATED_USER_EMAIL_SEND")
                .message("이메일 인증을 완료해주세요.")
                .status("success")
                .build().toString());
    }

    @Override
    public ResponseEntity<?> refreshAccessToken(HttpServletRequest request, HttpServletResponse response) {
        try {

            String refreshToken = jwtUtility.getRefreshToken(request);
            if (refreshToken == null || jwtUtility.isTokenExpired(refreshToken, 1)) {
                return ResponseEntity.status(HttpServletResponse.SC_UNAUTHORIZED).body(ApiResponseDto.builder()
                        .code("TOKEN_EXPIRED")
                        .message("리프레시 토큰이 만료되었습니다.")
                        .status("error")
                        .build().toString());
            }
            String userId = jwtUtility.parseToken(refreshToken, 1).get("userId").toString();
            String token = jwtUtility.generateReissuedAccessToken(userId);
            String deviceId = request.getHeader(Token.DEVICE_ID_HEADER.getHeaderName());

            Redis_Refresh_Token newRedis_refresh = Redis_Refresh_Token.builder()
                    .userId(userId)
                    .provider("LOCAL")
                    .deviceId(deviceId)
                    .build();
            redisService.saveRefreshToken(newRedis_refresh, token);

            TokenDto reissuedToken = TokenDto.builder()
                    .accessToken(token)
                    .refreshToken(refreshToken)
                    .build();

            jwtUtility.loginResponse(response, reissuedToken, deviceId);
            // loginResponse() already wrote the body via response.getWriter() — do not return a body
            return null;

        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponseDto.builder()
                    .code("TOKEN_EXPIRED")
                    .message("토큰이 만료되었습니다.")
                    .status("error")
                    .build().toString());
        }
    }

    @Override
    public boolean updateEmailValidation(String email) {
        return userRepository.updateEmailValidation(email);
    }

    @Override
    public void resendJoinEmail(String email) {
        smtpService.sendJoinMail(email);
    }

    @Override
    public ResponseEntity<?> logoutUser(HttpServletRequest request, HttpServletResponse response) {
        try {
            String refreshToken = jwtUtility.getRefreshToken(request);
            if (refreshToken == null) {
                return ResponseEntity.badRequest().body(responseStatusManager.error(response, "error", "LOGOUT_FAILED", "리프레시 토큰이 없습니다."));
            }
            String deviceId = request.getHeader(Token.DEVICE_ID_HEADER.getHeaderName());
            String userId = jwtUtility.parseToken(refreshToken, 1).get("userId").toString();

            Redis_Refresh_Token redisRefreshToken = Redis_Refresh_Token.builder()
                    .userId(userId)
                    .provider("LOCAL")
                    .deviceId(deviceId)
                    .build();
            redisService.deleteRefreshToken(redisRefreshToken);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(responseStatusManager.error(response, "error", "LOGOUT_FAILED", "로그아웃에 실패했습니다."));
        }
        return ResponseEntity.ok().body(responseStatusManager.success(response, "success", "LOGOUT_SUCCESS", "로그아웃에 성공했습니다."));
    }
}
