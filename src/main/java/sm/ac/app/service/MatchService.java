//package sm.ac.app.service;
//
//import org.springframework.stereotype.Service;
//
//import java.util.Queue;
//import java.util.Map;
//import java.util.concurrent.ConcurrentHashMap;
//import java.util.concurrent.ConcurrentLinkedQueue;
//
//@Service
//public class MatchService {
//
//    private final Queue<String> waitingQueue = new ConcurrentLinkedQueue<>();
//    private final Map<String, String> userSessionId = new ConcurrentHashMap<>();
//
//    public void addToQueue(String userId, String sessionId) {
//        waitingQueue.offer(userId);
//        userSessionId.put(userId, sessionId);
//        System.out.println("매칭 대기열 추가: " + userId + ", sessionId: " + sessionId); // 수정
//        System.out.println("현재 대기열: " + waitingQueue);
//        System.out.println("현재 세션 정보: " + userSessionId); // 추가
//    }
//
//    public String findMatch(String userId) {
//        System.out.println("매칭 시도 - userId: " + userId + ", 대기열: " + waitingQueue); // 추가
//        for (String otherUserId : waitingQueue) {
//            if (!otherUserId.equals(userId)) {
//                waitingQueue.remove(otherUserId);
//                System.out.println("매칭 성공 후보 - " + userId + " vs " + otherUserId + ", 남은 대기열: " + waitingQueue); // 수정
//                return otherUserId;
//            }
//        }
//        System.out.println("매칭 실패 - 찾을 수 없음"); // 추가
//        return null;
//    }
//
//    public void clearUserFromQueue(String userId) {
//        waitingQueue.removeIf(user -> user.equals(userId));
//        userSessionId.remove(userId);
//        System.out.println("매칭 대기열 제거: " + userId + ", 현재 대기열: " + waitingQueue); // 수정
//        System.out.println("현재 세션 정보: " + userSessionId); // 추가
//    }
//}