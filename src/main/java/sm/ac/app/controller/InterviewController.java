package sm.ac.app.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
@Slf4j
public class InterviewController {

    @GetMapping("/interview")
    public String loginPage() {
        log.info("화상통화 페이지 요청.");
        return "interview"; // interview.jsp 반환
    }
}
