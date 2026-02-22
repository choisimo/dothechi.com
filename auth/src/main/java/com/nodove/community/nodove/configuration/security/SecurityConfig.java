package com.nodove.community.nodove.configuration.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.nodove.community.nodove.configuration.security.JWT.JwtUtilityManager;
import com.nodove.community.nodove.filter.AuthenticationFilter;
import com.nodove.community.nodove.filter.AuthorizationFilter;
import com.nodove.community.nodove.service.RedisServiceManager;
import com.nodove.community.nodove.service.UserServiceManager;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.security.servlet.PathRequest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

@Slf4j
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtUtilityManager jwtUtility;
    private final RedisServiceManager redisService;
    private final UserServiceManager userService;

    private final AuthenticationConfiguration authenticationConfiguration;
    private final CorsConfigurationSource corsConfigurationSource;
    private final ObjectMapper objectMapper;

    private final List<String> permitList = Arrays.asList(
            "/auth/login",
            "/auth/register",
            "/auth/refresh",
            "/join/email/check",
            "/join/email/resend",
            "/swagger-ui.html",
            "/swagger-ui/**",
            "/v3/api-docs/**",
            "/swagger-resources/**"
    );

    @Bean
    public AuthenticationManager authenticationManager() throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.cors(cors -> cors.configurationSource(this.corsConfigurationSource));
        http.formLogin(AbstractHttpConfigurer::disable);
        http.csrf(AbstractHttpConfigurer::disable);
        http.httpBasic(AbstractHttpConfigurer::disable);
        http.sessionManagement(management->management.sessionCreationPolicy(SessionCreationPolicy.STATELESS));
        http.addFilterBefore(new AuthorizationFilter(this.jwtUtility, this.objectMapper, this.redisService, this.userService), UsernamePasswordAuthenticationFilter.class);
        http.addFilterAt(new AuthenticationFilter(authenticationManager(), this.jwtUtility, this.objectMapper, this.redisService, this.userService), UsernamePasswordAuthenticationFilter.class);

        http.authorizeHttpRequests((authorize) -> {
            authorize.requestMatchers(PathRequest.toStaticResources().atCommonLocations()).permitAll();
            authorize.requestMatchers(this.permitList.toArray(new String[0])).permitAll();  // 인증 없이 접근 가능
            authorize.requestMatchers("/api/private").hasAnyAuthority("ADMIN", "ROLE_ADMIN");
            authorize.requestMatchers("/api/protected").hasAnyAuthority("USER", "ROLE_USER", "ADMIN", "ROLE_ADMIN");
            authorize.requestMatchers("/api/public").permitAll();
            authorize.anyRequest().permitAll();
            });
        return http.build();
    }

}
