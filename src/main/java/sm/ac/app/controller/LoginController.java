package sm.ac.app.controller;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import sm.ac.app.dto.UsersDto;
import sm.ac.app.service.UsersService;

@Controller
@Slf4j
@RequiredArgsConstructor
public class LoginController {

    final UsersService usersService;

    // 로그인 페이지 반환
    @GetMapping("/login")
    public String loginPage() {
        log.info("로그인 페이지 요청");
        return "login"; // login.jsp 반환
    }

    @PostMapping("/loginimpl")
    public String loginimpl(Model model,
                            @RequestParam("id") String id,
                            @RequestParam("password") String password,
                            HttpSession session) throws Exception {

        log.info("ID: {}", id);
        log.info("password: {}", password);

        UsersDto usersDto = usersService.get(id);

        if (usersDto != null) {
            // 로그인 성공 조건
            if (usersDto.getPassword().equals(password)) {
                session.setAttribute("loginid", usersDto); // ✅ 로그인 성공한 경우에만 저장
                return "redirect:/"; // ✅ 반드시 redirect!
            } else {
                model.addAttribute("loginError", "비밀번호가 일치하지 않습니다.");
            }
        } else {
            model.addAttribute("loginError", "존재하지 않는 아이디입니다.");
        }

        return "login"; // 실패 시 다시 로그인 페이지로
    }

}
