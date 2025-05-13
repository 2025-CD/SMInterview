package sm.ac.app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import sm.ac.app.service.MatchService;

import java.util.Map;

@Controller
public class MatchController {

    @Autowired
    private MatchService matchService;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/match")
    public void requestMatch(Map<String, String> payload) {
        String userId = payload.get("userId");

        String matchedUserId = matchService.findMatch(userId);

        if (matchedUserId != null) {
            messagingTemplate.convertAndSendToUser(userId, "/queue/match-" + userId,
                    Map.of("matched", true, "otherUserId", matchedUserId));
            messagingTemplate.convertAndSendToUser(matchedUserId, "/queue/match-" + matchedUserId,
                    Map.of("matched", true, "otherUserId", userId));

            matchService.clearUserFromQueue(userId);
            matchService.clearUserFromQueue(matchedUserId);
        } else {
            matchService.addToQueue(userId, payload.get("sessionId"));
            messagingTemplate.convertAndSendToUser(userId, "/queue/match-" + userId,
                    Map.of("matched", false, "message", "매칭 대기 중..."));
        }
    }
}
