package nodove.com.chatserver.controller

import nodove.com.chatserver.domain.Room
import nodove.com.chatserver.dto.RoomDto
import nodove.com.chatserver.dto.RoomStatus
import nodove.com.chatserver.service.RoomService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api")
class RoomController(
    private val roomService: RoomService
) {

    @PostMapping("/room")
    fun createRoom(@RequestBody roomDto: RoomDto): ResponseEntity<Map<String, Any>> {
        val room = roomService.createRoom(roomDto)
        return ResponseEntity.ok(mapOf(
            "status" to "success",
            "message" to "방이 생성되었습니다.",
            "data" to room
        ))
    }

    @GetMapping("/room/{roomId}")
    fun getRoom(@PathVariable roomId: String): ResponseEntity<Map<String, Any>> {
        val room = roomService.getRoom(roomId)
        return ResponseEntity.ok(mapOf(
            "status" to "success",
            "data" to room
        ))
    }

    @GetMapping("/rooms")
    fun getAllRooms(): ResponseEntity<Map<String, Any>> {
        val rooms = roomService.getAllRooms()
        return ResponseEntity.ok(mapOf(
            "status" to "success",
            "data" to rooms
        ))
    }

    @GetMapping("/rooms/active")
    fun getActiveRooms(): ResponseEntity<Map<String, Any>> {
        val rooms = roomService.getActiveRooms()
        return ResponseEntity.ok(mapOf(
            "status" to "success",
            "data" to rooms
        ))
    }

    @GetMapping("/rooms/host/{hostId}")
    fun getRoomsByHost(@PathVariable hostId: String): ResponseEntity<Map<String, Any>> {
        val rooms = roomService.getRoomsByHost(hostId)
        return ResponseEntity.ok(mapOf(
            "status" to "success",
            "data" to rooms
        ))
    }

    @GetMapping("/rooms/guest/{guestId}")
    fun getRoomsByGuest(@PathVariable guestId: String): ResponseEntity<Map<String, Any>> {
        val rooms = roomService.getRoomsByGuest(guestId)
        return ResponseEntity.ok(mapOf(
            "status" to "success",
            "data" to rooms
        ))
    }

    @GetMapping("/rooms/search")
    fun searchRooms(@RequestParam query: String): ResponseEntity<Map<String, Any>> {
        val rooms = roomService.searchRooms(query)
        return ResponseEntity.ok(mapOf(
            "status" to "success",
            "data" to rooms
        ))
    }

    @PostMapping("/room/{roomId}/join")
    fun joinRoom(
        @PathVariable roomId: String,
        @RequestParam userId: String,
        @RequestParam(required = false) password: String?
    ): ResponseEntity<Map<String, Any>> {
        val room = if (password != null) {
            roomService.addGuestToRoomWithPassword(roomId, userId, password)
        } else {
            roomService.addGuestToRoom(roomId, userId)
        }
        return ResponseEntity.ok(mapOf(
            "status" to "success",
            "message" to "방에 참여했습니다.",
            "data" to room
        ))
    }

    @PostMapping("/room/{roomId}/leave")
    fun leaveRoom(
        @PathVariable roomId: String,
        @RequestParam userId: String
    ): ResponseEntity<Map<String, Any>> {
        val room = roomService.removeGuestFromRoom(roomId, userId)
        return ResponseEntity.ok(mapOf(
            "status" to "success",
            "message" to "방에서 나갔습니다.",
            "data" to room
        ))
    }

    @PatchMapping("/room/{roomId}/status")
    fun updateRoomStatus(
        @PathVariable roomId: String,
        @RequestParam status: RoomStatus
    ): ResponseEntity<Map<String, Any>> {
        val room = roomService.updateRoomStatus(roomId, status)
        return ResponseEntity.ok(mapOf(
            "status" to "success",
            "message" to "방 상태가 변경되었습니다.",
            "data" to room
        ))
    }

    @DeleteMapping("/room/{roomId}")
    fun deleteRoom(
        @PathVariable roomId: String,
        @RequestParam userId: String
    ): ResponseEntity<Map<String, Any>> {
        roomService.deleteRoom(roomId, userId)
        return ResponseEntity.ok(mapOf(
            "status" to "success",
            "message" to "방이 삭제되었습니다."
        ))
    }
}