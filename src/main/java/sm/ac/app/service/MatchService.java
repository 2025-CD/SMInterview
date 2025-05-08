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

    public String findMatch(String userId, String sessionId) {
        if (waitingQueue.size() >= 2) {
            List<String> queueList = new ArrayList<>(waitingQueue);
            for (String otherUserId : queueList) {
                if (!otherUserId.equals(userId)) {
                    waitingQueue.remove(userId); // 현재 사용자 제거
                    waitingQueue.remove(otherUserId); // 매칭된 다른 사용자 제거
                    System.out.println("매칭 성공: " + userId + " vs " + otherUserId);
                    return otherUserId;
                }
            }
            // 매칭 가능한 상대가 없으면 현재 사용자를 다시 큐에 추가 (다음 매칭 기회를 위해)
            if (!waitingQueue.contains(userId)) {
                waitingQueue.offer(userId);
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