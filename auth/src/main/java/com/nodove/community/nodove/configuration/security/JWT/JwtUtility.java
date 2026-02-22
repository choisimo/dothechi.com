package com.nodove.community.nodove.configuration.security.JWT;

import com.nodove.community.nodove.configuration.security.constructor.PrincipalDetails;
import com.nodove.community.nodove.constants.JwtValidity;
import com.nodove.community.nodove.domain.security.Token;
import com.nodove.community.nodove.domain.users.User;
import com.nodove.community.nodove.domain.users.UserBlock;
import com.nodove.community.nodove.domain.users.UserRole;
import com.nodove.community.nodove.dto.response.ApiResponseDto;
import com.nodove.community.nodove.dto.response.ResponseStatusManager;
import com.nodove.community.nodove.dto.security.TokenDto;
import com.nodove.community.nodove.dto.user.UserBlockDto;
import com.nodove.community.nodove.repository.users.UserRepository;
import com.nodove.community.nodove.service.RedisServiceManager;
import com.nodove.community.nodove.service.UserBlockService;
import com.nodove.community.nodove.service.UserBlockServiceManager;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.security.Key;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Component

public class JwtUtility implements JwtUtilityManager {

    private final Key accessKey;
    private final Key refreshKey;
    private final RedisServiceManager redisService;
    private final UserBlockServiceManager userBlockService;
    private final UserRepository userRepository;
    private final ResponseStatusManager responseStatusManager;


    public JwtUtility(
            @Value("${jwt.secret-key.access}") String accessKey,
            @Value("${jwt.secret-key.refresh}") String refreshKey, RedisServiceManager redisService, UserBlockServiceManager userBlockService, UserRepository userRepository, ResponseStatusManager responseStatusManager
    ) {
        this.accessKey = Keys.hmacShaKeyFor(accessKey.getBytes());
        this.refreshKey = Keys.hmacShaKeyFor(refreshKey.getBytes());
        this.redisService = redisService;
        this.userBlockService = userBlockService;
        this.userRepository = userRepository;
        this.responseStatusManager = responseStatusManager;
    }

