package sm.ac.app.controller;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MypageController {

    @GetMapping("/mypage")
    public String mypage(HttpSession session, Model model) {
        // 세션에 저장된 사용자 이름(닉네임) 꺼내기
        String nickname = (String) session.getAttribute("nickname");

        // 마이페이지에 표시할 사용자 정보 전달
        model.addAttribute("nickname", nickname); // JSP에서 ${nickname} 사용 가능
        return "mypage"; // /WEB-INF/views/mypage.jsp 로 이동 (ViewResolver 기준)
    }

}