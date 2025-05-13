//package sm.ac.app.controller;
//
//import lombok.RequiredArgsConstructor;
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.messaging.handler.annotation.MessageMapping;
//import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
//import org.springframework.messaging.simp.SimpMessagingTemplate;
//import org.springframework.stereotype.Controller;
//import sm.ac.app.service.MatchingService;
//
//
//
//
//
//import org.springframework.context.event.EventListener;
//
//import org.springframework.web.socket.messaging.SessionDisconnectEvent; // 이벤트 리스너를 위해 임포트
//import sm.ac.app.service.MatchingService;
//
//import java.security.Principal; // 사용자 정보를 위해 임포트
//
//@Slf4j
//@Controller
//@RequiredArgsConstructor
//public class SignalController {
//
//    private final MatchingService matchingService;
//    private final SimpMessagingTemplate messagingTemplate; // 특정 사용자에게 메시지를 보내기 위함
//
//    // WebSocket 세션과 사용자 정보 매핑은 Spring Security 또는 Principal 객체를 통해 관리됩니다.
//    // 여기서는 MatchingService가 사용자 ID 기반으로 동작하도록 변경합니다.
//
//    // --- Message Handlers ---
//
//    // 매칭 요청 처리
//    @MessageMapping("/match.request")
//    // Principal 객체를 추가하여 현재 로그인한 사용자 정보를 얻습니다.
//    public void handleMatchRequest(SimpMessageHeaderAccessor headerAccessor, Principal principal) {
//        // Principal이 null이면 인증되지 않은 사용자입니다.
//        if (principal == null || principal.getName() == null) {
//            log.warn("[Match Request] Unauthenticated user. Cannot add to queue.");
//            // 인증되지 않은 사용자에 대한 처리 (예: 에러 메시지 전송) 필요
//            return;
//        }
//
//        // Principal의 getName()이 사용자 ID를 반환한다고 가정 (Spring Security 설정에 따라 달라짐)
//        String userId = principal.getName();
//        log.info("[Match Request] User ID: {}", userId);
//
//        // MatchingService에 사용자 ID와 콜백 함수 전달
//        matchingService.addWaitingUser(userId, this::notifyMatchResult);
//    }
//
//    // WebRTC Offer 메시지 처리 및 전달
//    @MessageMapping("/signal.offer")
//    // Principal 객체를 추가하여 발신자 정보를 얻습니다.
//    public void handleOffer(SignalMessage message, Principal principal) {
//        if (principal == null || principal.getName() == null) {
//            log.warn("[Offer] Unauthenticated user. Ignoring.");
//            return;
//        }
//        String senderUserId = principal.getName();
//        String receiverUserId = matchingService.getMatchedPartner(senderUserId);
//        log.info("[Offer] From User: {}, To User: {}, SDP: {}", senderUserId, receiverUserId, message.getSdp().substring(0, Math.min(message.getSdp().length(), 30)) + "..."); // 로그 길이 제한
//
//        if (receiverUserId != null) {
//            // 메시지에 발신자 사용자 ID 추가 (클라이언트에서 사용할 수 있도록)
//            message.setSender(senderUserId);
//            message.setReceiver(receiverUserId); // 수신자도 메시지에 포함시키면 클라이언트에서 편리할 수 있음
//
//            // 특정 사용자에게 메시지 전송 (STOMP /user/{userId} 목적지 사용)
//            // /queue/signal 은 컨벤션에 따라 사용자가 개별적으로 받는 메시지 큐를 의미합니다.
//            messagingTemplate.convertAndSendToUser(receiverUserId, "/queue/signal", message);
//            log.info("Sent Offer from {} to {}", senderUserId, receiverUserId);
//
//        } else {
//            log.warn("[Offer] No matched partner found for user: {}", senderUserId);
//            // 매칭된 상대가 없으면 클라이언트에게 오류 알림 등 추가 처리 필요
//        }
//    }
//
//    // WebRTC Answer 메시지 처리 및 전달
//    @MessageMapping("/signal.answer")
//    public void handleAnswer(SignalMessage message, Principal principal) {
//        if (principal == null || principal.getName() == null) {
//            log.warn("[Answer] Unauthenticated user. Ignoring.");
//            return;
//        }
//        String senderUserId = principal.getName();
//        String receiverUserId = matchingService.getMatchedPartner(senderUserId);
//        log.info("[Answer] From User: {}, To User: {}, SDP: {}", senderUserId, receiverUserId, message.getSdp().substring(0, Math.min(message.getSdp().length(), 30)) + "..."); // 로그 길이 제한
//
//        if (receiverUserId != null) {
//            message.setSender(senderUserId);
//            message.setReceiver(receiverUserId);
//            messagingTemplate.convertAndSendToUser(receiverUserId, "/queue/signal", message);
//            log.info("Sent Answer from {} to {}", senderUserId, receiverUserId);
//        } else {
//            log.warn("[Answer] No matched partner found for user: {}", senderUserId);
//        }
//    }
//
//    // WebRTC ICE Candidate 메시지 처리 및 전달
//    @MessageMapping("/signal.ice")
//    public void handleIceCandidate(SignalMessage message, Principal principal) {
//        if (principal == null || principal.getName() == null) {
//            log.warn("[ICE] Unauthenticated user. Ignoring.");
//            return;
//        }
//        String senderUserId = principal.getName();
//        String receiverUserId = matchingService.getMatchedPartner(senderUserId);
//        // Candidate 객체 전체 로깅은 너무 길 수 있으니 적절히 조절
//        log.info("[ICE] From User: {}, To User: {}, Candidate (partial): {}", senderUserId, receiverUserId, message.getCandidate() != null ? message.getCandidate().toString().substring(0, Math.min(message.getCandidate().toString().length(), 30)) + "..." : "null");
//
//        if (receiverUserId != null) {
//            message.setSender(senderUserId);
//            message.setReceiver(receiverUserId);
//            messagingTemplate.convertAndSendToUser(receiverUserId, "/queue/signal", message);
//            log.info("Sent ICE Candidate from {} to {}", senderUserId, receiverUserId);
//        } else {
//            log.warn("[ICE] No matched partner found for user: {}", senderUserId);
//        }
//    }
//
//    // 연결 종료 메시지 처리 (사용자가 '연결 종료' 버튼을 눌렀을 때)
//    @MessageMapping("/signal.hangup")
//    public void handleHangup(Principal principal) {
//        if (principal == null || principal.getName() == null) {
//            log.warn("[Hangup] Unauthenticated user. Ignoring.");
//            return;
//        }
//        String userId = principal.getName();
//        log.info("[Hangup] User ID: {}", userId);
//
//        String partnerUserId = matchingService.getMatchedPartner(userId);
//
//        // MatchingService에서 매칭 정보 먼저 제거
//        matchingService.removeUser(userId);
//
//        if (partnerUserId != null) {
//            log.info("Notifying partner {} about hangup from {}.", partnerUserId, userId);
//            // 상대방에게 종료 알림 메시지 전송
//            SignalMessage hangupMessage = new SignalMessage();
//            hangupMessage.setType("hangup");
//            hangupMessage.setSender(userId); // 누가 종료했는지 알림
//            hangupMessage.setReceiver(partnerUserId);
//            messagingTemplate.convertAndSendToUser(partnerUserId, "/queue/signal", hangupMessage);
//        } else {
//            log.warn("Hangup: Partner not found for user {}. Maybe already disconnected.", userId);
//        }
//    }
//
//
//    // --- Callbacks ---
//
//    // 매칭 결과를 클라이언트에게 알리는 콜백 메서드 (MatchingService에서 호출됨)
//    // 이제 사용자 ID를 인자로 받습니다.
//    private void notifyMatchResult(String user1Id, String user2Id) {
//        log.info("[Match Found] User1 ID: {}, User2 ID: {}", user1Id, user2Id);
//
//        // 클라이언트에게 보낼 매칭 결과 메시지 생성
//        // partnerId 필드에 상대방의 사용자 ID를 담아 보냅니다.
//        MatchResultMessage result1 = new MatchResultMessage("match_found", user2Id);
//        MatchResultMessage result2 = new MatchResultMessage("match_found", user1Id);
//
//        // 각 사용자에게 개별적으로 메시지 전송
//        messagingTemplate.convertAndSendToUser(user1Id, "/queue/signal", result1);
//        log.info("Sent match_found to user {}", user1Id);
//        messagingTemplate.convertAndSendToUser(user2Id, "/queue/signal", result2);
//        log.info("Sent match_found to user {}", user2Id);
//    }
//
//
//    // --- Event Listener ---
//
//    // WebSocket 연결 해제 이벤트 처리
//    // @EventListener 어노테이션을 사용하여 스프링이 이 이벤트를 감지하고 이 메소드를 실행하도록 합니다.
//    @EventListener
//    public void handleSessionDisconnect(SessionDisconnectEvent event) {
//        String sessionId = event.getSessionId();
//        Principal principal = event.getUser(); // 연결 해제된 세션의 사용자 정보
//
//        if (principal != null && principal.getName() != null) {
//            String userId = principal.getName();
//            log.info("[Session Disconnect] User ID: {}, Session ID: {}", userId, sessionId);
//            // MatchingService에 해당 사용자 ID를 제거하도록 요청
//            // 사용자의 모든 세션이 끊어졌을 때만 매칭 서비스에서 완전히 제거할지,
//            // 아니면 세션 하나만 끊어져도 일단 매칭 대기/매칭 상태에서 제외할지는 정책에 따라 다릅니다.
//            // 여기서는 세션 하나가 끊어져도 매칭 대기/매칭 상태에서 제외하는 것으로 구현합니다.
//            matchingService.removeUser(userId);
//            log.info("Removed user {} from matching service due to session disconnect.", userId);
//
//            // 만약 이 사용자가 매칭된 상대방이 있었다면, 상대방에게도 연결 끊김 알림 필요
//            // (removeUser 내부에서 처리하거나, 별도의 로직 추가)
//            // 현재 removeUser에서는 매칭 정보만 정리하고 상대방 알림은 SignalController의 hangup에서 명시적으로 보냄
//            // 세션 종료 시 상대방 알림 로직은 removeUser 후에 여기서 추가하는 것이 더 명확할 수 있습니다.
//            // String partnerUserId = matchingService.getMatchedPartner(userId); // 이 시점에는 이미 removeUser로 인해 partnerId가 없을 수 있음
//            // => MatchingService의 removeUser 메소드에서 제거 전에 파트너를 찾아서 반환하도록 수정하거나, 다른 방식으로 상대방을 찾아야 함.
//            // 간단하게는 removeUser가 제거 전 파트너를 찾아서 제거하고 파트너 ID를 반환하게 하고, 여기서 알림 보냄.
//            // 또는, MatchingService 내부에서 연결 끊긴 사용자의 파트너에게 메시지 보내는 로직 추가.
//            // 여기서는 일단 복잡성을 줄이기 위해 MatchingService에서 매칭 정보만 정리하고, 알림은 hangup 버튼 클릭 시에만 명시적으로 보내는 것으로 유지.
//            // 실제 서비스에서는 SessionDisconnect 시에도 상대방에게 끊김 알림을 보내는 것이 필요합니다.
//        } else {
//            log.info("[Session Disconnect] Unauthenticated session ID: {}", sessionId);
//            // 인증되지 않은 세션 해제에 대한 처리 (예: 대기열에 인증되지 않은 사용자가 있었다면 제거)
//            // 현재 addWaitingUser는 인증된 사용자만 받으므로 여기서는 특별히 할 일 없을 수 있습니다.
//        }
//    }
//
//
//    // --- DTOs ---
//
//    // 메시지 구조를 위한 간단한 DTO (실제 필요한 필드 추가/수정 필요)
//    @lombok.Data
//    static class SignalMessage {
//        private String type; // offer, answer, ice, hangup 등
//        private String sender; // 메시지 발신자 (서버에서 설정 - 사용자 ID)
//        private String receiver; // 메시지 수신자 (서버에서 설정 - 사용자 ID)
//        private String sdp; // SDP 정보 (offer, answer 용)
//        private Object candidate; // ICE candidate 정보 (ice 용)
//        // 기타 필요한 필드 추가 가능 (예: 미디어 타입 등)
//    }
//
//    @lombok.Data
//    @lombok.AllArgsConstructor
//    static class MatchResultMessage {
//        private String type; // "match_found"
//        private String partnerId; // 매칭된 상대방의 사용자 ID
//    }
//
//    // 참고: Principal 객체를 사용하려면 Spring Security 설정 또는 WebSocket 설정에서
//    // 사용자 정보를 WebSocket 세션과 연결하는 로직 (예: DefaultHandshakeHandler 커스터마이징) 필요
//}