package sm.ac.app.controller;


import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
//import org.springframework.security.core.annotation.AuthenticationPrincipal;
//import org.springframework.security.oauth2.core.user.OAuth2User;
import org.eclipse.tags.shaded.org.apache.xpath.operations.Mod;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import sm.ac.app.dto.JobCategoryDto;
import sm.ac.app.dto.JobFieldDto;
import sm.ac.app.dto.UsersDto;
import sm.ac.app.service.JobCategoryService;
import sm.ac.app.service.JobFieldService;
import sm.ac.app.service.UsersService;

import java.util.List;

import java.util.Map;

@Controller
@Slf4j
@RequiredArgsConstructor
public class MainController {

    private final JobFieldService jobFieldService;


    private final JobCategoryService jobCategoryService;


    final UsersService userService;


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
    public String register(Model model) {

        List<JobFieldDto> jobFields = jobFieldService.getJobFields();
        model.addAttribute("jobFields", jobFields);
        return "register";

    }

    // 🔹 AJAX 요청을 처리하는 API (선택한 직종에 맞는 직군을 가져옴)
    @GetMapping("/getJobCategories")
    @ResponseBody
    public List<JobCategoryDto> getJobCategories(@RequestParam("jobFieldId") int jobFieldId) {
        log.info("Fetching job categories for jobFieldId: " + jobFieldId);
        return jobCategoryService.getJobCategories(jobFieldId);

    }



    // 회원가입 폼 제출 처리 (POST 요청)
    @PostMapping("/process-signup")
    public String processSignUp(@ModelAttribute UsersDto usersDto,
                                RedirectAttributes redirectAttributes,
                                Model model) throws Exception { // Model은 오류 시 현재 페이지 반환용

        log.info("회원가입 시도: {}", usersDto.getId());


        userService.add(usersDto);
        log.info("회원가입 성공: {}", usersDto.getId());

        // 회원가입 성공 시 리다이렉트와 함께 성공 메시지 전달 (선택 사항)
        redirectAttributes.addFlashAttribute("successMessage", "회원가입이 성공적으로 완료되었습니다. 로그인해주세요.");
        return "redirect:/login"; // 로그인 페이지로 리다이렉트


    }


//    @GetMapping("/user-info")
//    public String userInfo(@AuthenticationPrincipal OAuth2User principal) {
//        if (principal != null) {
//            // 카카오 사용자 정보 출력
//            Map<String, Object> attributes = principal.getAttributes();
//            String email = (String) attributes.get("email");
//            System.out.println("User email: " + email);
//        }
//        return "home"; // 홈 페이지로 이동
//    }

}



