package sm.ac.service;

import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class ResumeService {

    public Map<String, Map<String, String>> analyze(String resumeText, String targetJob) {
        // 간단한 더미 분석 결과 생성
        Map<String, String> section = new HashMap<>();
        section.put("분석", "이력서 내용이 분석되었습니다.");
        section.put("개선 제안", "직무 '" + targetJob + "'에 맞춰 구체적인 경험을 강조해보세요.");

        Map<String, Map<String, String>> result = new HashMap<>();
        result.put("분석 결과", section);

        return result;
    }
}
