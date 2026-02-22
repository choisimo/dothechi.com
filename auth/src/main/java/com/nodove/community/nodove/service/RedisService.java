package com.nodove.community.nodove.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nodove.community.nodove.domain.security.Token;
import com.nodove.community.nodove.domain.users.UserCaching;
import com.nodove.community.nodove.dto.security.Redis_Refresh_Token;
import com.nodove.community.nodove.dto.user.UserBlockDto;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class RedisService implements RedisServiceManager {

    private final RedisTemplate<String, String> redisTemplate;
    private final ObjectMapper objectMapper;


    /* Blocking User */


    private String generateRedisBlockedKey(String userId) {
        return UserCaching.PREFIX_USER_BLOCKED + userId;
    }

    private String generateRedisRefreshTokenKey(Redis_Refresh_Token redisRefreshToken) {
        return new StringBuilder(redisRefreshToken.getProvider())
                .append("_REFRESH_")
                .append(redisRefreshToken.getUserId())
                .append("_")
                .append(redisRefreshToken.getDeviceId())
                .toString();
    }

    @Transactional
    @Override
    public void setBlockCaching(UserBlockDto userBlockDto) {
        String redisKey = generateRedisBlockedKey(userBlockDto.getUser());

        try {
            // DTO를 JSON 문자열로 변환
            String value = objectMapper.writeValueAsString(userBlockDto);

            // Redis에 저장 (TTL 적용)
            redisTemplate.opsForValue().set(redisKey, value, userBlockDto.getDuration(), TimeUnit.MINUTES);
        } catch (JsonProcessingException e) {
            // 로그 및 사용자 정의 예외 처리
            throw new RuntimeException("Failed to serialize UserBlockDto for userId: " + userBlockDto.getUser(), e);
        }
    }

    @Transactional
    @Override
    public UserBlockDto getBlockCaching(String userId) {
        String redisKey = generateRedisBlockedKey(userId);

        // Redis에서 조회
        String value = redisTemplate.opsForValue().get(redisKey);

        if (value == null) {
            return null;
        }

        try {
            // JSON 문자열을 DTO로 변환
            return objectMapper.readValue(value, UserBlockDto.class);
        } catch (JsonProcessingException e) {
            // 로그 및 사용자 정의 예외 처리
            throw new RuntimeException("Failed to deserialize UserBlockDto for userId: " + userId, e);
        }
    }


    @Transactional
    @Override
    public void deleteBlockCaching(String userId) {
        String redisKey = generateRedisBlockedKey(userId);

        // Redis에서 삭제
        redisTemplate.delete(redisKey);
    }

    @Transactional
    @Override
    public boolean isBlocked(String userId) {
        String redisKey = generateRedisBlockedKey(userId);

        // Redis에서 조회
        return redisTemplate.hasKey(redisKey);
    }

    // Save Refresh Token
    @Transactional
    @Override
    public void saveRefreshToken(Redis_Refresh_Token redisRefreshToken, String refreshToken) {
        String key = generateRedisRefreshTokenKey(redisRefreshToken);
        redisTemplate.opsForValue().set(key, refreshToken, Duration.ofMillis(Token.REFRESH_TOKEN_HEADER.getREFRESH_TOKEN_EXPIRATION()));
    }

    // Get Refresh Token
    @Transactional
    @Override
    public String getRefreshToken(Redis_Refresh_Token redisRefreshToken) {
        String key = generateRedisRefreshTokenKey(redisRefreshToken);
        return redisTemplate.opsForValue().get(key);
    }

    // Delete Refresh Token
    @Transactional
    @Override
    public void deleteRefreshToken(Redis_Refresh_Token redisRefreshToken) {
        String key = generateRedisRefreshTokenKey(redisRefreshToken);
        redisTemplate.delete(key);
    }

    @Transactional
    @Override
    public boolean UserEmailExists(String email) {
        return redisTemplate.hasKey(UserCaching.PREFIX_USER_EMAIL + email);
    }

    @Transactional
    @Override
    public boolean UserIdExists(String userId) {
        return redisTemplate.hasKey(UserCaching.PREFIX_USER_ID + userId);
    }

    @Transactional
    @Override
    public boolean UserNickExists(String userNick) {
        return redisTemplate.hasKey(UserCaching.PREFIX_USER_NICK + userNick);
    }
    @Transactional
    @Override
    public void saveUserNick(String userNick) {
        redisTemplate.opsForValue().set(UserCaching.PREFIX_USER_NICK + userNick, userNick, Duration.ofDays(1));
    }
    @Transactional
    @Override
    public void saveUserEmail(String email) {
        redisTemplate.opsForValue().set(UserCaching.PREFIX_USER_EMAIL + email, email, Duration.ofDays(1));
    }
    @Transactional
    @Override
    public void saveUserId(String userId) {
        redisTemplate.opsForValue().set(UserCaching.PREFIX_USER_ID + userId, userId, Duration.ofDays(1));
    }
    @Transactional
    @Override
    public String getEmailCode(String email) {
        return redisTemplate.opsForValue().get(UserCaching.PREFIX_USER_EMAIL_CODE + email);
    }
    @Transactional
    @Override
    public void saveEmailCode(String email, String code) {
        log.info("saveEmailCode: email={}, code={}", email, code);
        redisTemplate.opsForValue().set(UserCaching.PREFIX_USER_EMAIL_CODE + email, code, Duration.ofMinutes(30));
    }

    /* Blocking User */



}
