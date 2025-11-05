package nodove.com.chatserver.domain

import nodove.com.chatserver.dto.RoomStatus
import nodove.com.chatserver.dto.RoomType
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import java.time.LocalDateTime

@Document(collection = "rooms")
data class Room(
    @Id
    val id: String? = null,

    val host: String,

    val guests: MutableList<String> = mutableListOf(),

    val roomName: String,

    val roomType: RoomType,

    var roomStatus: RoomStatus,

    val roomPassword: String? = null,

    val createdAt: LocalDateTime = LocalDateTime.now(),

    var updatedAt: LocalDateTime = LocalDateTime.now()
) {
    fun addGuest(userId: String) {
        if (!guests.contains(userId)) {
            guests.add(userId)
            updatedAt = LocalDateTime.now()
        }
    }

    fun removeGuest(userId: String) {
        guests.remove(userId)
        updatedAt = LocalDateTime.now()
    }

    fun updateStatus(status: RoomStatus) {
        roomStatus = status
        updatedAt = LocalDateTime.now()
    }
}
