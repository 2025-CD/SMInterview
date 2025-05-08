package sm.ac.app.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class ResumeAnalyzeRequest {
    private MultipartFile resumeFile;
    private String resumeText;
}