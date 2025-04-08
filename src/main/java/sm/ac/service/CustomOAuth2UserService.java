package sm.ac.service;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final HttpSession httpSession;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);
        log.info("OAuth2 로그인 성공: {}", oAuth2User.getAttributes());

        // 세션에 사용자 ID 저장
        httpSession.setAttribute("user", oAuth2User.getAttributes().get("id"));

        // 세션에 닉네임 저장
        Map<String, Object> properties = (Map<String, Object>) oAuth2User.getAttributes().get("properties");
        if (properties != null && properties.containsKey("nickname")) {
            httpSession.setAttribute("nickname", properties.get("nickname"));
            log.info("세션에 닉네임 저장: {}", properties.get("nickname"));
        }

        return oAuth2User;
    }
}