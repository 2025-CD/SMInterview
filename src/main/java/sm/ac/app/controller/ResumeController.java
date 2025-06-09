package sm.ac.app.controller;

import sm.ac.app.dto.UsersDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.poi.xwpf.extractor.XWPFWordExtractor;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import sm.ac.service.S3UploadService;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/resume")
public class ResumeController {

    private final RestTemplate openaiRestTemplate;
    private final ObjectMapper objectMapper;
    private final S3UploadService s3UploadService;

    @Value("${openai.api-key}")
    private String openaiApiKey;

    @Autowired
    public ResumeController(RestTemplate openaiRestTemplate,
                            ObjectMapper objectMapper,
                            S3UploadService s3UploadService) {
        this.openaiRestTemplate = openaiRestTemplate;
        this.objectMapper = objectMapper;
        this.s3UploadService = s3UploadService;
    }

    @GetMapping("/input")
    public String showResumeInputForm() {
        return "resumeInput";
    }

    @PostMapping("/result")
    public String analyzeResumeAndShowResult(
            @RequestParam(value = "resumeFile", required = false) MultipartFile resumeFile,
            @RequestParam(value = "resumeText", required = false) String resumeText,
            @RequestParam(value = "targetJob", required = false) String targetJob,
            Model model,
            HttpSession session) {

        String resumeContent = "";

        // 파일 업로드 방식
        if (resumeFile != null && !resumeFile.isEmpty()) {
            String fileContentType = resumeFile.getContentType();
            String originalFileName = resumeFile.getOriginalFilename().toLowerCase();

            try (InputStream inputStream = resumeFile.getInputStream()) {
                if (fileContentType != null && fileContentType.startsWith("text/plain")) {
                    resumeContent = new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
                } else if (fileContentType != null && fileContentType.equals("application/pdf")) {
                    try (PDDocument document = PDDocument.load(inputStream)) {
                        PDFTextStripper stripper = new PDFTextStripper();
                        resumeContent = stripper.getText(document);
                    }
                } else if ((fileContentType != null && fileContentType.contains("word")) || originalFileName.endsWith(".docx")) {
                    try (XWPFDocument document = new XWPFDocument(inputStream);
                         XWPFWordExtractor extractor = new XWPFWordExtractor(document)) {
                        resumeContent = extractor.getText();
                    }
                } else {
                    model.addAttribute("errorMessage", "지원하지 않는 파일 형식입니다 (TXT, PDF, DOCX만 지원).");
                    return "resumeInput";
                }
            } catch (IOException e) {
                model.addAttribute("errorMessage", "파일을 읽는 중 오류가 발생했습니다.");
                return "resumeInput";
            }
        }
        // 텍스트 직접 입력 방식
        else if (resumeText != null && !resumeText.trim().isEmpty()) {
            resumeContent = resumeText.trim();
        }
        // 아무 입력도 없을 때
        else {
            model.addAttribute("errorMessage", "이력서 파일 또는 텍스트를 입력해주세요.");
            return "resumeInput";
        }

        // OpenAI 분석 처리
        try {
            Map<String, Object> analysisResult = callOpenAiApi(resumeContent, targetJob);
            model.addAttribute("analysisResult", analysisResult);
            session.setAttribute("analysisResult", analysisResult);
            return "resumeResult";
        } catch (IOException e) {
            model.addAttribute("errorMessage", "OpenAI API 호출 중 오류 발생: " + e.getMessage());
            return "resumeInput";
        }
    }

    @PostMapping("/saveToCloud")
    public String saveToCloud(HttpSession session, RedirectAttributes redirectAttributes) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Map<String, String>> analysisResult =
                    (Map<String, Map<String, String>>) session.getAttribute("analysisResult");

            // 사용자 정보에서 userId 추출
            UsersDto loginUser = (UsersDto) session.getAttribute("user");
            if (loginUser == null) {
                redirectAttributes.addFlashAttribute("error", "로그인 정보가 없어 저장할 수 없습니다.");
                return "redirect:/resume/result";
            }

            String userId = loginUser.getId();

