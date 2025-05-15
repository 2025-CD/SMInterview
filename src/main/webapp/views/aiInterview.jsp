<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI 모의 면접</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #dfefff, #f0f5ff);
            color: #333;
            margin: 0;
            padding: 0;
        }
        .main-content {
            width: 80%;
            margin: 30px auto;
            background-color: #fff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
        }
        .page-header h1 {
            text-align: center;
            color: #333;
            margin-bottom: 20px;
        }
        #question-area {
            min-height: 100px;
            background-color: #f1f1f1;
            padding: 15px;
            border-radius: 6px;
            border-left: 4px solid #0d6efd;
        }
        #answer-area {
            resize: none;
            overflow: hidden;
            min-height: 100px;
        }
        .form-label {
            font-weight: bold;
            color: #555;
        }
        #volume-visual {
            height: 10px;
            background-color: #ccc;
            margin-top: 5px;
            border-radius: 5px;
            overflow: hidden;
        }
        #volume-bar {
            height: 100%;
            width: 0%;
            background-color: #28a745;
            transition: width 0.2s ease;
        }
        .btn-group button {
            min-width: 110px;
        }
        .feedback-box {
            background-color: #f9f9f9;
            border-left: 4px solid #ffc107;
            padding: 15px;
            border-radius: 5px;
        }
        @media (max-width: 768px) {
            .main-content {
                width: 95%;
            }
        }
    </style>
</head>
<body>
<div class="container main-content">
    <div class="page-header">
        <h1><i class="fas fa-robot"></i> AI 모의 면접</h1>
    </div>

    <div class="form-group mb-4">
        <label class="form-label">AI 질문</label>
        <div id="question-area">AI 질문이 여기에 표시됩니다.</div>
    </div>

    <div class="form-group mb-3">
        <label class="form-label" for="jobSelect">목표 직무 선택</label>
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

    <div class="form-group mb-3">
        <label class="form-label" for="answer-area">사용자 답변</label>
        <textarea id="answer-area" class="form-control" placeholder="음성으로 입력되며, 직접 수정도 가능합니다."></textarea>
    </div>

    <div id="volume-visual" class="mb-3">
        <div id="volume-bar"></div>
    </div>

    <div class="text-center mb-4">
        <button id="start-interview" class="btn btn-primary">🎙 면접 시작</button>
    </div>

    <div class="btn-group d-flex justify-content-between mb-4">
        <button id="start-stt" class="btn btn-outline-primary"><i class="fas fa-microphone"></i> 답변하기</button>
        <button id="stop-stt" class="btn btn-outline-danger" disabled><i class="fas fa-stop-circle"></i> 답변 종료</button>
        <button id="submit-answer" class="btn btn-success"><i class="fas fa-paper-plane"></i> 제출하기</button>
    </div>

    <div class="feedback-box">
        <strong>AI 피드백:</strong>
        <div id="feedback-content">답변에 대한 피드백이 여기에 표시됩니다.</div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    const csrfToken = "${_csrf.token}";
    const csrfHeader = "${_csrf.headerName}";


    const tts = window.speechSynthesis;
    const ttsUtterance = new SpeechSynthesisUtterance();

    function speak(text) {
        ttsUtterance.text = text;
        tts.speak(ttsUtterance);
    }

    $(document).ready(function () {
        $("#start-interview").click(function () {
            console.log("면접 시작 버튼 클릭됨");
            const selectedJob = $("#jobSelect").val();
            if (!selectedJob) {
                alert("직무를 선택해주세요.");
                return;
            }

            $.ajax({
                type: "POST",
                url: "/aiinterview/question",
                data: { job: selectedJob },
                // beforeSend: function (xhr) {
                //     xhr.setRequestHeader(csrfHeader, csrfToken);
                // },
                success: function (question) {
                    $("#question-area").text(question);
                    speak(question);
                },
                error: function () {
                    alert("질문 생성 오류 발생");
                }
            });
        });

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
            stopVisualizer();
            $("#stop-stt").prop("disabled", true);
            $("#start-stt").prop("disabled", false);
        };

        $("#start-stt").click(function () {
            stt.start();
            $("#start-stt").prop("disabled", true);
            $("#stop-stt").prop("disabled", false);
            startVisualizer();
        });

        $("#stop-stt").click(function () {
            stt.stop();
        });

        $("#submit-answer").click(function () {
            const answer = $("#answer-area").val();
            const job = $("#jobSelect").val();
            if (!answer.trim()) {
                alert("답변 내용을 입력해주세요.");
                return;
            }

            $.ajax({
                type: "POST",
                url: "/aiinterview/feedback",
                data: { answer: answer, job: job },
                // beforeSend: function (xhr) {
                //     xhr.setRequestHeader(csrfHeader, csrfToken);
                // },
                success: function (feedback) {
                    $("#feedback-content").text(feedback);
                },
                error: function () {
                    $("#feedback-content").text("피드백 생성 오류 발생");
                }
            });
        });

        // 데시벨 시각화
        let audioContext, analyser, microphone, animationId;

        function startVisualizer() {
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

        function stopVisualizer() {
            if (audioContext) {
                audioContext.close();
                cancelAnimationFrame(animationId);
            }
            $("#volume-bar").css("width", "0%");
        }

        // 자동 높이 조절
        const textarea = document.getElementById("answer-area");
        textarea.addEventListener("input", function () {
            this.style.height = "auto";
            this.style.height = this.scrollHeight + "px";
        });
    });
</script>
</body>
</html>
