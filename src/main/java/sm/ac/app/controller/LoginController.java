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

        log.info("✅ 로그인 시도됨!");
        log.info("입력한 ID: {}", id);
        log.info("입력한 Password: {}", password);

        UsersDto usersDto = usersService.get(id);
        log.info("DB에서 조회된 사용자: {}", usersDto);

        if (usersDto != null && usersDto.getPassword().equals(password)) {
            // ✅ 세션에 유저 정보 저장
            session.setAttribute("user", usersDto);              // 전체 사용자 객체
            session.setAttribute("nickname", usersDto.getUsername());  // 별도 닉네임 저장 (JSP에서 사용 편하게)

            log.info("✅ 로그인 성공: {}", usersDto.getUsername());
            return "redirect:/"; // redirect로 이동해야 세션 반영됨
        } else {
            log.warn("❌ 로그인 실패: 아이디 또는 비밀번호 불일치");
            model.addAttribute("loginError", "아이디 또는 비밀번호가 올바르지 않습니다.");
            return "login";
        }
    }

}
