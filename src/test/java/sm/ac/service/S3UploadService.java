package sm.ac.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.IOException;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class S3UploadService {

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;

    private final S3Client s3Client;
    private final ObjectMapper objectMapper;

    // ✅ 원래 있던 메서드 (userId 포함)
    public void uploadAnalysisResult(Map<String, Map<String, String>> analysisResult, String userId) {
        try {
            String json = objectMapper.writeValueAsString(analysisResult);

            String key = "resume-analysis/" + userId + "_result_" + System.currentTimeMillis() + ".json";

            PutObjectRequest request = PutObjectRequest.builder()
                    .bucket(bucket)
                    .key(key)
                    .contentType("application/json")
                    .build();

            s3Client.putObject(request, RequestBody.fromString(json));
        } catch (IOException e) {
            throw new RuntimeException("S3 업로드 중 오류 발생", e);
        }
    }

    // ✅ 새로 추가된 메서드 (userId 없이 바로 저장)
    public void uploadAnalysisResult(Map<String, Map<String, String>> analysisResult) {
        try {
            String json = objectMapper.writeValueAsString(analysisResult);

            String key = "resume-analysis/anonymous_" + System.currentTimeMillis() + ".json";

            PutObjectRequest request = PutObjectRequest.builder()
                    .bucket(bucket)
                    .key(key)
                    .contentType("application/json")
                    .build();

            s3Client.putObject(request, RequestBody.fromString(json));
        } catch (IOException e) {
            throw new RuntimeException("S3 업로드 중 오류 발생", e);
        }
    }
}
