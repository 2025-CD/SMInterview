<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <title>웹캠 테스트</title>
    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="assets/favicon.ico" />
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css" rel="stylesheet" />
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css?family=Merriweather+Sans:400,700" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css?family=Merriweather:400,300,300italic,400italic,700,700italic" rel="stylesheet" type="text/css" />
    <!-- SimpleLightbox plugin CSS -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/SimpleLightbox/2.1.0/simpleLightbox.min.css" rel="stylesheet" />
    <!-- Bootstrap CSS -->
    <link href="css/styles.css" rel="stylesheet" />
    <style>
        video {
            width: 100%;
            max-width: 600px;
            border: 5px solid black;
            border-radius: 10px;
            transition: border-color 0.3s ease-in-out;
        }
        #capturedImage {
            opacity: 0;
            transition: opacity 0.5s ease-in-out;
            border: 2px solid blue;
            display: block;
            margin-top: 10px;
            max-width: 100%;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-light sticky-top py-3" id="mainNav">
        <div class="container px-4 px-lg-5">
            <a class="navbar-brand text-dark" href="/#page-top">Mockup</a>
            <button class="navbar-toggler navbar-toggler-right" type="button" data-bs-toggle="collapse" data-bs-target="#navbarResponsive" aria-controls="navbarResponsive" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
        </div>
    </nav>

    <div class="container mt-4">
        <h2 class="text-center">웹캠 테스트</h2>
        <div class="text-center">
            <video id="webcam" autoplay playsinline></video>
            <br>

            <button class="btn btn-danger mt-2" onclick="toggleMute()" id="muteButton">마이크 음소거</button>
            <button class="btn btn-primary mt-2" onclick="startWebcam()">웹캠 시작</button>
            <button class="btn btn-success mt-2" onclick="captureImage()">사진 찍기</button>
            <canvas id="canvas" style="display: none;"></canvas>
            <img id="capturedImage" style="opacity: 0; display: none;" />
        </div>
    </div>

    <script>
        let audioTrack;
        let isMuted = false;
        let audioContext, analyser, microphone, dataArray;

        async function startWebcam() {
            try {
                const stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
                document.getElementById('webcam').srcObject = stream;
                audioTrack = stream.getAudioTracks()[0];
                setupAudioProcessing(stream);
            } catch (error) {
                alert("웹캠과 마이크를 사용할 수 없습니다: " + error);
            }
        }

        function setupAudioProcessing(stream) {
            audioContext = new AudioContext();
            analyser = audioContext.createAnalyser();
            microphone = audioContext.createMediaStreamSource(stream);
            microphone.connect(analyser);
            analyser.fftSize = 256;
            dataArray = new Uint8Array(analyser.frequencyBinCount);
            detectAudioLevel();
        }

        function detectAudioLevel() {
            analyser.getByteFrequencyData(dataArray);
            let volume = dataArray.reduce((a, b) => a + b, 0) / dataArray.length;
            document.getElementById('webcam').style.borderColor = volume > 10 ? 'green' : 'black';
            requestAnimationFrame(detectAudioLevel);
        }

        function captureImage() {
            const video = document.getElementById('webcam');
            const canvas = document.getElementById('canvas');
            const ctx = canvas.getContext('2d');

            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

            const image = document.getElementById('capturedImage');
            image.src = canvas.toDataURL("image/png");
            image.style.display = "block";
            setTimeout(() => image.style.opacity = "1", 100);
        }

        function toggleMute() {
            if (audioTrack) {
                isMuted = !isMuted;
                audioTrack.enabled = !isMuted;
                document.getElementById('muteButton').textContent = isMuted ? "마이크 켜기" : "마이크 음소거";
            }
        }
    </script>
</body>
</html>