    @Override
    public String generateReissuedAccessToken(String userId) {
        User user = this.userRepository.findByUserId(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
        List<UserRole> role = Collections.singletonList(user.getUserRole());
        String email = user.getEmail();
        return generateAcessToken(role, userId, email);
    }

    protected String generateAccessToken(PrincipalDetails principalDetails) {
        Collection<? extends GrantedAuthority> role = principalDetails.getAuthorities();
        List<UserRole> roles = role.stream().map(GrantedAuthority::getAuthority).map(UserRole::valueOf).collect(Collectors.toList());
        String userId = principalDetails.getUserId();
        String email = principalDetails.getEmail();
        String userNick = principalDetails.getNickname();

        return generateAcessToken(roles, userId, email, userNick);
    }

    private String generateAcessToken(List<UserRole> role, String userId, String email) {
        return generateAcessToken(role, userId, email, null);
    }

    private String generateAcessToken(List<UserRole> role, String userId, String email, String userNick) {
        var builder = Jwts.builder()
                .setSubject("access")
                .claim("role", role)
                .claim("userId", userId)
                .claim("email", email);
        if (userNick != null) {
            builder = builder.claim("userNick", userNick);
        }
        return builder
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + JwtValidity.ACCESS_TOKEN.getValidityInMillis()))
                .signWith(accessKey)
                .compact();
    }

    protected String generateRefreshToken(PrincipalDetails principalDetails) {
        String userId = principalDetails.getUserId();

        return Jwts.builder()
                .setSubject("refresh")
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + JwtValidity.REFRESH_TOKEN.getValidityInMillis()))
                .claim("userId", userId)
                .signWith(refreshKey)
                .compact();
    }

    @Override
    public TokenDto generateToken(Authentication authentication) {
        PrincipalDetails principalDetails = (PrincipalDetails) authentication.getPrincipal();
        return new TokenDto(
                generateAccessToken(principalDetails),
                generateRefreshToken(principalDetails)
        );
    }


    @Override
    public UsernamePasswordAuthenticationToken getAuthentication(String token) {
        try {
            Jws<Claims> claims = Jwts.parserBuilder()
                    .setSigningKey(accessKey)
                    .build()
                    .parseClaimsJws(token);

            String userId = claims.getBody().get("userId", String.class);
            List<String> role = claims.getBody().get("role", List.class);
            String email = claims.getBody().get("email", String.class);

            User user = User.builder()
                    .userId(userId)
                    .email(email)
                    .userRole(UserRole.valueOf(role.get(0)))
                    .build();


            UserBlockDto userBlock = this.userBlockService.getBlockCaching(userId);

            UserBlock checkUserBlock = null;
            if (userBlock != null && userBlock.getUnblockedAt() != null) {
                checkUserBlock = UserBlock.builder()
                        .unblockedAt(LocalDateTime.parse(userBlock.getUnblockedAt()))
                        .build();
            }

            UserDetails userDetails = new PrincipalDetails(user, checkUserBlock);
            return new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
        } catch (Exception e) {
            log.error("Error while parsing token: {}", e.getMessage());
            return null;
        }
    }

    // type 0: access token, type 1: refresh token
    @Override
    public boolean isTokenExpired(String token, int type) {
        try {
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(type == 0 ? accessKey : refreshKey)
                    .setAllowedClockSkewSeconds(60) // 60초 허용
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
            return claims.getExpiration().before(new Date());
        } catch (ExpiredJwtException e) {
            log.warn("Token expired: {}", e.getMessage());
            return true; // 토큰 만료
        } catch (UnsupportedJwtException e) {
            log.error("Unsupported JWT token: {}", e.getMessage());
            throw new IllegalArgumentException("지원되지 않는 JWT 토큰 형식입니다.", e);
        } catch (MalformedJwtException e) {
            log.error("Malformed JWT token: {}", e.getMessage());
            throw new IllegalArgumentException("잘못된 JWT 토큰 형식입니다.", e);
        } catch (IllegalArgumentException e) {
            log.error("Illegal argument for JWT parsing: {}", e.getMessage());
            throw new IllegalArgumentException("JWT 처리 중 잘못된 인수가 전달되었습니다.", e);
        } catch (Exception e) {
            log.error("Unknown error during JWT parsing: {}", e.getMessage());
            throw new RuntimeException("JWT 처리 중 알 수 없는 오류가 발생했습니다.", e);
        }
    }

    @Override
    public String getRefreshToken(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) {
            return null;
        }

        return Arrays.stream(cookies)
                .filter(cookie -> "refreshToken".equals(cookie.getName()))
                .map(Cookie::getValue)
                .findFirst()
                .orElse(null);
    }

    // parsing token
    // type 0: access token, type 1: refresh token
    @Override
    public Map<String, Object> parseToken(String token, int type)
    {
        Key key = (type == 0) ? this.accessKey : this.refreshKey;

        Jws<Claims> parsedToken = Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token);

        Map<String, Object> result = new HashMap<>();
        if (type == 0) {
            result.put("userId", parsedToken.getBody().get("userId"));
            result.put("email", parsedToken.getBody().get("email"));
            result.put("role", parsedToken.getBody().get("role"));
        } else {
            result.put("userId", parsedToken.getBody().get("userId"));
            result.put("exp", parsedToken.getBody().getExpiration());
        }
        return result;
    }

    // token 전달 시, response에 token을 담아서 전달.
    @Override
    public void loginResponse(HttpServletResponse response, TokenDto tokenDto, String deviceId) throws IOException {
        // response 초기화
        response.reset();

        // cookie-start
        Cookie newCookie = new Cookie("refreshToken", tokenDto.getRefreshToken());
        newCookie.setHttpOnly(true); // TODO : Http-only 으로 수정 | secure 설정
        newCookie.setSecure(true);
        newCookie.setDomain(null); // TODO : domain 설정  | test 하느라 null 설정함
        newCookie.setPath("/");
        response.addCookie(newCookie);
        // cookie-end

        response.setStatus(HttpServletResponse.SC_OK);
        response.getWriter().write(responseStatusManager.success(
                response,"TOKEN_REISSUED","토큰이 재발급되었습니다.","success"
        ));
        response.addHeader(Token.ACCESS_TOKEN_HEADER.getHeaderName(),
                Token.ACCESS_TOKEN_HEADER.createHeaderPrefix(tokenDto.getAccessToken()));
        response.addHeader(Token.REFRESH_TOKEN_HEADER.getHeaderName(),
                Token.REFRESH_TOKEN_HEADER.createHeaderPrefix(tokenDto.getRefreshToken()));
        response.addHeader(Token.DEVICE_ID_HEADER.getHeaderName(), deviceId);
    }

}
