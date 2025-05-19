//package sm.ac.app.controller;
//
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.messaging.handler.annotation.MessageMapping;
//import org.springframework.messaging.simp.SimpMessagingTemplate;
//import org.springframework.stereotype.Controller;
//
//import java.util.Map;
//
//@Controller
//public class SignalingController {
//
//    @Autowired
//    private SimpMessagingTemplate messagingTemplate;
//
//    @MessageMapping("/signal-{receiverId}")
//    public void relaySignalingMessage(@org.springframework.messaging.handler.annotation.Payload Map<String, Object> message,
//                                      @org.springframework.messaging.handler.annotation.DestinationVariable String receiverId) {
//        // 메시지 타입에 senderId 추가
//        message.put("senderId", message.get("userId")); // userId를 senderId로 사용
//        messagingTemplate.convertAndSendToUser(receiverId, "/queue/signal", message);
//        System.out.println("시그널링 메시지 relay: to " + receiverId + ", message: " + message);
//    }
//}
