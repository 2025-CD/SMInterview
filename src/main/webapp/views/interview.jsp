<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>웹캠 테스트</title>
    <style>
        video {
            width: 100%;
            max-width: 600px;
            border: 2px solid black;
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <h2>웹캠 테스트</h2>
    <video id="webcam" autoplay playsinline></video>
    <button onclick="startWebcam()">웹캠 시작</button>
    <button onclick="captureImage()">사진 찍기</button>
    <canvas id="canvas" style="display: none;"></canvas>
    <img id="capturedImage" style="display: none; border: 2px solid blue;"/>

    <script>
        async function startWebcam() {
            try {
                const stream = await navigator.mediaDevices.getUserMedia({ video: true });
                document.getElementById('webcam').srcObject = stream;
            } catch (error) {
                alert("웹캠을 사용할 수 없습니다: " + error);
            }
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
        }
    </script>
</body>
</html>
