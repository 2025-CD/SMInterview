package sm.ac.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import sm.ac.app.service.MatchingService;

@Slf4j
@Controller
@RequiredArgsConstructor
public class SignalController {

    private final MatchingService matchingService;
    private final SimpMessagingTemplate messagingTemplate; // 특정 사용자에게 메시지를 보내기 위함

    // 사용자의 WebSocket 세션 ID와 매칭된 상대방 세션 ID를 저장 (실제로는 더 견고한 관리 필요)
    // 예: Map<String, String> userSessionMap = new ConcurrentHashMap<>();

    // 매칭 요청 처리
    @MessageMapping("/match.request")
    public void handleMatchRequest(SimpMessageHeaderAccessor headerAccessor) {
        String sessionId = headerAccessor.getSessionId();
        log.info("[Match Request] Session ID: {}", sessionId);
        matchingService.addWaitingUser(sessionId, this::notifyMatchResult); // 매칭 서비스에 대기열 추가 요청
    }

    // WebRTC Offer 메시지 처리 및 전달
    @MessageMapping("/signal.offer")
    public void handleOffer(SignalMessage message, SimpMessageHeaderAccessor headerAccessor) {
        String senderSessionId = headerAccessor.getSessionId();
        String receiverSessionId = matchingService.getMatchedPartner(senderSessionId);
        log.info("[Offer] From: {}, To: {}, SDP: {}", senderSessionId, receiverSessionId, message.getSdp().substring(0, 30));

        if (receiverSessionId != null) {
            message.setSender(senderSessionId); // 메시지에 발신자 정보 추가
            // STOMP에서는 특정 세션 ID로 직접 메시지를 보내기 어려울 수 있음.
            // 보통 사용자 ID(Principal) 기반으로 /user/{username}/topic/signal 형태로 보냄.
            // 여기서는 단순화를 위해 /topic/signal/{receiverSessionId} 같은 형태로 가정하거나,
            // WebSocket 세션 관리 및 직접 전송 로직 필요.
            // SimpMessagingTemplate 사용 예시 (Principal 기반)
            // messagingTemplate.convertAndSendToUser(receiverUsername, "/topic/signal", message);

            // 임시: /topic/signal/{sessionId} 구독자에게 메시지 전송
            messagingTemplate.convertAndSend("/topic/signal/" + receiverSessionId, message);
        } else {
            log.warn("[Offer] No matched partner found for session: {}", senderSessionId);
        }
    }

    // WebRTC Answer 메시지 처리 및 전달
    @MessageMapping("/signal.answer")
    public void handleAnswer(SignalMessage message, SimpMessageHeaderAccessor headerAccessor) {
        String senderSessionId = headerAccessor.getSessionId();
        String receiverSessionId = matchingService.getMatchedPartner(senderSessionId);
        log.info("[Answer] From: {}, To: {}, SDP: {}", senderSessionId, receiverSessionId, message.getSdp().substring(0, 30));

        if (receiverSessionId != null) {
            message.setSender(senderSessionId);
            messagingTemplate.convertAndSend("/topic/signal/" + receiverSessionId, message);
        } else {
            log.warn("[Answer] No matched partner found for session: {}", senderSessionId);
        }
    }

    // WebRTC ICE Candidate 메시지 처리 및 전달
    @MessageMapping("/signal.ice")
    public void handleIceCandidate(SignalMessage message, SimpMessageHeaderAccessor headerAccessor) {
        String senderSessionId = headerAccessor.getSessionId();
        String receiverSessionId = matchingService.getMatchedPartner(senderSessionId);
        log.info("[ICE] From: {}, To: {}, Candidate: {}", senderSessionId, receiverSessionId, message.getCandidate());

        if (receiverSessionId != null) {
            message.setSender(senderSessionId);
            messagingTemplate.convertAndSend("/topic/signal/" + receiverSessionId, message);
        } else {
            log.warn("[ICE] No matched partner found for session: {}", senderSessionId);
        }
    }

    // 연결 종료 메시지 처리
    @MessageMapping("/signal.hangup")
    public void handleHangup(SimpMessageHeaderAccessor headerAccessor) {
        String sessionId = headerAccessor.getSessionId();
        log.info("[Hangup] Session ID: {}", sessionId);
        String partnerSessionId = matchingService.getMatchedPartner(sessionId);
        if (partnerSessionId != null) {
            // 상대방에게 종료 알림
            SignalMessage hangupMessage = new SignalMessage();
            hangupMessage.setType("hangup");
            hangupMessage.setSender(sessionId);
            messagingTemplate.convertAndSend("/topic/signal/" + partnerSessionId, hangupMessage);
        }
        matchingService.removeUser(sessionId); // 매칭 정보 제거
    }


    // 매칭 결과를 클라이언트에게 알리는 콜백 메서드
    private void notifyMatchResult(String user1, String user2) {
        log.info("[Match Found] User1: {}, User2: {}", user1, user2);
        MatchResultMessage result1 = new MatchResultMessage("match_found", user2);
        MatchResultMessage result2 = new MatchResultMessage("match_found", user1);

        messagingTemplate.convertAndSend("/topic/signal/" + user1, result1);
        messagingTemplate.convertAndSend("/topic/signal/" + user2, result2);
    }

    // 메시지 구조를 위한 간단한 DTO (실제 필요한 필드 추가/수정 필요)
    @lombok.Data
    static class SignalMessage {
        private String type; // offer, answer, ice, hangup 등
        private String sender; // 메시지 발신자 (서버에서 설정)
        private String sdp; // SDP 정보 (offer, answer 용)
        private Object candidate; // ICE candidate 정보 (ice 용)
    }

    @lombok.Data
    @lombok.AllArgsConstructor
    static class MatchResultMessage {
        private String type;
        private String partnerId; // 매칭된 상대방의 임시 ID (세션 ID 등)
    }

    // 참고: WebSocket 연결 해제 시 @EventListener(SessionDisconnectEvent.class) 를 사용하여
    // matchingService.removeUser(sessionId) 호출 등 정리 로직 필요
}
