package nodove.com.chatserver.service

import nodove.com.chatserver.domain.Room
import nodove.com.chatserver.dto.RoomDto
import nodove.com.chatserver.dto.RoomStatus
import nodove.com.chatserver.dto.RoomType
import nodove.com.chatserver.repository.RoomRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class RoomService(
    private val roomRepository: RoomRepository
) {

    @Transactional
    fun createRoom(roomDto: RoomDto): Room {
        val room = Room(
            host = roomDto.host,
            guests = roomDto.guest.toMutableList(),
            roomName = roomDto.roomName,
            roomType = roomDto.roomType,
            roomStatus = roomDto.roomStatus,
            roomPassword = roomDto.roomPassword.takeIf { it.isNotBlank() }
        )

        return roomRepository.save(room)
    }

    fun getRoom(roomId: String): Room {
        return roomRepository.findById(roomId)
            .orElseThrow { IllegalArgumentException("방을 찾을 수 없습니다.") }
    }

    fun getAllRooms(): List<Room> {
        return roomRepository.findAll()
    }

    fun getRoomsByHost(host: String): List<Room> {
        return roomRepository.findByHost(host)
    }

    fun getRoomsByGuest(guestId: String): List<Room> {
        return roomRepository.findByGuestsContaining(guestId)
    }

    fun getActiveRooms(): List<Room> {
        return roomRepository.findByRoomStatusIn(listOf(RoomStatus.ACTIVE, RoomStatus.WAITING))
    }

    fun searchRooms(query: String): List<Room> {
        return roomRepository.findByRoomNameContaining(query)
    }

    @Transactional
    fun addGuestToRoom(roomId: String, guestId: String): Room {
        val room = getRoom(roomId)

        if (room.roomType == RoomType.PRIVATE && room.roomPassword != null) {
            throw IllegalStateException("비밀방에는 비밀번호가 필요합니다.")
        }

        room.addGuest(guestId)
        return roomRepository.save(room)
    }

    @Transactional
    fun addGuestToRoomWithPassword(roomId: String, guestId: String, password: String): Room {
        val room = getRoom(roomId)

        if (room.roomType == RoomType.PRIVATE) {
            if (room.roomPassword != password) {
                throw IllegalArgumentException("비밀번호가 일치하지 않습니다.")
            }
        }

        room.addGuest(guestId)
        return roomRepository.save(room)
    }

    @Transactional
    fun removeGuestFromRoom(roomId: String, guestId: String): Room {
        val room = getRoom(roomId)
        room.removeGuest(guestId)
        return roomRepository.save(room)
    }

    @Transactional
    fun updateRoomStatus(roomId: String, status: RoomStatus): Room {
        val room = getRoom(roomId)
        room.updateStatus(status)
        return roomRepository.save(room)
    }

    @Transactional
    fun deleteRoom(roomId: String, userId: String) {
        val room = getRoom(roomId)

        if (room.host != userId) {
            throw IllegalArgumentException("방을 삭제할 권한이 없습니다.")
        }

        room.updateStatus(RoomStatus.DELETED)
        roomRepository.save(room)
    }
}
