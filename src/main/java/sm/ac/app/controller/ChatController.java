package sm.ac.app.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import sm.ac.app.dto.ChatMessage;

@Controller
public class ChatController {

    private final SimpMessagingTemplate messagingTemplate;

    public ChatController(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    @MessageMapping("/chat/{roomId}")
    public void sendMessage(@DestinationVariable String roomId, @Payload ChatMessage message) {
        // 여기에 데이터베이스 저장이나 유효성 검사 등 추가 로직을 넣을 수 있습니다.
        // 실시간 채팅의 경우 보통 수신 즉시 다시 브로드캐스트합니다.
        messagingTemplate.convertAndSend("/topic/chat/" + roomId, message);
    }
}
