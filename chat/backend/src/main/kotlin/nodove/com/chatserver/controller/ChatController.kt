package nodove.com.chatserver.controller

import nodove.com.chatserver.dto.Message
import nodove.com.chatserver.service.ChatService
import org.slf4j.LoggerFactory
import org.springframework.messaging.handler.annotation.DestinationVariable
import org.springframework.messaging.handler.annotation.MessageMapping
import org.springframework.messaging.handler.annotation.Payload
import org.springframework.messaging.simp.SimpMessagingTemplate
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
class ChatController(
    private val chatService: ChatService,
    private val messageTemplate: SimpMessagingTemplate
) {

    private val log = LoggerFactory.getLogger(ChatController::class.java)

    @MessageMapping("/chat.sendMessage/{receiver}")
    fun sendMessage(
        @Payload message: Message,
        @DestinationVariable receiver: String
    ): Message {
        log.info("Message sent from ${message.sender} to ${message.receiver}: ${message.content}")

        // 메시지 저장
        val savedMessage = chatService.saveMessage(message)

        // 수신자에게 메시지 전송
        messageTemplate.convertAndSend("/topic/messages/${receiver}", savedMessage)
        // 송신자에게도 전송 (자신이 보낸 메시지 확인용)
        messageTemplate.convertAndSend("/topic/messages/${message.sender}", savedMessage)

        return savedMessage
    }

    @MessageMapping("/chat.addUser")
    fun addUser(@Payload message: Message): Message {
        log.info("User ${message.sender} joined chat")
        messageTemplate.convertAndSend("/topic/messages", message)
        return message
    }

    @GetMapping("/api/messages")
    fun getAllMessages(): List<Message> {
        return chatService.getAllMessages()
    }

    @GetMapping("/api/messages/between")
    fun getMessagesBetweenUsers(
        @RequestParam sender: String,
        @RequestParam receiver: String
    ): List<Message> {
        return chatService.getMessagesBetweenUsers(sender, receiver)
    }

    @GetMapping("/api/messages/sent/{sender}")
    fun getMessagesBySender(@PathVariable sender: String): List<Message> {
        return chatService.getMessagesBySender(sender)
    }

    @GetMapping("/api/messages/received/{receiver}")
    fun getMessagesByReceiver(@PathVariable receiver: String): List<Message> {
        return chatService.getMessagesByReceiver(receiver)
    }
}