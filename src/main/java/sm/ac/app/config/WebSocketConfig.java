package sm.ac.app.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker // STOMP 기반의 WebSocket 메시지 처리 활성화
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // 클라이언트에게 메시지를 브로드캐스팅하기 위한 prefix 설정 (/topic으로 시작하는 주소)
        config.enableSimpleBroker("/topic");
        // 클라이언트에서 서버로 메시지를 보낼 때 붙는 prefix 설정 (@MessageMapping 메서드 호출)
        config.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // 클라이언트가 WebSocket 연결을 생성할 때 사용할 엔드포인트 설정
        // "/signal" 엔드포인트로 SockJS를 fallback 옵션으로 활성화 (브라우저 호환성)
        registry.addEndpoint("/signal").withSockJS();
    }
}