package nodove.com.community.configuration

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configurers.*
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.core.Authentication
import org.springframework.security.web.SecurityFilterChain
import org.springframework.web.cors.CorsConfigurationSource

@Configuration
@EnableWebSecurity
class SecurityConfig {

    @Bean
    fun authenticationManager(): AuthenticationManager {
        return AuthenticationManager { authentication: Authentication -> authentication }
    }

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
                    // Public endpoints
                    .requestMatchers("/api/posts/**").permitAll()
                    .requestMatchers("/api/categories/**").permitAll()
                    .requestMatchers("/api/ai/**").permitAll()
                    .requestMatchers("/actuator/**").permitAll()
                    .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
                    // All other requests need authentication
                    .anyRequest().authenticated()
            }
        
        return http.build()
    }
}
