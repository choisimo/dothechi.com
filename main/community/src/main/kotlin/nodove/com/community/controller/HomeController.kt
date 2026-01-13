package nodove.com.community.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import java.time.Instant

@Tag(name = "Home", description = "홈 및 상태 API")
@RestController
class HomeController {

    data class HealthResponse(
        val status: String,
        val service: String,
        val version: String,
        val timestamp: String,
        val endpoints: Map<String, String>
    )

    @Operation(summary = "API 상태 확인")
    @GetMapping("/api/health")
    fun health(): ResponseEntity<HealthResponse> {
        return ResponseEntity.ok(
            HealthResponse(
                status = "UP",
                service = "Community API",
                version = "0.0.1-SNAPSHOT",
                timestamp = Instant.now().toString(),
                endpoints = mapOf(
                    "posts" to "/api/posts",
                    "categories" to "/api/categories",
                    "ai" to "/api/ai",
                    "swagger" to "/swagger-ui/index.html",
                    "api-docs" to "/v3/api-docs"
                )
            )
        )
    }

    @Operation(summary = "루트 리다이렉트")
    @GetMapping("/")
    fun root(): ResponseEntity<HealthResponse> {
        return health()
    }
}
