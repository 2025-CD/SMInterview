package sm.ac.app.controller;

import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import sm.ac.service.S3UploadService;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class ResumeFileListController {

    private final S3UploadService s3UploadService;

    @GetMapping("/files")
    public String showAllResumeFiles(Model model) {
        Map<String, String> fileMap = s3UploadService.listResumeFilesWithDisplayNames();
        model.addAttribute("fileMap", fileMap);
        return "resumeFileList";
    }

    // ✅ S3 JSON 파일 내용을 출력하는 핸들러
    @GetMapping("/files/view")
    @ResponseBody
    public String viewS3JsonFile(@RequestParam("key") String key) {
        return s3UploadService.getJsonFileContent(key);
    }
}
