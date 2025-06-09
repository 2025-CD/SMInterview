package sm.ac.app.controller;
import org.springframework.http.ResponseEntity;

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
    @ResponseBody
    public ResponseEntity<?> saveInterviewRecording(@RequestParam("file") MultipartFile file,
                                                    HttpSession session) {
        UsersDto user = (UsersDto) session.getAttribute("user");
        if (user == null) {
            return ResponseEntity.status(401).body("로그인이 필요합니다.");
        }

        try {
            s3UploadService.uploadInterviewVideo(file, user.getId());
            return ResponseEntity.ok("녹화 영상이 S3에 저장되었습니다.");
        } catch (Exception e) {
            log.error("❌ S3 업로드 실패", e);
            return ResponseEntity.status(500).body("업로드 실패: " + e.getMessage());
        }
    }

}
