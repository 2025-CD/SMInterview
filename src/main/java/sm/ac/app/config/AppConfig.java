package sm.ac.app.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration // 이 클래스가 Spring의 설정 클래스임을 나타냅니다.
public class AppConfig {

    @Bean // 이 메서드가 반환하는 객체를 Spring 빈으로 등록합니다.
    public RestTemplate restTemplate() {
        // 기본 RestTemplate 인스턴스를 생성하여 반환합니다.
        // 필요에 따라 MessageConverter, ClientHttpRequestFactory 등을 설정할 수 있습니다.
        return new RestTemplate();
    }
}

