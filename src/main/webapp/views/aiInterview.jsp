<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
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
        .feedback-box {
            background-color: #f9f9f9;
            border-left: 4px solid #ffc107;
            padding: 15px;
            border-radius: 5px;
        }
        .btn-group button {
            min-width: 110px;
        }
    </style>
</head>
<body>
<div class="container main-content">
    <div class="page-header">
        <h1><i class="fas fa-robot"></i> AI 모의 면접</h1>
    </div>

    <div class="form-group mb-3">
        <label class="form-label">목표 직무 선택</label>
        <select id="jobSelect" class="form-select">
            <option value="">-- 선택해주세요 --</option>
            <option value="소프트웨어 엔지니어 (백엔드)">소프트웨어 엔지니어 (백엔드)</option>
            <option value="소프트웨어 엔지니어 (프론트엔드)">소프트웨어 엔지니어 (프론트엔드)</option>
            <option value="데이터 분석가">데이터 분석가</option>
            <option value="웹 개발자">웹 개발자</option>
            <option value="마\ucr
케팅 담당자">마애티담당자</option>
            <option value="기획자">기획자</option>
        </select>
    </div>

    <div class="form-group mb-3">
        <label>
            AI 질문 <span id="question-count" class="text-muted small">(2/5)</span>
        </label>
        <div id="question-area" class="form-control" style="min-height: 100px; background-color: #f1f1f1;"></div>
    </div>

    <div class="form-group mb-3">
        <label class="form-label" for="answer-area">사용자 답변</label>
        <textarea id="answer-area" class="form-control" placeholder="음성으로 입력되며, 직접 수정도 가능합니다."></textarea>
    </div>

    <div id="volume-visual" class="mb-3">
        <div id="volume-bar"></div>
    </div>

    <div class="text-center mb-4">
        <button id="start-interview" class="btn btn-primary">🎧 면접 시작</button>
        <button id="next-question" class="btn btn-outline-primary d-none">➡ 다음 질문</button>
        <button id="extend-session" class="btn btn-outline-secondary d-none">➕ 더 이어서 하기</button>
    </div>

    <div class="btn-group d-flex justify-content-between mb-4">
        <button id="start-stt" class="btn btn-outline-primary"><i class="fas fa-microphone"></i> 답변하기</button>
        <button id="stop-stt" class="btn btn-outline-danger" disabled><i class="fas fa-stop-circle"></i> 답변 종료</button>
        <button id="submit-answer" class="btn btn-success"><i class="fas fa-paper-plane"></i> 제출하기</button>
    </div>

    <div class="feedback-box">
        <strong>AI 피드벱:</strong>
        <div id="feedback-content">답변에 대한 피드벱이 여기에 표시됩니다.</div>
    </div>

    <div class="text-center mt-4">
        <button id="download-report" class="btn btn-outline-dark">
            <i class="fas fa-file-pdf"></i> 면접 요약 리포트 다운로드 (PDF)
        </button>
        <div id="download-status" class="text-muted mt-2" style="display: none;">파일 생성 중...</div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    let currentQuestion = 0;
    let totalQuestions = 5;

    const tts = window.speechSynthesis;
    const ttsUtterance = new SpeechSynthesisUtterance();

    function speak(text) {
        ttsUtterance.text = text;
        tts.speak(ttsUtterance);
    }

    function updateCounter() {
        $("#question-count").text(`(${currentQuestion+2}/${totalQuestions+5})`);
    }

    function requestQuestion() {
        const job = $("#jobSelect").val();
        if (!job) {
            alert("\uc9c1\ubb34\ub97c \uc120\ud0dd\ud574\uc8fc\uc138\uc694.");
            return;
        }

        $.ajax({
            type: "POST",
            url: "/aiinterview/question",
            data: { job: job },
            success: function (question) {
                $("#question-area").text(question);
                speak(question);
                currentQuestion++;
                updateCounter();

                if (currentQuestion >= totalQuestions) {
                    $("#next-question").addClass("d-none");
                    $("#extend-session").removeClass("d-none");
                } else {
                    $("#next-question").removeClass("d-none");
                    $("#extend-session").addClass("d-none");
                }
            },
            error: function () {
                alert("\uc9c8\ubb38 \uc0dd\uc131 \uc624\ub958 \ubc1c\uc0dd");
            }
        });
    }

    $(document).ready(function () {
        $("#start-interview").click(function () {
            currentQuestion = 0;
            totalQuestions = 5;
            updateCounter();
            requestQuestion();
            $(this).addClass("d-none");
        });

        $("#next-question").click(function () {
            requestQuestion();
        });

        $("#extend-session").click(function () {
            totalQuestions += 5;
            requestQuestion();
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
                alert("\ub2f5\ubcc0 \ub0b4\uc6a9\uc744 \uc785\ub825\ud574\uc8fc\uc138\uc694.");
                return;
            }

            $.ajax({
                type: "POST",
                url: "/aiinterview/feedback",
                data: { answer: answer, job: job },
                success: function (feedback) {
                    $("#feedback-content").text(feedback);
                },
                error: function () {
                    $("#feedback-content").text("\ud53c\ub4dc\ubcb1 \uc0dd\uc131 \uc624\ub958 \ubc1c\uc0dd");
                }
            });
        });

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
            });
        }

        function stopVisualizer() {
            if (audioContext) {
                audioContext.close();
                cancelAnimationFrame(animationId);
            }
            $("#volume-bar").css("width", "0%");
        }

        document.getElementById("answer-area").addEventListener("input", function () {
            this.style.height = "auto";
            this.style.height = this.scrollHeight + "px";
        });
    });
</script>
</body>
</html>
