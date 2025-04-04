package sm.ac.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.servlet.util.matcher.MvcRequestMatcher;
import org.springframework.web.servlet.handler.HandlerMappingIntrospector;
import org.springframework.security.oauth2.client.OAuth2AuthorizationRequest;
import java.util.function.Consumer;
import org.springframework.security.config.Customizer;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http, HandlerMappingIntrospector introspector) throws Exception {
        http
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers("/", "/home", "/main", "/static/**", "/login").permitAll()
                        .anyRequest().authenticated()
                )
                .formLogin(login -> login
                        .loginPage("/login")
                        .defaultSuccessUrl("/user")
                )
                .oauth2Login(oauth2 -> oauth2
                        .authorizationEndpoint(authorization -> authorization
                                .customizers(Customizer.withDefaults())
                        )
                        .defaultSuccessUrl("/user")
                )
                .logout(logout -> logout
                        .logoutSuccessUrl("/logout")
                );
        return http.build();
    }

    @Bean
    public Consumer<OAuth2AuthorizationRequest> kakaoAuthorizationRequestCustomizer(HandlerMappingIntrospector introspector) {
        return request -> {
            MvcRequestMatcher requestMatcher = new MvcRequestMatcher(introspector, "/oauth2/authorization/kakao");
            if (requestMatcher.matches(request.getAttribute(MvcRequestMatcher.class.getName()))) {
                request.attributes(attributes -> attributes.put("registrationId", "kakao"));
            }
        };
    }
}