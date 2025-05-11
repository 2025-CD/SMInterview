package sm.ac.controller;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import sm.ac.service.ResumeService;
import sm.ac.service.S3UploadService;

import java.util.Map;

@Controller
@RequiredArgsConstructor
public class ResumeController {

    private final ResumeService resumeService;
    private final S3UploadService s3UploadService;

    @PostMapping("/resume/result")
    public String showResult(@RequestParam String resumeText,
                             @RequestParam String targetJob,
                             Model model,
                             HttpSession session) {

        Map<String, Map<String, String>> analysisResult = resumeService.analyze(resumeText, targetJob);
        model.addAttribute("analysisResult", analysisResult);
        session.setAttribute("analysisResult", analysisResult);

        return "resume/result";
    }

    @PostMapping("/resume/saveToCloud")
    public String saveToCloud(HttpSession session, RedirectAttributes redirectAttributes) {
        Map<String, Map<String, String>> analysisResult =
                (Map<String, Map<String, String>>) session.getAttribute("analysisResult");

        if (analysisResult != null) {
            s3UploadService.uploadAnalysisResult(analysisResult);
            redirectAttributes.addFlashAttribute("message", "클라우드 저장 완료!");
        } else {
            redirectAttributes.addFlashAttribute("error", "분석 결과가 없어 저장할 수 없습니다.");
        }

        return "redirect:/resume/result";
    }
}
