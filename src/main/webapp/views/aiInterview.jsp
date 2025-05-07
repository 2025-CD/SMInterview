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
            min-height: 200px;
        }
    </style>
</head>
<body>
<div class="container">
    <h1 class="text-center">TTS STT 테스트</h1>

    <!-- 질문 표시 영역 -->
    <div class="form-group mt-4">
        <label><strong>AI 질문</strong></label>
        <div id="question-area" class="p-3 border rounded">AI 질문이 여기에 표시됩니다.</div>
    </div>

    <!-- 직무 선택 -->
    <div class="form-group mt-3">
        <label for="jobSelect">목표 직무 선택</label>
        <select id="jobSelect" class="form-select">
            <option value="">-- 선택하세요 --</option>
            <option value="소프트웨어 엔지니어 (백엔드)">소프트웨어 엔지니어 (백엔드)</option>
            <option value="소프트웨어 엔지니어 (프론트엔드)">소프트웨어 엔지니어 (프론트엔드)</option>
            <option value="데이터 분석가">데이터 분석가</option>
            <option value="웹 개발자">웹 개발자</option>
            <option value="마케팅 담당자">마케팅 담당자</option>
            <option value="기획자">기획자</option>
        </select>
    </div>

    <!-- 사용자 답변 영역: 자동 확장 기능 적용 -->
    <div class="form-group mt-3">
        <label for="answer-area">사용자 답변</label>
        <textarea id="answer-area" class="form-control" rows="1"
                  style="overflow:hidden; resize:none; min-height: 80px;"
                  placeholder="말하면 자동 입력되며, 직접 수정도 가능합니다."></textarea>
    </div>

    <!-- 데시벨 시각화 -->
    <div id="volume-visual" class="my-2" style="height: 10px; background-color: #ccc;">
        <div id="volume-bar" style="height: 100%; width: 0%; background-color: #28a745;"></div>
    </div>

    <div class="text-center mt-4">
        <button id="start-interview" class="btn btn-primary">🎙 면접 시작</button>
    </div>

    <!-- 제어 버튼들 -->
    <div class="btn-group mt-3" role="group">
        <button id="start-stt" class="btn btn-outline-primary">🎤 답변하기</button>
        <button id="stop-stt" class="btn btn-outline-danger" disabled>🛑 답변 종료</button>
        <button id="submit-answer" class="btn btn-success">📋 제출하기</button>
    </div>

    <!-- 피드백 출력 -->
    <div id="feedback-area" class="mt-4 p-3 border rounded bg-light">
        <strong>AI 피드백:</strong>
        <div id="feedback-content">답변에 대한 피드백이 여기에 표시됩니다.</div>
    </div>


    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    const csrfToken = "${_csrf.token}";
    const csrfHeader = "${_csrf.headerName}";

    $(document).ready(function () {
        const tts = window.speechSynthesis;
        const ttsUtterance = new SpeechSynthesisUtterance();

        function speak(text) {
            ttsUtterance.text = text;
            tts.speak(ttsUtterance);
        }

        // 직무 선택 → 질문 요청
        $("#start-interview").click(function () {
            const selectedJob = $("#jobSelect").val();
            if (!selectedJob) {
                alert("직무를 선택해주세요.");
                return;
            }

            $.ajax({
                type: "POST",
                url: "/aiinterview/question",
                data: { job: selectedJob },
                beforeSend: function (xhr) {
                    xhr.setRequestHeader(csrfHeader, csrfToken);
                },
                success: function (question) {
                    $("#question-area").text(question);
                    speak(question); // TTS만 실행 (STT는 버튼 누를 때)
                },
                error: function () {
                    alert("질문 생성 오류 발생");
                }
            });
        });

        // ===== STT 관련 설정 =====
        const stt = new webkitSpeechRecognition();
        stt.continuous = true;
        stt.interimResults = true;

        stt.onresult = function (event) {
            let transcript = '';
            for (let i = event.resultIndex; i < event.results.length; ++i) {
                transcript += event.results[i][0].transcript;
            }
            $("#answer-area").val(transcript);
        };

        stt.onend = function () {
            stopVolumeVisualizer(); // 음량 시각화 중단
            $("#stop-stt").prop("disabled", true);
            $("#start-stt").prop("disabled", false);
        };

        // ===== 마이크 버튼 제어 =====
        $("#start-stt").click(function () {
            stt.start();
            $("#start-stt").prop("disabled", true);
            $("#stop-stt").prop("disabled", false);
            startVolumeVisualizer(); // 데시벨 시각화 시작
        });

        $("#stop-stt").click(function () {
            stt.stop();
            stopVolumeVisualizer();
        });

        // ===== GPT 분석 전송 =====
        $("#submit-answer").click(function () {
            const finalAnswer = $("#answer-area").val();
            const job = $("#jobSelect").val();

            if (!finalAnswer.trim()) {
                alert("답변 내용을 입력해주세요.");
                return;
            }

            $.ajax({
                type: "POST",
                url: "/aiinterview/feedback",
                data: { answer: finalAnswer, job: job },
                beforeSend: function (xhr) {
                    xhr.setRequestHeader(csrfHeader, csrfToken);
                },
                success: function (feedback) {
                    $("#feedback-content").text(feedback);
                },
                error: function () {
                    $("#feedback-content").text("피드백 생성 오류 발생");
                }
            });
        });

        // ===== 데시벨 시각화 =====
        let audioContext, analyser, microphone, animationId;

        function startVolumeVisualizer() {
            navigator.mediaDevices.getUserMedia({ audio: true }).then((stream) => {
                audioContext = new (window.AudioContext || window.webkitAudioContext)();
                analyser = audioContext.createAnalyser();
                microphone = audioContext.createMediaStreamSource(stream);
                microphone.connect(analyser);
                analyser.fftSize = 256;

                const dataArray = new Uint8Array(analyser.frequencyBinCount);

                function update() {
                    analyser.getByteFrequencyData(dataArray);
                    const volume = dataArray.reduce((a, b) => a + b) / dataArray.length;
                    const percent = Math.min(100, Math.round(volume));
                    $("#volume-bar").css("width", percent + "%");
                    animationId = requestAnimationFrame(update);
                }

                update();
            }).catch((err) => {
                console.error("마이크 접근 실패:", err);
            });
        }

        function stopVolumeVisualizer() {
            if (audioContext) {
                audioContext.close();
                cancelAnimationFrame(animationId);
            }
            $("#volume-bar").css("width", "0%");
        }
    });


    <!-- 자동 확장 JavaScript (JQuery 없이도 동작) -->
    const textarea = document.getElementById("answer-area");
    textarea.addEventListener("input", function () {
        this.style.height = "auto";              // 높이 초기화
        this.style.height = this.scrollHeight + "px";  // scrollHeight 기준으로 확장
    });
</script>

</body>
</html>


