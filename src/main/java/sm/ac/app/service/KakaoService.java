//package sm.ac.service;
//
//import com.fasterxml.jackson.databind.JsonNode;
//import com.fasterxml.jackson.databind.ObjectMapper;
//import lombok.RequiredArgsConstructor;
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.beans.factory.annotation.Value;
//import org.springframework.http.*;
//import org.springframework.stereotype.Service;
//import org.springframework.web.client.RestTemplate;
//
//import java.util.HashMap;
//import java.util.Map;
//import java.util.Optional;
//
//@Slf4j
//@Service
//@RequiredArgsConstructor
//public class KakaoService {
//
//    @Value("${spring.security.oauth2.client.registration.kakao.client-id}")
//    private String clientId;
//
//    @Value("${spring.security.oauth2.client.registration.kakao.redirect-uri}")
//    private String redirectUri;
//
//    // 토큰 및 사용자 정보 URL은 고정값 사용 (application.yml에 provider 설정과 다르게 사용할 수 있음)
//    private final String kakaoTokenUrl = "https://kauth.kakao.com/oauth/token";
//    private final String kakaoUserInfoUrl = "https://kapi.kakao.com/v2/user/me";
//
//    private final RestTemplate restTemplate;
//
//    /**
//     * 인가 코드를 이용하여 액세스 토큰 발급
//     */
//    public Optional<String> getAccessToken(String code) {
//        HttpHeaders headers = new HttpHeaders();
//        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
//
//        String requestBody = "grant_type=authorization_code"
//                + "&client_id=" + clientId
//                + "&redirect_uri=" + redirectUri
//                + "&code=" + code;
//
//        HttpEntity<String> request = new HttpEntity<>(requestBody, headers);
//        ResponseEntity<String> response = restTemplate.exchange(kakaoTokenUrl, HttpMethod.POST, request, String.class);
//
//        if (response.getStatusCode() == HttpStatus.OK) {
//            try {
//                ObjectMapper objectMapper = new ObjectMapper();
//                JsonNode jsonNode = objectMapper.readTree(response.getBody());
//                return Optional.ofNullable(jsonNode.get("access_token")).map(JsonNode::asText);
//            } catch (Exception e) {
//                log.error("JSON 파싱 오류: {}", e.getMessage());
//            }
//        } else {
//            log.error("카카오 토큰 발급 실패: {}", response.getBody());
//        }
//        return Optional.empty();
//    }
//
//    /**
//     * 액세스 토큰을 이용하여 사용자 정보 가져오기
//     */
//    public Optional<Map<String, Object>> getUserInfo(String code) {
//        Optional<String> accessTokenOpt = getAccessToken(code);
//        if (accessTokenOpt.isEmpty()) {
//            log.error("액세스 토큰 발급 실패!");
//            return Optional.empty();
//        }
//        String accessToken = accessTokenOpt.get();
//
//        HttpHeaders headers = new HttpHeaders();
//        headers.set("Authorization", "Bearer " + accessToken);
//        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
//
//        HttpEntity<String> request = new HttpEntity<>(headers);
//        ResponseEntity<String> response = restTemplate.exchange(kakaoUserInfoUrl, HttpMethod.GET, request, String.class);
//
//        if (response.getStatusCode() == HttpStatus.OK) {
//            try {
//                ObjectMapper objectMapper = new ObjectMapper();
//                JsonNode jsonNode = objectMapper.readTree(response.getBody());
//                log.info("카카오 사용자 정보: {}", jsonNode);
//
//                Map<String, Object> userInfo = new HashMap<>();
//                userInfo.put("id", jsonNode.get("id").asText());
//
//                JsonNode properties = jsonNode.get("properties");
//                if (properties != null && properties.has("nickname")) {
//                    userInfo.put("nickname", properties.get("nickname").asText());
//                }
//                return Optional.of(userInfo);
//            } catch (Exception e) {
//                log.error("JSON 파싱 오류: {}", e.getMessage());
//            }
//        } else {
//            log.error("카카오 사용자 정보 가져오기 실패: {}", response.getBody());
//        }
//        return Optional.empty();
//    }
//}
