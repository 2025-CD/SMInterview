//package sm.ac.app.controller;
//
////import org.springframework.security.core.context.SecurityContextHolder;
////import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import org.springframework.stereotype.Controller;
//import org.springframework.web.bind.annotation.GetMapping;
//
//@Controller
//public class LogoutController {
//
//
//
//    @GetMapping("/logout")
//    public String logout(HttpServletRequest request, HttpServletResponse response) {
//        new SecurityContextLogoutHandler().logout(request, response, SecurityContextHolder.getContext().getAuthentication());
//        return "redirect:/"; // 로그아웃 후 /logout 페이지로 리다이렉트
//    }
//}
