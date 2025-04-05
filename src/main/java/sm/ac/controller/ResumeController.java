package sm.ac.controller;

import sm.ac.dto.ResumeAnalyzeRequest;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.poi.xwpf.extractor.XWPFWordExtractor;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

@Controller
@RequestMapping("/resume")
public class ResumeController {

    @GetMapping("/input")
    public String showResumeInputForm() {
        return "resumeInput";
    }

    @PostMapping("/api/analyze")
    public ResponseEntity<String> analyzeResume(ResumeAnalyzeRequest request) {
        if (request.getResumeFile() != null && !request.getResumeFile().isEmpty()) {
            MultipartFile resumeFile = request.getResumeFile();
            try {
                String fileContentType = resumeFile.getContentType();
                String resumeContent = "";
                InputStream inputStream = resumeFile.getInputStream();

                if (fileContentType != null) {
                    if (fileContentType.startsWith("text/plain")) {
                        resumeContent = new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
                    } else if (fileContentType.equals("application/pdf")) {
                        byte[] bytes = inputStream.readAllBytes();
                        PDDocument document = PDDocument.load(bytes);
                        PDFTextStripper stripper = new PDFTextStripper();
                        resumeContent = stripper.getText(document);
                        document.close();
                        // PDF 처리 응답 수정 확인
                        String analysisResult = "PDF 파일 분석 결과 (구현 예정):\n" + resumeContent;
                        return ResponseEntity.ok(analysisResult);
                    } else if (fileContentType.equals("application/vnd.openxmlformats-officedocument.wordprocessingml.document")) {
                        // DOCX 파일 처리 (텍스트 추출)
                        XWPFDocument document = new XWPFDocument(inputStream);
                        XWPFWordExtractor extractor = new XWPFWordExtractor(document);
                        resumeContent = extractor.getText();
                        extractor.close();
                        document.close();
                        // 수정된 응답 부분
                        String analysisResult = "DOCX 파일 분석 결과 (구현 예정):\n" + resumeContent;
                        return ResponseEntity.ok(analysisResult);
                    }

                    // TODO: OpenAI API 호출 및 분석 로직 추가 (다음 단계)
                    String analysisResult = "파일 분석 결과 (구현 예정) - 형식: " + fileContentType + "\n" + resumeContent;
                    return ResponseEntity.ok(analysisResult);

                } else {
                    return ResponseEntity.badRequest().body("파일 형식을 확인할 수 없습니다.");
                }

            } catch (IOException e) {
                e.printStackTrace();
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("파일을 읽는 동안 오류가 발생했습니다.");
            }
        } else if (request.getResumeText() != null && !request.getResumeText().isEmpty()) {
            String resumeText = request.getResumeText();
            String analysisResult = "텍스트 입력 분석 결과 (구현 예정):\n" + resumeText;
            return ResponseEntity.ok(analysisResult);
        } else {
            return ResponseEntity.badRequest().body("이력서 파일을 업로드하거나 텍스트를 입력해주세요.");
        }
    }
}