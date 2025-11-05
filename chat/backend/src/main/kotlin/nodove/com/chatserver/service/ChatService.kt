package nodove.com.chatserver.service

import nodove.com.chatserver.dto.Message
import nodove.com.chatserver.repository.MessageRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime

@Service
@Transactional(readOnly = true)
class ChatService(
    private val messageRepository: MessageRepository
) {

    @Transactional
    fun saveMessage(message: Message): Message {
        return messageRepository.save(message)
    }

    fun getAllMessages(): List<Message> {
        return messageRepository.findAllByOrderByTimestampAsc()
    }

    fun getMessagesBetweenUsers(sender: String, receiver: String): List<Message> {
        return messageRepository.findAllByOrderByTimestampAsc()
            .filter {
                (it.sender == sender && it.receiver == receiver) ||
                (it.sender == receiver && it.receiver == sender)
            }
    }

    fun getMessagesBySender(sender: String): List<Message> {
        return messageRepository.findAllByOrderByTimestampAsc()
            .filter { it.sender == sender }
    }

    fun getMessagesByReceiver(receiver: String): List<Message> {
        return messageRepository.findAllByOrderByTimestampAsc()
            .filter { it.receiver == receiver }
    }
}
