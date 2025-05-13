//package sm.ac.app.config;
//
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.security.config.annotation.web.builders.HttpSecurity;
//import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
//import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
//import org.springframework.security.crypto.password.PasswordEncoder;
//import org.springframework.security.web.SecurityFilterChain;
//
//@Configuration
//@EnableWebSecurity
//public class SecurityConfig {
//
//    @Bean
//    public PasswordEncoder passwordEncoder() {
//        return new BCryptPasswordEncoder();
//    }
//
//    @Bean
//    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
//        http
//                .securityMatcher("/**") // 모든 요청에 대해 이 필터 체인 적용 (우선순위 낮음)
//                .csrf((csrf) -> csrf.disable()) // WebSocket 사용 시 CSRF 처리에 대한 고려 필요 (일단 비활성화)
//                .authorizeHttpRequests((authz) -> authz
//                        .requestMatchers("/", "/login", "/css/**", "/js/**", "/webjars/**").permitAll()
//                        .anyRequest().authenticated()
//                )
//                .formLogin((formLogin) -> formLogin
//                        .loginPage("/login")
//                        .defaultSuccessUrl("/interview")
//                        .permitAll()
//                )
//                .logout((logout) -> logout
//                        .permitAll()
//                        .logoutSuccessUrl("/")
//                );
//        return http.build();
//    }
//}