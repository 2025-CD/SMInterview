package sm.ac.app.service;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

@Service
public class MatchService {

    private final Queue<String> waitingQueue = new ConcurrentLinkedQueue<>();
    private final Map<String, String> userSessionId = new ConcurrentHashMap<>();

    public void addToQueue(String userId, String sessionId) {
        waitingQueue.offer(userId);
        userSessionId.put(userId, sessionId);
        System.out.println("매칭 대기열 추가: " + userId);
        System.out.println("현재 대기열: " + waitingQueue);
    }

    public String findMatch(String userId) {
        for (String otherUserId : waitingQueue) {
            if (!otherUserId.equals(userId)) {
                // 상대 유저를 큐에서 제거만 하고, 현재 유저는 컨트롤러에서 제거
                waitingQueue.remove(otherUserId);
                System.out.println("매칭 성공 후보: " + userId + " vs " + otherUserId);
                return otherUserId;
            }
        }
        return null;
    }

    public void clearUserFromQueue(String userId) {
        waitingQueue.removeIf(user -> user.equals(userId));
        userSessionId.remove(userId);
        System.out.println("매칭 대기열 제거: " + userId);
        System.out.println("현재 대기열: " + waitingQueue);
    }
}