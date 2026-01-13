package nodove.com.community.configuration

import nodove.com.community.security.JwtAuthenticationFilter
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configurers.*
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import org.springframework.web.cors.CorsConfigurationSource

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
class SecurityConfig(
    private val jwtAuthenticationFilter: JwtAuthenticationFilter
) {

    @Bean
    fun passwordEncoder(): PasswordEncoder = BCryptPasswordEncoder()

    @Bean
    @Throws(Exception::class)
    fun securityFilterChain(
        http: HttpSecurity,
        corsConfigurationSource: CorsConfigurationSource
    ): SecurityFilterChain {
        http
            .cors { cors: CorsConfigurer<HttpSecurity> -> 
                cors.configurationSource(corsConfigurationSource) 
            }
            .formLogin { formLogin: FormLoginConfigurer<HttpSecurity> -> 
                formLogin.disable() 
            }
            .csrf { csrf: CsrfConfigurer<HttpSecurity> -> 
                csrf.disable() 
            }
            .httpBasic { httpBasic: HttpBasicConfigurer<HttpSecurity> -> 
                httpBasic.disable() 
            }
            .sessionManagement { session: SessionManagementConfigurer<HttpSecurity?> ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            }
            .authorizeHttpRequests { requests ->
                requests
                    .requestMatchers("/").permitAll()
                    .requestMatchers("/index.html").permitAll()
                    .requestMatchers("/favicon.ico").permitAll()
                    .requestMatchers("/static/**").permitAll()
                    .requestMatchers("/assets/**").permitAll()
                    .requestMatchers("/api/health").permitAll()
                    .requestMatchers("/error").permitAll()
                    
                    .requestMatchers("/api/auth/login").permitAll()
                    .requestMatchers("/api/auth/register").permitAll()
                    
                    .requestMatchers(HttpMethod.GET, "/api/posts/**").permitAll()
                    .requestMatchers(HttpMethod.GET, "/api/categories/**").permitAll()
                    
                    .requestMatchers(HttpMethod.GET, "/api/ai/trending").permitAll()
                    .requestMatchers(HttpMethod.GET, "/api/ai/search").permitAll()
                    .requestMatchers("/api/ai/**").authenticated()
                    
                    .requestMatchers(HttpMethod.POST, "/api/posts/**").authenticated()
                    .requestMatchers(HttpMethod.PUT, "/api/posts/**").authenticated()
                    .requestMatchers(HttpMethod.DELETE, "/api/posts/**").authenticated()
                    
                    .requestMatchers("/api/auth/verify").authenticated()
                    .requestMatchers("/api/user/**").authenticated()
                    
                    .requestMatchers("/api/admin/**").hasRole("ADMIN")
                    .requestMatchers("/actuator/**").hasRole("ADMIN")
                    
                    .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
                    .requestMatchers("/ws/**").permitAll()
                    
                    .anyRequest().authenticated()
            }
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter::class.java)
        
        return http.build()
    }
}
