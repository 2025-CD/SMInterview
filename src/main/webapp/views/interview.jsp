<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <meta name="description" content="실시간 면접 연습" />
    <meta name="author" content="" />
    <title>실시간 면접 연습</title>
    <link rel="icon" type="image/x-icon" href="assets/favicon.ico" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css?family=Merriweather+Sans:400,700" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css?family=Merriweather:400,300,300italic,400italic,700,700italic" rel="stylesheet" type="text/css" />
    <link href="css/styles.css" rel="stylesheet" />
    <style>
        .video-container {
            display: flex;
            flex-wrap: wrap; /* 화면 작아지면 줄바꿈 */
            justify-content: space-around; /* 비디오 간 간격 */
            align-items: flex-start;
        }

        .video-wrapper {
            flex: 1; /* 가능한 공간 차지 */
            min-width: 300px; /* 최소 너비 */
            max-width: 600px; /* 최대 너비 */
            margin: 10px;
            text-align: center;
        }

        video {
            width: 100%;
            border: 3px solid black;
            border-radius: 8px;
            background-color: #f0f0f0; /* 비디오 로딩 전 배경색 */
        }

        #localVideo {
            /* 내 화면 구분 스타일 (선택적) */
            border-color: steelblue;
        }

        #remoteVideo {
            /* 상대방 화면 구분 스타일 (선택적) */
            border-color: mediumseagreen;
        }

        /* 캡처 이미지 스타일 (필요시) */
        #captureCanvas, #capturedImageLocal, #capturedImageRemote {
            display: none;
            max-width: 100%;
            margin-top: 10px;
            border: 1px solid lightgray;
        }

        #status {
            margin-top: 15px;
            font-weight: bold;
            min-height: 24px; /* 상태 메시지 영역 높이 확보 */
        }
    </style>
</head>

<c:choose>
<c:when test="${empty sessionScope.loginid}">
<body>
<p>실시간 면접 연습을 이용하려면 로그인이 필요합니다. <a href="/login">로그인 페이지로 이동</a></p>
</body>
</c:when>
<c:otherwise>
    <%-- 로그인 된 사용자에게 보여줄 내용 --%>
<body data-userid="${sessionScope.loginid.id}">
<nav class="navbar navbar-expand-lg navbar-light sticky-top py-3" id="mainNav">
        <%-- 네비게이션 바 내용 --%>
</nav>

<div class="container mt-4">
    <h2 class="text-center">실시간 면접 연습</h2>
    <p class="text-center" id="status">연결 준비 중...</p> <%-- status 요소 --%>

        <%-- ▼▼▼ 이 HTML 코드들이 여기에 있어야 합니다! ▼▼▼ --%>
    <div class="video-container">
        <div class="video-wrapper">
            <h5>내 화면 (Local)</h5>
            <video id="localVideo" autoplay playsinline muted></video> <%-- localVideo 요소 --%>
            <button id="muteButton" class="btn btn-secondary mt-2 btn-sm" onclick="toggleMute()">마이크 켜기</button> <%-- muteButton 요소 --%>
            <button class="btn btn-info mt-2 btn-sm" onclick="captureLocalImage()">내 화면 캡쳐</button>
            <img id="capturedImageLocal" alt="내 화면 캡쳐"/>
        </div>
        <div class="video-wrapper">
            <h5>상대방 화면 (Remote)</h5>
            <video id="remoteVideo" autoplay playsinline></video> <%-- remoteVideo 요소 --%>
            <button class="btn btn-info mt-2 btn-sm" onclick="captureRemoteImage()">상대 화면 캡쳐</button>
            <img id="capturedImageRemote" alt="상대방 화면 캡쳐"/>
        </div>
    </div>

    <div class="text-center mt-4">
            <%-- startConnection 버튼 (querySelector로 찾음) --%>
        <button class="btn btn-primary" onclick="startConnection()">연결 시작</button>
            <%-- hangupButton 요소 --%>
        <button id="hangupButton" class="btn btn-danger" onclick="hangUp()">연결 종료</button>
    </div>

    <canvas id="captureCanvas" style="display: none;"></canvas>
        <%-- ▲▲▲ 여기까지 필수 요소들 ▲▲▲ --%>

</div> <%-- // container mt-4 --%>

    <%-- 스크립트는 맨 아래에 위치 --%>
<script src="https://webrtc.github.io/adapter/adapter-latest.js"></script> <%-- 중복이면 하나 삭제 --%>
<script src="/webjars/sockjs-client/1.0.2/sockjs.min.js"></script>
<script src="/webjars/stomp-websocket/2.3.3/stomp.min.js"></script>
<script src="/js/main.js"></script>

</body>
</c:otherwise>
</c:choose>
