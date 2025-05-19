package sm.ac.app.controller;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MypageController {

    @GetMapping("/mypage")
    public String showMypage() {
        // /WEB-INF/views/mypage.jsp 로 포워딩
        return "mypage";
    }
}