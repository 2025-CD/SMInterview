//package sm.ac.app.service;
//
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.stereotype.Service;
//
//import java.util.Queue;
//import java.util.concurrent.ConcurrentHashMap;
//import java.util.concurrent.ConcurrentLinkedQueue;
//import java.util.function.BiConsumer;
//import java.util.Map;
//
//@Service
//@Slf4j
//public class MatchingService {
//
//    // 사용자 ID(String)를 저장하는 대기열
//    private final Queue<String> waitingQueue = new ConcurrentLinkedQueue<>();
//    // 매칭된 사용자 쌍 (사용자 ID -> 상대방 사용자 ID)
//    private final Map<String, String> activeMatches = new ConcurrentHashMap<>();
//    // 매칭 결과를 알릴 콜백 함수 저장 (사용자 ID -> 콜백 함수)
//    private final Map<String, BiConsumer<String, String>> matchCallbacks = new ConcurrentHashMap<>();
//
//    // 매칭 대기열에 사용자 추가
//    // user ID와 매칭 완료 시 호출될 콜백 함수를 받음
//    public void addWaitingUser(String userId, BiConsumer<String, String> matchCallback) {
//        log.info("Adding user {} to waiting queue.", userId);
//
//        // 이미 대기 중이거나 매칭된 사용자는 추가하지 않음 (방어 코드)
//        if (waitingQueue.contains(userId) || activeMatches.containsKey(userId)) {
//            log.warn("User {} is already in queue or matched. Skipping.", userId);
//            // 이미 매칭된 경우, 콜백을 다시 호출하거나 상태를 알릴 필요가 있을 수 있으나,
//            // 여기서는 단순화하여 중복 추가를 막습니다.
//            // 이미 대기 중인 경우 콜백만 업데이트 할 수 있습니다.
//            matchCallbacks.put(userId, matchCallback); // 콜백은 최신으로 업데이트
//            log.info("User {} already in queue, updating callback.", userId);
//            return;
//        }
//
//        waitingQueue.offer(userId); // 대기열에 추가
//        matchCallbacks.put(userId, matchCallback); // 콜백 저장
//        log.info("User {} added to waiting queue. Current queue size: {}", userId, waitingQueue.size());
//
//        tryMatch(); // 매칭 시도
//    }
//
//    // 대기열에서 매칭 가능한 사용자 쌍 찾기
//    // private synchronized void tryMatch() { // Concurrent 컬렉션 사용 시 synchronized는 필수 아닐 수 있으나, 안전을 위해 유지하거나 다른 락 메커니즘 고려 가능
//    // ConcurrentLinkedQueue는 offer/poll이 스레드 안전하지만, size 체크 후 poll하는 과정에서
//    // 다른 스레드가 poll하여 size가 변할 수 있으므로, tryMatch 전체에 synchronized를 적용하는 것이 안전
//    private synchronized void tryMatch() {
//        // 대기열에 2명 이상 있을 때만 매칭 시도
//        if (waitingQueue.size() >= 2) {
//            String user1Id = waitingQueue.poll();
//            String user2Id = waitingQueue.poll();
//
//            // poll 결과가 null이 아니고, 두 사용자가 모두 대기 중 상태일 경우 (방어 코드)
//            // user1Id 또는 user2Id가 null이 되는 경우는 거의 없겠지만, poll의 특성 상 체크.
//            // activeMatches.containsKey(user1Id) 체크는 addWaitingUser에서 했으므로 여기서는 굳이 필요 없을 수 있으나,
//            // 복잡한 시나리오에서는 필요할 수도 있습니다. 여기서는 단순화하여 null 체크만.
//            if (user1Id != null && user2Id != null) {
//                // 혹시 자기 자신과 매칭되는 경우 (발생해서는 안 되지만 방어 코드)
//                if (user1Id.equals(user2Id)) {
//                    log.warn("Attempted to match user {} with themselves. Re-queueing.", user1Id);
//                    waitingQueue.offer(user1Id);
//                    // 콜백은 그대로 유지
//                    return; // 다시 시도
//                }
//
//                log.info("Match found: {} and {}", user1Id, user2Id);
//
//                // 매칭 정보 저장
//                activeMatches.put(user1Id, user2Id);
//                activeMatches.put(user2Id, user1Id);
//
//                // 저장된 콜백 함수 호출 및 제거
//                BiConsumer<String, String> callback1 = matchCallbacks.remove(user1Id);
//                BiConsumer<String, String> callback2 = matchCallbacks.remove(user2Id);
//
//                // 콜백 함수가 존재하면 호출하여 클라이언트에게 매칭 결과 알림
//                if (callback1 != null) {
//                    try {
//                        callback1.accept(user1Id, user2Id);
//                    } catch (Exception e) {
//                        log.error("Error executing match callback for user {}: {}", user1Id, e.getMessage());
//                        // 콜백 실패 시 해당 사용자 연결 종료 등의 예외 처리 필요
//                        // 여기서는 간단히 로그만 남김
//                    }
//                } else {
//                    log.warn("Match callback not found for user {}. Cannot notify.", user1Id);
//                    // 콜백이 없으면 해당 사용자에게 매칭 결과를 알릴 수 없음. 연결 끊기 등 처리 필요.
//                    // 여기서는 일단 상대방에게는 알림.
//                }
//
//                if (callback2 != null) {
//                    try {
//                        callback2.accept(user2Id, user1Id);
//                    } catch (Exception e) {
//                        log.error("Error executing match callback for user {}: {}", user2Id, e.getMessage());
//                        // 콜백 실패 시 해당 사용자 연결 종료 등의 예외 처리 필요
//                        // 여기서는 간단히 로그만 남김
//                    }
//                } else {
//                    log.warn("Match callback not found for user {}. Cannot notify.", user2Id);
//                    // 콜백이 없으면 해당 사용자에게 매칭 결과를 알릴 수 없음.
//                }
//
//
//            } else {
//                // 혹시 poll 결과가 null이면 (발생해서는 안 됨)
//                log.error("tryMatch: Polled null user(s). user1Id: {}, user2Id: {}", user1Id, user2Id);
//                // 복구 로직: null이 아닌 사용자만 다시 큐에 넣기
//                if(user1Id != null) waitingQueue.offer(user1Id);
//                if(user2Id != null) waitingQueue.offer(user2Id);
//                // 콜백은 그대로 맵에 남아있음
//            }
//        } else {
//            log.info("Not enough users to match. Waiting queue size: {}", waitingQueue.size());
//        }
//    }
//
//    // 매칭된 상대방의 사용자 ID 가져오기
//    public String getMatchedPartner(String userId) {
//        return activeMatches.get(userId);
//    }
//
//    // 매칭 또는 대기 상태에서 사용자 제거
//    // WebSocket 연결 해제, 명시적 종료 시 호출됨
//    public void removeUser(String userId) {
//        log.info("Attempting to remove user {} from matching service.", userId);
//
//        // 대기열에서 제거 시도
//        boolean removedFromQueue = waitingQueue.remove(userId);
//        if (removedFromQueue) {
//            log.info("User {} removed from waiting queue.", userId);
//            matchCallbacks.remove(userId); // 콜백도 제거
//        }
//
//        // 매칭된 상태에서 제거 시도
//        String partnerId = activeMatches.remove(userId);
//        if (partnerId != null) {
//            log.info("User {} removed from active match with partner {}.", userId, partnerId);
//            activeMatches.remove(partnerId); // 상대방 쪽에서도 제거
//
//            // 상대방에게 연결 종료 알림 (SignalController에서 처리할 수도 있으나, 서비스에서 알릴 수도 있음)
//            // 여기서는 SignalController에서 처리하는 것으로 가정하고 서비스에서는 매칭 정보만 정리
//            // 필요한 경우 여기서 상대방에게 끊어졌음을 알리는 로직 추가 가능
//            // BiConsumer<String, String> partnerCallback = matchCallbacks.remove(partnerId); // 상대방 콜백은 보통 매칭 시 제거됨
//        } else if (!removedFromQueue) {
//            // 대기열에도 없었고, 매칭된 상태도 아니었다면 이미 제거되었거나 잘못된 userId
//            log.warn("User {} was not found in queue or active matches.", userId);
//        }
//
//        // 제거 후 다시 매칭 시도 (대기열에 2명 이상 남을 수도 있으므로)
//        if (!waitingQueue.isEmpty()) {
//            tryMatch();
//        }
//    }
//
//    // 현재 대기열 상태 확인 (디버깅용)
//    public int getWaitingQueueSize() {
//        return waitingQueue.size();
//    }
//
//    // 현재 매칭된 쌍 확인 (디버깅용)
//    public int getActiveMatchCount() {
//        return activeMatches.size() / 2; // 쌍의 개수
//    }
//}