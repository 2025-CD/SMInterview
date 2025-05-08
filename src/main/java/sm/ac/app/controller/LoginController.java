package sm.ac.app.controller;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.SessionAttributes;
import sm.ac.app.service.KakaoService;

@Controller
@SessionAttributes("user")
@Slf4j
@RequiredArgsConstructor
public class LoginController {

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

}
