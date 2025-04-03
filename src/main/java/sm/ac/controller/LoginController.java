package sm.ac.controller;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttributes;
import sm.ac.service.KakaoService;

import java.util.Map;
import java.util.Optional;

@Controller
@SessionAttributes("user")
@Slf4j
@RequiredArgsConstructor
public class LoginController {

    private final KakaoService kakaoService; // 수동 로그인와 카카오 로그인을 모두 처리

    // 로그인 페이지 반환
    @GetMapping("/login")
    public String loginPage() {
        log.info("로그인 페이지 요청");
        return "login"; // /views/login.jsp
    }

    // 홈 페이지 반환 (index.jsp)
    @GetMapping("/")
    public String homePage() {
        return "index"; // /views/index.jsp
    }

    // 일반 로그인 (수동 로그인)
    @PostMapping("/login")
    public String login(@RequestParam("username") String username,
                        @RequestParam("password") String password,
                        HttpSession session) {

        log.info("일반 로그인 시도 - username: {}", username);
        if ("admin".equals(username) && "1234".equals(password)) {
            session.setAttribute("user", username);
            log.info("일반 로그인 성공! 세션 저장 완료: {}", session.getAttribute("user"));
            return "redirect:/";
        } else {
            log.warn("일반 로그인 실패: 아이디 또는 비밀번호 오류");
            return "redirect:/login?error=true";
        }
    }

    // 카카오 로그인 처리 (인가 코드로 사용자 정보 가져오기)
    @PostMapping("/kakao/login")
    public String kakaoLogin(@RequestParam("code") String code, Model model, HttpSession session) {
        log.info("카카오 로그인 요청, 인가 코드: {}", code);
        Optional<Map<String, Object>> userInfoOpt = kakaoService.getUserInfo(code);
        if (userInfoOpt.isPresent()) {
            Map<String, Object> userInfo = userInfoOpt.get();
            session.setAttribute("user", userInfo.get("id"));
            session.setAttribute("nickname", userInfo.get("nickname"));
            model.addAttribute("user", userInfo.get("id"));
            log.info("카카오 로그인 성공! 세션 저장 완료, user: {}", session.getAttribute("user"));
        } else {
            log.warn("카카오 로그인 실패: 사용자 정보 없음");
        }
        return "redirect:/";
    }
}
