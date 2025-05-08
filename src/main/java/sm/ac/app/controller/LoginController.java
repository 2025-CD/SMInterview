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

    @GetMapping("/login")
    public String loginPage() {
        log.info("로그인 페이지 요청");
        return "login"; // login.jsp 반환
    }

    @PostMapping("/loginimpl")
    public String loginimpl(Model model,
                            @RequestParam("id") String id, // JSP의 name 속성에 맞춰 변경
                            @RequestParam("password") String password,
                            HttpSession session) throws Exception {

        log.info("ID:" + id);
        log.info("password:" + password);

        UsersDto usersDto = usersService.get(id);

        if (usersDto != null) {
            // 비밀번호 비교 (주의: 실제 서비스에서는 암호화된 비밀번호 비교를 해야 합니다.)
            if (usersDto.getPassword().equals(password)) {
                session.setAttribute("loginid", usersDto);
                return "index"; // 로그인 성공 시 이동할 페이지
            } else {
                model.addAttribute("loginError", "비밀번호가 일치하지 않습니다.");
                return "login"; // 로그인 실패 시 로그인 페이지로 다시 이동
            }
        } else {
            model.addAttribute("loginError", "존재하지 않는 아이디입니다.");
            return "login"; // 로그인 실패 시 로그인 페이지로 다시 이동
        }
    }
}
