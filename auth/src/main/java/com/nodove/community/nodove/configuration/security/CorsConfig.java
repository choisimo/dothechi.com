package com.nodove.community.nodove.configuration.security;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


@Configuration
public class CorsConfig {

    @Value("${app.cors.allowed-origins:}")
    private String configuredOrigins;

    @Value("${spring.profiles.active:dev}")
    private String activeProfile;

    @Bean
    @Primary
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration corsConfiguration = new CorsConfiguration();

        corsConfiguration.setAllowedOriginPatterns(buildAllowedOrigins());
        corsConfiguration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        corsConfiguration.setAllowedHeaders(Arrays.asList(
            "Content-Type", 
            "Authorization", 
            "X-User-Id",
            "X-User-Name",
            "X-User-Avatar",
            "X-Requested-With", 
            "X-XSRF-TOKEN"
        ));
        corsConfiguration.setExposedHeaders(Arrays.asList("Authorization", "X-Total-Count"));
        corsConfiguration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", corsConfiguration);
        return source;
    }

    private List<String> buildAllowedOrigins() {
        List<String> origins = new ArrayList<>();

        if (configuredOrigins != null && !configuredOrigins.isBlank()) {
            String[] parts = configuredOrigins.split(",");
            for (String part : parts) {
                origins.add(part.trim());
            }
        }

        switch (activeProfile) {
            case "prod":
            case "production":
                origins.add("https://community.nodove.com");
                origins.add("https://*.nodove.com");
                break;
            case "staging":
                origins.add("https://staging.nodove.com");
                origins.add("https://*.nodove.com");
                origins.add("http://localhost:*");
                break;
            default:
                origins.add("http://localhost:*");
                origins.add("https://*.nodove.com");
                break;
        }

        return origins.stream().distinct().toList();
    }
}
