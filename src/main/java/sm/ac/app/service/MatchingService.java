package sm.ac.app.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Queue;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.function.BiConsumer;

@Slf4j
@Service
public class MatchingService {

    // 매칭 대기 중인 사용자들의 세션 ID 큐
    private final Queue<String> waitingQueue = new ConcurrentLinkedQueue<>();
    // 현재 매칭된 사용자 쌍 (key: 사용자 세션 ID, value: 상대방 세션 ID)
    private final Map<String, String> activeMatches = new ConcurrentHashMap<>();
    // 콜백 저장을 위한 임시 맵 (실제로는 더 좋은 방법 고려)
    private final Map<String, BiConsumer<String, String>> matchCallbacks = new ConcurrentHashMap<>();


    /**
     * 사용자를 매칭 대기열에 추가하고, 매칭 시도
     * @param sessionId 사용자 세션 ID
     * @param onMatchFound 매칭 성공 시 호출될 콜백 (user1, user2 전달)
     */
    public synchronized void addWaitingUser(String sessionId, BiConsumer<String, String> onMatchFound) {
        if (activeMatches.containsKey(sessionId) || waitingQueue.contains(sessionId)) {
            log.warn("User {} is already in queue or matched.", sessionId);
            return;
        }

        log.info("Adding user {} to waiting queue.", sessionId);
        waitingQueue.offer(sessionId);
        matchCallbacks.put(sessionId, onMatchFound); // 콜백 저장

        tryMatch();
    }

    /**
     * 매칭 시도 (대기열에 2명 이상일 경우)
     */
    private synchronized void tryMatch() {
        if (waitingQueue.size() >= 2) {
            String user1 = waitingQueue.poll();
            String user2 = waitingQueue.poll();

            if (user1 != null && user2 != null) {
                log.info("Match found: {} and {}", user1, user2);
                activeMatches.put(user1, user2);
                activeMatches.put(user2, user1);

                // 저장된 콜백 함수 호출
                BiConsumer<String, String> callback1 = matchCallbacks.remove(user1);
                BiConsumer<String, String> callback2 = matchCallbacks.remove(user2);

                if (callback1 != null) {
                    callback1.accept(user1, user2); // user1에게 매칭 결과 알림
                }
                if (callback2 != null) {
                    callback2.accept(user2, user1); // user2에게 매칭 결과 알림
                }

            } else {
                // 혹시 poll 결과가 null이면 다시 큐에 넣기 (동시성 문제 방지 차원)
                if(user1 != null) waitingQueue.offer(user1);
                if(user2 != null) waitingQueue.offer(user2);
            }
        } else {
            log.info("Not enough users to match. Waiting queue size: {}", waitingQueue.size());
        }
    }

    /**
     * 사용자의 매칭된 상대방 세션 ID 반환
     * @param sessionId 사용자 세션 ID
     * @return 상대방 세션 ID (없으면 null)
     */
    public String getMatchedPartner(String sessionId) {
        return activeMatches.get(sessionId);
    }

    /**
     * 사용자 제거 (연결 종료 또는 매칭 취소 시)
     * @param sessionId 사용자 세션 ID
     */
    public synchronized void removeUser(String sessionId) {
        log.info("Removing user: {}", sessionId);
        waitingQueue.remove(sessionId); // 대기열에서 제거
        matchCallbacks.remove(sessionId); // 콜백 제거

        String partnerId = activeMatches.remove(sessionId); // 현재 매칭 정보 제거
        if (partnerId != null) {
            activeMatches.remove(partnerId); // 상대방의 매칭 정보도 제거
            log.info("Removed match between {} and {}", sessionId, partnerId);
        }
    }
}