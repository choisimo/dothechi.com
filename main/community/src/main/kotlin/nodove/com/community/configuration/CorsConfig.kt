package nodove.com.community.configuration

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource

@Configuration
class CorsConfig(
    @Value("\${app.cors.allowed-origins:}") 
    private val configuredOrigins: String,
    
    @Value("\${spring.profiles.active:dev}")
    private val activeProfile: String
) {

    @Bean
    fun corsConfigurationSource(): CorsConfigurationSource {
        val source = UrlBasedCorsConfigurationSource()
        val config = CorsConfiguration()

        config.allowCredentials = true
        config.allowedOriginPatterns = buildAllowedOrigins()
        config.allowedHeaders = listOf(
            "Content-Type", 
            "Authorization", 
            "X-User-Id",
            "X-User-Name",
            "X-User-Avatar",
            "X-Requested-With",
            "X-XSRF-TOKEN"
        )
        config.allowedMethods = listOf("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
        config.exposedHeaders = listOf("Authorization", "X-Total-Count")
        
        source.registerCorsConfiguration("/**", config)
        return source
    }
    
    private fun buildAllowedOrigins(): List<String> {
        val origins = mutableListOf<String>()
        
        if (configuredOrigins.isNotBlank()) {
            origins.addAll(configuredOrigins.split(",").map { it.trim() })
        }
        
        when (activeProfile) {
            "prod", "production" -> {
                origins.add("https://community.nodove.com")
                origins.add("https://*.nodove.com")
            }
            "staging" -> {
                origins.add("https://staging.nodove.com")
                origins.add("https://*.nodove.com")
                origins.add("http://localhost:*")
            }
            else -> {
                origins.add("http://localhost:*")
                origins.add("https://*.nodove.com")
            }
        }
        
        return origins.distinct()
    }
}
