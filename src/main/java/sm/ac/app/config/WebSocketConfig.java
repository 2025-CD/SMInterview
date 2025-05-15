package sm.ac.app.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/signal").withSockJS(); // 클라이언트가 연결할 엔드포인트
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        registry.enableSimpleBroker("/user", "/queue"); // /user, /queue 토픽 사용
//        registry.setApplicationDestinationPrefixes("/app"); // /app으로 시작하는 메시지는 @MessageMapping 메서드로 라우팅
        //app/match로 서버에 전송하고 있지만  match로 받는 Controller를 찾고있었음...
    }
}