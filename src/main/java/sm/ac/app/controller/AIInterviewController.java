package sm.ac.app.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;


import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/aiinterview")
@RequiredArgsConstructor
public class AIInterviewController {

    private final RestTemplate restTemplate;

    @Value("${openai.api-key}")
    private String apiKey;

    // 1. JSP 페이지 반환 (초기 진입용)
    @GetMapping
    public String aiInterviewPage() {
        return "aiInterview"; // aiInterview.jsp
    }

    // 2. GPT 면접 질문 생성 API
    @PostMapping("/question")
    @ResponseBody
    public String generateQuestion(@RequestParam(defaultValue = "백엔드 개발자") String job) {
        try {
            String prompt = job + " 면접에서 사용할 질문을 하나 만들어줘.";



            // HTTP 요청 헤더
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(apiKey);

            System.out.println("🔐 API KEY (length): " + (apiKey == null ? "NULL" : apiKey.length()));
            System.out.println("📡 Bearer header: " + headers.get("Authorization"));

            // 메시지 및 본문 구성
            Map<String, Object> message = Map.of(
                    "role", "user",
                    "content", prompt
            );

            Map<String, Object> body = Map.of(
                    "model", "gpt-3.5-turbo",
                    "messages", List.of(message),
                    "temperature", 0.7
            );

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);

            // OpenAI API 호출
            ResponseEntity<String> response = restTemplate.postForEntity(
                    "https://api.openai.com/v1/chat/completions",
                    request,
                    String.class
            );

            // 응답 파싱
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(response.getBody());
            String question = root.path("choices").get(0).path("message").path("content").asText();

            return question;

        } catch (Exception e) {
            e.printStackTrace(); // 콘솔에 전체 오류 로그 출력
            return "질문 생성 중 오류 발생: " + e.getMessage();
        }
    }

    @PostMapping("/feedback")
    @ResponseBody
    public String analyzeAnswer(@RequestParam String answer, @RequestParam String job) {
        try {
            String prompt = String.format(
                    "'%s' 직무의 면접에서 다음 답변을 평가하고 논리성, 구체성, 표현력 기준으로 간단히 피드백 해줘:\n\n\"%s\"",
                    job, answer
            );

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(apiKey);

            Map<String, Object> message = Map.of("role", "user", "content", prompt);
            Map<String, Object> body = Map.of(
                    "model", "gpt-3.5-turbo",
                    "messages", List.of(message),
                    "temperature", 0.7
            );

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
            ResponseEntity<String> response = restTemplate.postForEntity(
                    "https://api.openai.com/v1/chat/completions",
                    request,
                    String.class
            );

            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(response.getBody());
            String feedback = root.path("choices").get(0).path("message").path("content").asText();

            return feedback;

        } catch (Exception e) {
            return "피드백 생성 중 오류: " + e.getMessage();
        }
    }



}