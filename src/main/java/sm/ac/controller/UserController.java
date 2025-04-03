package sm.ac.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.Map;

@Controller
public class UserController {

    @GetMapping("/user")
    public String getUserInfo(@AuthenticationPrincipal OAuth2User oauth2User, Model model) {
        if (oauth2User != null) {
            Map<String, Object> attributes = oauth2User.getAttributes();
            model.addAttribute("userInfo", attributes);
        }
        return "user"; // user.jsp 페이지로 이동
    }
}