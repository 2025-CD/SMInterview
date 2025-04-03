package sm.ac.controller;


import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Map;

@Controller
@Slf4j
public class MainController {
    @RequestMapping("/")
    public String main(Model model) {
        log.info("Start Main ,,,,,,");
        // Database 데이터를 가지고 온다.
        model.addAttribute("data", "Hello World");
        model.addAttribute("num", 10000);
        return "index";
    }




    // 회원가입 페이지
    @GetMapping("/register")
    public String register() {
        log.info("Navigating to Sign Up Page...");
        return "register"; //

    }

    @GetMapping("/user-info")
    public String userInfo(@AuthenticationPrincipal OAuth2User principal) {
        if (principal != null) {
            // 카카오 사용자 정보 출력
            Map<String, Object> attributes = principal.getAttributes();
            String email = (String) attributes.get("email");
            System.out.println("User email: " + email);
        }
        return "home"; // 홈 페이지로 이동
    }




}