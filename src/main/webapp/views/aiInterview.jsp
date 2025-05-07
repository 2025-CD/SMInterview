<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>AI 모의 면접</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        /* 추가적인 스타일링 */
        #question-area {
            border: 1px solid #ccc;
            padding: 10px;
            margin-bottom: 10px;
            min-height: 100px;
        }
        #answer-area {
            border: 1px solid #ccc;
            padding: 10px;
            margin-bottom: 10px;
            min-height: 100px;
        }
    </style>
</head>
<body>
<div class="container">
    <h1 class="text-center">TTS STT 테스트</h1>

    <div id="qestion-area">
        AI 질문이 여기에 표시됩니다.
    </div>

    <div id="answer-area">
        사용자 답변이 여기에 표시됩니다.
    </div>u

    <button id="start-interview" class="btn btn-primary">테스트 시작ㅣㅣ</button>
    <button id="next-question" class="btn btn-secondary" disabled>다음 질문</button>

    <video id="webcam-video" style="display: none;"></video>
    <audio id="tts-audio" style="display: none;"></audio>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    $(document).ready(function() {
        // TTS (Text-to-Speech)
        const tts = window.speechSynthesis;
        const ttsUtterance = new SpeechSynthesisUtterance();

        function speak(text) {
            ttsUtterance.text = text;
            tts.speak(ttsUtterance);
        }

        // STT (Speech-to-Text)
        const stt = new webkitSpeechRecognition(); // Chrome 기반 브라우저 지원
        stt.continuous = false; // 한 번만 인식
        stt.interimResults = true; // 중간 결과 얻기

        stt.onresult = function(event) {
            let finalTranscript = '';
            for (let i = event.resultIndex; i < event.results.length; ++i) {
                if (event.results[i].isFinal) {
                    finalTranscript += event.results[i][0].transcript;
                }
            }
            $("#answer-area").text(finalTranscript); // 사용자 답변 표시
        };

        stt.onend = function() {
            // 답변 종료 처리 (AI 분석 요청 등)
        };

        function startSTT() {
            stt.start();
        }

        function stopSTT() {
            stt.stop();
        }

        // 이벤트 핸들러
        $("#start-interview").click(function() {
            // 첫 번째 질문 생성 및 출력
            const firstQuestion = "자기소개를 해주세요."; // 실제로는 AI API 호출로 생성
            $("#question-area").text(firstQuestion);
            speak(firstQuestion); // TTS로 질문 읽어주기
            startSTT(); // STT 시작
            $("#next-question").prop("disabled", false); // 다음 질문 버튼 활성화
        });

        $("#next-question").click(function() {
            // 다음 질문 생성 및 출력
            const nextQuestion = "당신의 강점은 무엇인가요?"; // 실제로는 AI API 호출로 생성
            $("#question-area").text(nextQuestion);
            speak(nextQuestion); // TTS로 질문 읽어주기
            stopSTT(); // 이전 답변 STT 종료
            startSTT(); // 새 답변 STT 시작
        });
    });
</script>

</body>
</html>


