package nodove.com.chatserver.dto

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import java.time.LocalDateTime

@Document(collection = "messages")
data class Message (
    @Id val id: String? = null,
    val sender: String,
    val receiver: String,
    val content: String,
    val timestamp: LocalDateTime = LocalDateTime.now()
)
