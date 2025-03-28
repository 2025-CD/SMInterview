package sm.ac.controller;


import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

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


//    // ✅ 로그인 페이지 매핑 추가
//    @GetMapping("/login")
//    public String login() {
//        log.info("Navigating to Login Page...");
//        return "login"; // login.jsp 또는 login.html로 이동
//    }

    // 회원가입 페이지
    @GetMapping("/register")
    public String register() {
        log.info("Navigating to Sign Up Page...");
        return "register"; //

    }



}