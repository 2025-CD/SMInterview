package sm.ac.service;

import jakarta.servlet.http.HttpSession; // HttpSession import 추가
import lombok.RequiredArgsConstructor; // RequiredArgsConstructor import 추가
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired; // Autowired import 추가
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor // 생성자 자동 생성 어노테이션 추가
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final HttpSession httpSession; // HttpSession 주입

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);
        log.info("OAuth2 로그인 성공: {}", oAuth2User.getAttributes());

        // 세션에 사용자 정보 저장
        httpSession.setAttribute("user", oAuth2User.getName()); // 예시: 사용자 이름 저장
        // 세션에 사용자 ID 저장
        httpSession.setAttribute("user", oAuth2User.getAttributes().get("id"));

        return oAuth2User;
    }
}