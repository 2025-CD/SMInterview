//package sm.ac.config;
//
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.http.HttpMethod;
//import org.springframework.security.config.annotation.web.builders.HttpSecurity;
//import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
//import org.springframework.security.web.SecurityFilterChain;
//import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
//
//@Configuration
//@EnableWebSecurity
//public class SecurityConfig {
//
//    @Bean
//    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
//        http
//                .authorizeHttpRequests(authorize -> authorize
//                        .requestMatchers("/").permitAll() // 루트 경로 접근 허용
//                        .requestMatchers("/home", "/main", "/static/**", "/login").permitAll()
//                        .requestMatchers("/oauth2/authorization/**").permitAll()
//                        .anyRequest().permitAll() // 모든 요청 허용으로 변경
//                )
//                .formLogin(login -> login
//                        .loginPage("/login")
//                        .defaultSuccessUrl("/")
//                )
//                .oauth2Login(oauth2 -> oauth2
//                        .loginPage("/login")
//                        .defaultSuccessUrl("/user")
//                        .failureUrl("/login?error")
//                )
//                .logout(logout -> logout
//                        .logoutSuccessUrl("/logout")
//                )
//                .csrf((csrf) -> csrf.csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())); // CSRF 활성화 및 쿠키 저장소 사용 (필요에 따라)
//        return http.build();
//    }

//}