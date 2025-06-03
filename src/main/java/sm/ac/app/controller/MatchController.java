//package sm.ac.app.controller;
//
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.messaging.handler.annotation.MessageMapping;
//import org.springframework.messaging.simp.SimpMessagingTemplate;
//import org.springframework.stereotype.Controller;
//import sm.ac.app.service.MatchService;
//
//import java.util.Map;
//
//@Controller
//public class MatchController {
//
//    @Autowired
//    private MatchService matchService;
//
//    @Autowired
//    private SimpMessagingTemplate messagingTemplate;
//
//    @MessageMapping("/app/match")
//    public void requestMatch(Map<String, String> payload) {
//        String userId = payload.get("userId");
//        String sessionId = payload.get("sessionId"); // sessionId도 활용 가능
//        if (sessionId == null) {
//            sessionId = "defaultSessionId"; // 또는 다른 방식으로 처리
//        }
//
//        System.out.println("매칭 요청 받음 - userId: " + userId + ", sessionId: " + sessionId);
//
//        String matchedUserId = matchService.findMatch(userId);
//
//        if (matchedUserId != null) {
//            System.out.println("매칭 성공 - " + userId + " vs " + matchedUserId);
//
//            // userId에게 매칭 성공 메시지 전송
//            // destination에서 "/user/"를 제거합니다. SimpMessagingTemplate이 자동으로 붙여줍니다.
//            messagingTemplate.convertAndSendToUser(userId, "/queue/match-" + userId, // 이 부분 수정!
//                    Map.of("matched", true, "otherUserId", matchedUserId));
//
//            // matchedUserId에게 매칭 성공 메시지 전송
//            // destination에서 "/user/"를 제거합니다.
//            messagingTemplate.convertAndSendToUser(matchedUserId, "/queue/match-" + matchedUserId, // 이 부분 수정!
//                    Map.of("matched", true, "otherUserId", userId));
//
//            matchService.clearUserFromQueue(userId);
//            matchService.clearUserFromQueue(matchedUserId);
//        } else {
//            System.out.println("매칭 실패 - 대기열에 추가: " + userId + ", sessionId: " + sessionId);
//            matchService.addToQueue(userId, sessionId);
//            // 매칭 실패 메시지 전송
//            // destination에서 "/user/"를 제거합니다.
//            messagingTemplate.convertAndSendToUser(userId, "/queue/match-" + userId, // 이 부분 수정!
//                    Map.of("matched", false, "message", "매칭 대기 중..."));
//        }
//    }
//}