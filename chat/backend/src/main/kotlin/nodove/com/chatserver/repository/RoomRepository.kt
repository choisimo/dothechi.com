package nodove.com.chatserver.repository

import nodove.com.chatserver.domain.Room
import nodove.com.chatserver.dto.RoomStatus
import nodove.com.chatserver.dto.RoomType
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository

@Repository
interface RoomRepository : MongoRepository<Room, String> {

    // 호스트로 방 찾기
    fun findByHost(host: String): List<Room>

    // 게스트로 방 찾기
    fun findByGuestsContaining(guestId: String): List<Room>

    // 상태로 방 찾기
    fun findByRoomStatus(status: RoomStatus): List<Room>

    // 타입으로 방 찾기
    fun findByRoomType(type: RoomType): List<Room>

    // 방 이름으로 검색
    fun findByRoomNameContaining(roomName: String): List<Room>

    // 활성화된 방 목록
    fun findByRoomStatusIn(statuses: List<RoomStatus>): List<Room>
}
