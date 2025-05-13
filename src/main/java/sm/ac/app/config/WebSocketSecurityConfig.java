//package sm.ac.app.config;
//
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.security.config.annotation.web.builders.HttpSecurity;
//import org.springframework.security.web.SecurityFilterChain;
//
//@Configuration
//public class WebSocketSecurityConfig {
//
//    @Bean
//    public SecurityFilterChain webSocketFilterChain(HttpSecurity http) throws Exception {
//        http
//                .securityMatcher("/signal/**") // /signal/** 패턴의 요청에만 이 필터 체인 적용
//                .csrf((csrf) -> csrf.disable()) // WebSocket 사용 시 CSRF 처리에 대한 고려 필요
//                .authorizeHttpRequests((authz) -> authz
//                        .requestMatchers("/signal/**").authenticated() // 인증된 사용자만 /signal/** 접근 허용 (예시)
//                        .anyRequest().denyAll() // 나머지 요청은 거부 (선택 사항)
//                );
//        return http.build();
//    }
////}