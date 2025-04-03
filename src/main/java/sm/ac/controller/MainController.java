package sm.ac.controller;


import lombok.extern.slf4j.Slf4j;
import org.eclipse.tags.shaded.org.apache.xpath.operations.Mod;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import sm.ac.app.dto.JobCategoryDto;
import sm.ac.app.dto.JobFieldDto;
import sm.ac.app.service.JobCategoryService;
import sm.ac.app.service.JobFieldService;

import java.util.List;

@Controller
@Slf4j
public class MainController {

    private final JobFieldService jobFieldService;


    private final JobCategoryService jobCategoryService;

    @Autowired
    public MainController(JobFieldService jobFieldService, JobCategoryService jobCategoryService) {
        this.jobFieldService = jobFieldService;
        this.jobCategoryService = jobCategoryService;
    }


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



}