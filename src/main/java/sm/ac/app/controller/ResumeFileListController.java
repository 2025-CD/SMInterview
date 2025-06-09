package sm.ac.app.controller;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import sm.ac.app.dto.UsersDto;
import sm.ac.service.S3UploadService;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;
@Controller
@RequiredArgsConstructor
public class ResumeFileListController {

    private final S3UploadService s3UploadService;

    @GetMapping("/files")
    public String showUserResumeFiles(HttpSession session, Model model) {
        UsersDto loginUser = (UsersDto) session.getAttribute("user");

        if (loginUser == null) {
            model.addAttribute("errorMessage", "로그인이 필요합니다.");
            return "login";  // 또는 에러 페이지로 이동
        }

        String userId = loginUser.getId();
        Map<String, String> fileMap = s3UploadService.listResumeFilesWithDisplayNames(userId);
        model.addAttribute("fileMap", fileMap);
        return "resumeFileList";
    }

    // ✅ S3 JSON 파일 내용을 출력하는 핸들러
    @GetMapping("/files/view")
    @ResponseBody
    public String viewS3JsonFile(@RequestParam("key") String key) {
        return s3UploadService.getJsonFileContent(key);
    }
    @GetMapping("/resume/files/view")
    public String viewResumeFile(@RequestParam("key") String key, Model model) {
        String content = s3UploadService.getJsonFileContent(key); // S3에서 JSON 내용 읽기
        model.addAttribute("jsonContent", content);
        return "resumeJsonViewer"; // 보여줄 JSP 이름
    }

    @GetMapping("/resume/result/view")
    public String showResumeResult(@RequestParam("key") String key, Model model) throws IOException {
        // 1. S3에서 JSON 문자열 불러오기
        String content = s3UploadService.getJsonFileContent(key);

        // 2. 문자열을 Map으로 파싱
        ObjectMapper objectMapper = new ObjectMapper();
        Map<String, Map<String, String>> analysisResult = objectMapper.readValue(content, Map.class);

        // 3. JSP에 넘기기
        model.addAttribute("analysisResult", analysisResult);
        return "resumeJsonViewer"; // JSP 파일명
    }



}
