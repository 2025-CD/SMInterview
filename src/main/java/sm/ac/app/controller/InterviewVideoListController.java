package sm.ac.app.controller;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import sm.ac.app.dto.UsersDto;
import sm.ac.service.S3UploadService;

import java.util.Map;

@Controller
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/video")

public class InterviewVideoListController {

    private final S3UploadService s3UploadService;

    @GetMapping("/list")
    public String showInterviewVideos(Model model, HttpSession session) {
        UsersDto user = (UsersDto) session.getAttribute("user");
        if (user == null) {
            return "redirect:/login";
        }

        Map<String, String> fileMap = s3UploadService.listInterviewVideosWithDisplayNames(user.getId());
        model.addAttribute("fileMap", fileMap);
        return "interviewVideoList"; // JSP 파일명: interviewVideoList.jsp
    }

    @GetMapping("/view")
    public ResponseEntity<byte[]> viewS3File(@RequestParam("key") String key) {
        byte[] videoData = s3UploadService.getFileBytes(key);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.valueOf("video/webm"));
        return new ResponseEntity<>(videoData, headers, HttpStatus.OK);
    }

    @GetMapping("/watch")
    public String watchVideo(@RequestParam("key") String key, Model model) {
        model.addAttribute("videoKey", key);
        return "interviewVideoPlayer"; // JSP 파일 이름
    }


}
