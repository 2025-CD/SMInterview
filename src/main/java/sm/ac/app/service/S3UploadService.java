package sm.ac.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
public class S3UploadService {

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;

    private final S3Client s3Client;
    private final ObjectMapper objectMapper;

    public void uploadAnalysisResult(Map<String, Map<String, String>> analysisResult, String userId) {
        try {
            String json = objectMapper.writeValueAsString(analysisResult);
            String key = "resume-analysis/" + userId + "/result_" + System.currentTimeMillis() + ".json";

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


    public List<String> listAllResumeAnalysisFiles() {
        String prefix = "resume-analysis/";

        ListObjectsV2Request request = ListObjectsV2Request.builder()
                .bucket(bucket)
                .prefix(prefix)
                .build();

        ListObjectsV2Response response = s3Client.listObjectsV2(request);

        List<String> keys = response.contents().stream()
                .map(S3Object::key)
                .filter(key -> key.endsWith(".json"))
                .toList();

        System.out.println("S3 파일 목록: " + keys);
        return keys;
    }

    public String getJsonFileContent(String key) {
        try {
            GetObjectRequest getRequest = GetObjectRequest.builder()
                    .bucket(bucket)
                    .key(key)
                    .build();

            ResponseInputStream<GetObjectResponse> response = s3Client.getObject(getRequest);
            return new String(response.readAllBytes(), StandardCharsets.UTF_8);

        } catch (Exception e) {
            return "⚠️ 파일을 불러오는 중 오류 발생: " + e.getMessage();
        }
    }

    // ✅ S3 파일 목록 + 표시용 날짜 맵 반환
    public Map<String, String> listResumeFilesWithDisplayNames(String userId) {
        String prefix = "resume-analysis/" + userId + "/";

        ListObjectsV2Request request = ListObjectsV2Request.builder()
                .bucket(bucket)
                .prefix(prefix)
                .build();

        ListObjectsV2Response response = s3Client.listObjectsV2(request);

        // 👉 객체 목록을 타임스탬프 기준으로 내림차순 정렬
        List<S3Object> sorted = response.contents().stream()
                .filter(obj -> obj.key().endsWith(".json"))
                .sorted((a, b) -> Long.compare(
                        extractTimestampFromFilename(b.key()),
                        extractTimestampFromFilename(a.key())
                ))
                .toList();

        Map<String, String> fileDisplayMap = new LinkedHashMap<>();
        for (S3Object obj : sorted) {
            String key = obj.key();
            long timestamp = extractTimestampFromFilename(key);
            String displayName = formatTimestamp(timestamp);
            fileDisplayMap.put(key, displayName);
        }

        return fileDisplayMap;
    }



    private long extractTimestampFromFilename(String key) {
        try {
            String name = key.substring(key.lastIndexOf('_') + 1, key.lastIndexOf('.'));
            return Long.parseLong(name);
        } catch (Exception e) {
            return 0L;
        }
    }

    private String formatTimestamp(long millis) {
        if (millis == 0L) return "(날짜 없음)";
        Instant instant = Instant.ofEpochMilli(millis);
        LocalDateTime dateTime = LocalDateTime.ofInstant(instant, ZoneId.of("Asia/Seoul"));
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        return dateTime.format(formatter);
    }
}