            if (analysisResult == null) {
                redirectAttributes.addFlashAttribute("error", "분석 결과가 없어 저장할 수 없습니다.");
            } else {
                s3UploadService.uploadAnalysisResult(analysisResult, userId); // userId 버전 사용
                redirectAttributes.addFlashAttribute("message", "클라우드 저장 완료!");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "클라우드 저장 중 오류 발생: " + e.getMessage());
        }
        return "redirect:/resume/result";
    }


    private Map<String, Object> callOpenAiApi(String resumeContent, String targetJob) throws IOException {
        String apiUrl = "https://api.openai.com/v1/chat/completions";
        String model = "gpt-3.5-turbo";

        if (targetJob == null || targetJob.trim().isEmpty()) {
            targetJob = "일반";
        }

        String requiredSkills = "";

        String prompt = String.format(
                "당신은 %s 분야의 채용 전문가입니다. 다음 이력서를 %s 직무에 지원하는 지원자의 관점에서 상세히 분석하고, 채용 담당자의 입장에서 매력적인 이력서가 되기 위한 구체적인 개선 제안을 제공해주세요.\n\n" +
                        "**주요 평가 항목:**\n" +
                        "- **경력 사항:** %s 직무와 관련된 프로젝트 경험 및 성과를 명확하고 구체적인 수치와 함께 제시했는지 평가하고, 성과를 더 효과적으로 어필할 수 있는 방법을 제안해주세요. 특히 %s 기술 스택 사용 경험을 강조해야 합니다.\n" +
                        "- **기술 스택:** 제시된 기술 스택이 %s 직무에서 요구하는 핵심 기술(%s)과 부합하는지 평가하고, 부족하거나 보완해야 할 기술, 추가하면 좋을 기술 등을 제안해주세요.\n" +
                        "- **학력 및 기타:** 학력 사항이 지원 직무와 관련성이 있는지, 기타 활동 (수상 경력, 프로젝트 경험 등)이 강점을 부각하는 데 도움이 되는지 평가하고 개선 방안을 제시해주세요.\n" +
                        "- **문법 및 가독성:** 문법 오류, 오탈자, 비문, 어색하거나 불필요한 표현은 없는지 꼼꼼히 확인하고, 간결하고 명확하며 읽기 쉬운 문장으로 작성되었는지 평가해주세요.\n" +
                        "- **전반적인 경쟁력:** 이 이력서가 %s 직무에 대한 전반적인 경쟁력이 어느 정도인지 평가하고, 서류 통과율을 높이기 위한 가장 중요한 개선 사항들을 3가지 이상 구체적으로 제시해주세요.\n\n" +
                        "**답변 형식:**\n" +
                        "{\n" +
                        "  \"경력 사항\": { \"분석\": \"...\", \"개선 제안\": \"...\" },\n" +
                        "  \"기술 스택\": { \"분석\": \"...\", \"개선 제안\": \"...\" },\n" +
                        "  \"학력 및 기타\": { \"분석\": \"...\", \"개선 제안\": \"...\" },\n" +
                        "  \"문법 및 가독성\": { \"분석\": \"...\", \"개선 제안\": \"...\" },\n" +
                        "  \"전반적인 경쟁력\": { \"분석\": \"...\", \"개선 제안\": \"...\" }\n" +
                        "}",
                targetJob, targetJob, targetJob, requiredSkills, targetJob, requiredSkills, targetJob, resumeContent
        );

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", model);
        requestBody.put("messages", List.of(Map.of("role", "user", "content", prompt)));
        requestBody.put("temperature", 0.7);

        org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
        headers.set("Authorization", "Bearer " + openaiApiKey);
        org.springframework.http.HttpEntity<Map<String, Object>> requestEntity = new org.springframework.http.HttpEntity<>(requestBody, headers);

        ResponseEntity<Map> response = openaiRestTemplate.postForEntity(apiUrl, requestEntity, Map.class);

        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            List<Map<String, Object>> choices = (List<Map<String, Object>>) response.getBody().get("choices");
            if (!choices.isEmpty()) {
                Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
                String content = (String) message.get("content");
                try {
                    return objectMapper.readValue(content, Map.class);
                } catch (com.fasterxml.jackson.core.JsonProcessingException e) {
                    System.err.println("JSON 파싱 오류: " + content);
                    throw new IOException("OpenAI API 응답 JSON 파싱 오류", e);
                }
            }
        } else {
            System.err.println("OpenAI API 호출 실패: " + response.getStatusCode());
            System.err.println("Response body: " + response.getBody());
            throw new IOException("OpenAI API 호출 실패: " + response.getStatusCode());
        }
        return null;
    }


    @GetMapping("/result")
    public String showResumeResult() {
        return "resumeResult";
    }

    @GetMapping("/files")
    public String showAllResumeFiles(Model model) {
        List<String> fileList = s3UploadService.listAllResumeAnalysisFiles();
        model.addAttribute("fileList", fileList);
        return "resumeFileList";  // => JSP 뷰 이름
    }

    @PostMapping("/upload")
    public String handleFileUpload(@RequestParam("file") MultipartFile file) {
        // 파일 처리 로직
        return "uploadResult";
    }
}
