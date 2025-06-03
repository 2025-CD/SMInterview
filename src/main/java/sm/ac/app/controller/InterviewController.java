package sm.ac.app.controller;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import sm.ac.app.dto.UsersDto;
import sm.ac.service.S3UploadService;

@Controller
@Slf4j
@RequiredArgsConstructor
public class InterviewController {

    private final S3UploadService s3UploadService;

    @GetMapping("/interview")
    public String interviewPage() {
        log.info("화상통화 페이지 요청.");
        return "interview"; // interview.jsp 반환
    }

    // ✅ 영상 파일 업로드용 POST 매핑
    @PostMapping("/interview/save")
    public String saveInterviewRecording(@RequestParam("file") MultipartFile file,
                                         HttpSession session,
                                         RedirectAttributes redirectAttributes) {
        UsersDto user = (UsersDto) session.getAttribute("user");
        if (user == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요합니다.");
            return "redirect:/login";
        }

        try {
            s3UploadService.uploadInterviewVideo(file, user.getId());
            redirectAttributes.addFlashAttribute("message", "녹화 영상이 S3에 저장되었습니다.");
        } catch (Exception e) {
            log.error("❌ S3 업로드 실패", e);
            redirectAttributes.addFlashAttribute("error", "저장 중 오류 발생: " + e.getMessage());
        }

        return "redirect:/interview/ai"; // 저장 후 이동할 페이지
    }
}
