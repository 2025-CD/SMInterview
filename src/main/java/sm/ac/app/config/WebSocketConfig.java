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

//    @Override
//    public void registerStompEndpoints(StompEndpointRegistry registry) {
//        // 클라이언트가 WebSocket 연결을 생성할 때 사용할 엔드포인트 설정
//        // "/signal" 엔드포인트로 SockJS를 fallback 옵션으로 활성화 (브라우저 호환성)
//        registry.addEndpoint("/signal").withSockJS();
//    }
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/signaling")// webSokcet 접속시 endpoint 설정
                .setAllowedOriginPatterns("*") // cors 에 따른 설정 ( * 는 모두 허용 )
                .withSockJS(); // 브라우저에서 WebSocket 을 지원하지 않는 경우에 대안으로 어플리케이션의 코드를 변경할 필요 없이 런타임에 필요할 때 대체하기 위해 설정
    }

}
