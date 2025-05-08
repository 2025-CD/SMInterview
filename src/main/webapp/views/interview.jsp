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
        <%-- body 태그의 data-userid 속성에 로그인 ID를 설정합니다. --%>
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
        <script src="https://webrtc.github.io/adapter/adapter-latest.js"></script> <%-- 중복되면 하나 삭제 --%>
        <script src="/webjars/sockjs-client/1.0.2/sockjs.min.js"></script>
        <script src="/webjars/stomp-websocket/2.3.3/stomp.min.js"></script>
            <%--        <script src="/js/main.js"></script>--%>

        </body>
    </c:otherwise>
</c:choose>
<script>
    const userId = document.body.dataset.userid;
    const localVideo = document.getElementById('localVideo');
    const remoteVideo = document.getElementById('remoteVideo');
    const muteButton = document.getElementById('muteButton');
    const statusElement = document.getElementById('status');
    const hangupButton = document.getElementById('hangupButton');
    const startConnectionButton = document.querySelector('button[onclick="startConnection()"]'); // 연결 시작 버튼

    let localStream;
    let remoteStream;
    let peerConnection;
    let isMuted = false;
    let remoteUserId; // 통화 상대방 ID
    const configuration = {
        iceServers: [{ urls: 'stun:stun.l.google.com:19302' }]
    };
    let stompClient;
    let isWaitingForMatch = false;
    let isConnected = false;

    document.addEventListener('DOMContentLoaded', () => {
        connectWebSocket();
        getUserMedia();
        hangupButton.disabled = true; // 초기에는 연결 종료 버튼 비활성화
    });

    function connectWebSocket() {
        const socket = new SockJS('/signal');
        stompClient = Stomp.over(socket);

        stompClient.connect({}, onConnected, onError);
    }

    function onConnected() {
        console.log('WebSocket 연결 성공');
        statusElement.textContent = '대기 중...';

// 자신에게 오는 시그널링 메시지 구독
        stompClient.subscribe(`/user/queue/signal-${userId}`, handleSignalingMessage);

// 매칭 결과를 받기 위한 구독
        stompClient.subscribe(`/user/queue/match-${userId}`, handleMatchResult);
    }

    function onError(error) {
        console.error('WebSocket 연결 실패:', error);
        statusElement.textContent = 'WebSocket 연결 실패';
    }

    function handleSignalingMessage(payload) {
        const message = JSON.parse(payload.body);
        console.log('받은 시그널링 메시지:', message);

        switch (message.type) {
            case 'offer':
                handleOffer(message);
                break;
            case 'answer':
                handleAnswer(message);
                break;
            case 'candidate':
                handleCandidate(message);
                break;
            case 'hangup':
                handleHangup();
                break;
        }
    }

    function handleMatchResult(payload) {
        const message = JSON.parse(payload.body);
        if (message.matched) {
            remoteUserId = message.otherUserId;
            statusElement.textContent = `상대방 ${remoteUserId}와 연결 중...`;
            isWaitingForMatch = false;
            startConnectionButton.disabled = true;
            hangupButton.disabled = false;
            startWebRTC();
        } else {
            statusElement.textContent = '매칭 실패. 다시 시도해주세요.';
            isWaitingForMatch = false;
            startConnectionButton.disabled = false;
        }
    }

    async function getUserMedia() {
        try {
            localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
            localVideo.srcObject = localStream;
        } catch (error) {
            console.error('미디어 장치 접근 오류:', error);
            statusElement.textContent = '미디어 장치 접근 오류';
        }
    }

    async function startConnection() {
        if (isWaitingForMatch || isConnected) {
            return;
        }
        isWaitingForMatch = true;
        statusElement.textContent = '연결 대기 중...';
        startConnectionButton.disabled = true;

// 서버에 매칭 요청 전송
        stompClient.send('/app/match', {}, JSON.stringify({ userId: userId }));
    }

    async function startWebRTC() {
        await createPeerConnection();
        try {
            const offer = await peerConnection.createOffer();
            await peerConnection.setLocalDescription(offer);

            sendMessage({
                type: 'offer',
                offer: offer,
                receiverId: remoteUserId
            });
        } catch (error) {
            console.error('Offer 생성 오류:', error);
            statusElement.textContent = 'Offer 생성 오류';
            resetCall();
        }
    }

    async function createPeerConnection() {
        peerConnection = new RTCPeerConnection(configuration);

        peerConnection.onicecandidate = handleIceCandidate;
        peerConnection.ontrack = handleRemoteStream;
        peerConnection.oniceconnectionstatechange = handleIceStateChange;

        localStream.getTracks().forEach(track => peerConnection.addTrack(track, localStream));
    }

    function handleIceStateChange() {
        console.log('ICE connection state:', peerConnection.iceConnectionState);
        if (peerConnection.iceConnectionState === 'failed' ||
            peerConnection.iceConnectionState === 'disconnected' ||
            peerConnection.iceConnectionState === 'closed') {
            resetCall();
        }
    }

    function handleIceCandidate(event) {
        if (event.candidate && remoteUserId) {
            sendMessage({
                type: 'candidate',
                candidate: event.candidate,
                receiverId: remoteUserId
            });
        }
    }

    function handleRemoteStream(event) {
        if (event.track.kind === 'video') {
            remoteVideo.srcObject = event.streams[0];
        }
    }

    async function handleOffer(message) {
        if (isConnected) return;
        isConnected = true;
        remoteUserId = message.senderId;
        statusElement.textContent = `상대방 ${remoteUserId}와 연결됨`;
        startConnectionButton.disabled = true;
        hangupButton.disabled = false;

        await createPeerConnection();
        try {
            await peerConnection.setRemoteDescription(new RTCSessionDescription(message.offer));
            const answer = await peerConnection.createAnswer();
            await peerConnection.setLocalDescription(answer);

            sendMessage({
                type: 'answer',
                answer: answer,
                receiverId: remoteUserId
            });
        } catch (error) {
            console.error('Answer 생성 오류:', error);
            statusElement.textContent = 'Answer 생성 오류';
            resetCall();
        }
    }

    async function handleAnswer(message) {
        try {
            await peerConnection.setRemoteDescription(new RTCSessionDescription(message.answer));
            statusElement.textContent = `화상 통화 시작`;
            isConnected = true;
        } catch (error) {
            console.error('Answer 처리 오류:', error);
            statusElement.textContent = 'Answer 처리 오류';
            resetCall();
        }
    }

    async function handleCandidate(message) {
        try {
            if (peerConnection) {
                await peerConnection.addIceCandidate(new RTCIceCandidate(message.candidate));
            }
        } catch (error) {
            console.error('ICE candidate 처리 오류:', error);
        }
    }

    function sendMessage(message) {
        if (stompClient && stompClient.connected && remoteUserId) {
            stompClient.send(`/app/signal-${remoteUserId}`, {}, JSON.stringify(message));
        }
    }

    function toggleMute() {
        isMuted = !isMuted;
        localStream.getAudioTracks().forEach(track => track.enabled = !isMuted);
        muteButton.textContent = isMuted ? '마이크 끄기' : '마이크 켜기';
    }

    function captureLocalImage() { /* ... 기존 코드 ... */ }
    function captureRemoteImage() { /* ... 기존 코드 ... */ }

    function hangUp() {
        if (isConnected && peerConnection) {
            sendMessage({ type: 'hangup' });
            peerConnection.close();
        }
        resetCall();
    }

    function handleHangup() {
        statusElement.textContent = '상대방이 연결을 종료했습니다.';
        resetCall();
    }

    function resetCall() {
        isConnected = false;
        isWaitingForMatch = false;
        remoteUserId = null;
        statusElement.textContent = '대기 중...';
        startConnectionButton.disabled = false;
        hangupButton.disabled = true;
        if (remoteVideo.srcObject) {
            remoteVideo.srcObject.getTracks().forEach(track => track.stop());
        }
        remoteVideo.srcObject = null;
        if (peerConnection) {
            peerConnection = null;
        }
    }
</script>



</html>