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
                    <%-- startConnection 버튼 --%>
                <button class="btn btn-primary" type="button" onclick="startConnection()">연결 시작</button>
                    <%-- hangupButton 요소 --%>
                <button id="hangupButton" class="btn btn-danger" onclick="hangUp()">연결 종료</button>
            </div>

            <canvas id="captureCanvas" style="display: none;"></canvas>
                <%-- ▲▲▲ 여기까지 필수 요소들 ▲▲▲ --%>

        </div> <%-- // container mt-4 --%>

            <%-- 스크립트는 맨 아래에 위치 --%>
        <script src="https://webrtc.github.io/adapter/adapter-latest.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.6.1/sockjs.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>

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
    const startConnectionButton = document.querySelector('button[onclick="startConnection()"]');

    let localStream;
    let remoteStream;
    let peerConnection;
    let isMuted = false;
    let remoteUserId;
    const configuration = {
        iceServers: [{ urls: 'stun:stun.l.google.com:19302' }]
    };
    let stompClient;
    let isWaitingForMatch = false;
    let isConnected = false;
    let mediaAccessFailed = false;

    document.addEventListener('DOMContentLoaded', () => {
        connectWebSocket();
        getUserMedia();
        hangupButton.disabled = true;
        startConnectionButton.disabled = false; // 초기에는 연결 시작 버튼 활성화
    });

    function connectWebSocket() {
        const socket = new SockJS('/signal');
        stompClient = Stomp.over(socket);
        console.log('WebSocket 연결 시도...'); // 추가
        stompClient.connect({}, onConnected, onError);
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
        console.log('handleMatchResult 실행됨 - 페이로드:', payload); // 페이로드 전체 로깅

        try {
            const message = JSON.parse(payload.body);
            console.log('handleMatchResult 실행됨 - 파싱된 메시지:', message); // 파싱된 메시지 로깅

            if (message.matched) {
                remoteUserId = message.otherUserId;
                statusElement.textContent = `매칭 성공! 상대방 ID: ${remoteUserId}. 연결을 시작합니다...`;
                isWaitingForMatch = false;
                startConnectionButton.disabled = true; // 매칭 후 연결 시작은 자동으로 진행
                hangupButton.disabled = false;
                console.log('매칭 성공:', remoteUserId); // 매칭 성공 및 remoteUserId 로깅
                startWebRTC(); // 매칭 성공 시 WebRTC 연결 시작
            } else {
                statusElement.textContent = '매칭 실패. 다시 시도해주세요.';
                isWaitingForMatch = false;
                startConnectionButton.disabled = false;
                console.log('매칭 실패:', message.message); // 매칭 실패 메시지 로깅
            }
        } catch (error) {
            console.error('handleMatchResult 에러:', error); // 에러 발생 시 로깅
        }
    }

    async function getUserMedia() {
        // 웹 카메라와 마이크 없이 매칭 기능만 확인하기 위해 주석 처리 또는 비활성화
        // try {
        //     localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
        //     localVideo.srcObject = localStream;
        // } catch (error) {
        //     console.error('미디어 장치 접근 오류:', error);
        //     statusElement.textContent = '카메라 또는 마이크를 찾을 수 없습니다. 장치 연결 후 다시 시도해주세요.';
        //     mediaAccessFailed = true;
        // }

        // 미디어 스트림이 없음을 명시적으로 설정 (WebRTC 관련 기능은 동작하지 않음)
        localStream = null;
        mediaAccessFailed = true; // 미디어 접근에 실패한 것으로 간주하여 WebRTC 관련 로직 실행 방지
        statusElement.textContent = '카메라와 마이크 없이 매칭을 시도합니다.';
    }

    async function startConnection() {//"연결시작" 버튼 클릭시 호출
        console.log('연결 시작 버튼 클릭됨');
        console.log('stompClient:', stompClient); // 추가
        if (stompClient) {
            console.log('stompClient.connected:', stompClient.connected); // 추가
        }
        console.log('isWaitingForMatch:', isWaitingForMatch);
        console.log('isConnected:', isConnected);

        if (isWaitingForMatch || isConnected) { //이미 매칭 요청 중이거나 연결된 상태 면 함수 종료.
            console.log('이미 매칭 요청 중이거나 연결됨 - 함수 종료');
            return;
        }


        isWaitingForMatch = true; //중복된 매칭 요청 방지
        statusElement.textContent = '매칭 요청 중...';
        startConnectionButton.disabled = true;

        console.log('userId:', userId);
        console.log('stompClient:', stompClient);

        if (stompClient && stompClient.connected) {
            const matchRequest = JSON.stringify({ userId: userId });
            console.log('매칭 요청 전송 시도:', '/app/match', matchRequest);
            stompClient.send('/app/match', {}, matchRequest);
        } else {
            console.log('stompClient가 연결되지 않음 - 매칭 요청 전송 안 함');
        }
        //app/match라는 STOMP 엔드포인트로 메시지를 전송 ..
        //메시지 본문에는 현재 사용자의 userId가 JSON형태로 담겨 서버에 매칭 요청을 보낸다.

        // stompClient.send('/app/test', {}, 'Hello Server!');
    }
    function onConnected() {
        console.log('WebSocket 연결 성공');
        statusElement.textContent = '대기 중...';

        console.log('userId:', userId);
        const matchTopic = '/user/queue/match-' + userId;
        console.log('매칭 구독 시도:', matchTopic);
        console.log('stompClient 객체 (구독 전):', stompClient);
        console.log('stompClient 연결 상태 (구독 전):', stompClient ? stompClient.connected : 'stompClient is null');
        if (stompClient && stompClient.connected) {
            stompClient.subscribe(matchTopic, (payload) => {
                console.log('매칭 결과 페이로드 수신:', payload);
                handleMatchResult(payload);
            }, (error) => {
                console.error('매칭 구독 오류:', error);
            });
        } else {
            console.error('stompClient가 연결되지 않아 매칭 구독 실패');
        }

        const signalTopic = '/user/queue/signal-' + userId;
        console.log('시그널 구독 시도:', signalTopic);
        console.log('stompClient 객체 (두 번째 구독 전):', stompClient);
        console.log('stompClient 연결 상태 (두 번째 구독 전):', stompClient ? stompClient.connected : 'stompClient is null');
        if (stompClient && stompClient.connected) {
            stompClient.subscribe(signalTopic, handleSignalingMessage, (error) => {
                console.error('시그널 구독 오류:', error);
            });
        } else {
            console.error('stompClient가 연결되지 않아 시그널 구독 실패');
        }

        console.log('현재 userId 값:', userId);
        console.log('시그널 구독 토픽:', signalTopic);
        console.log('매칭 구독 토픽:', matchTopic);
    }

    async function startWebRTC() {
        if (mediaAccessFailed || !remoteUserId) {
            statusElement.textContent = '카메라/마이크 오류 또는 상대방 정보 없음.';
            return;
        }
        await createPeerConnection();
        try {
            const offer = await peerConnection.createOffer();
            await peerConnection.setLocalDescription(offer);
            sendMessage({ type: 'offer', offer: offer, receiverId: remoteUserId });
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
        if (localStream) {
            localStream.getTracks().forEach(track => peerConnection.addTrack(track, localStream));
        }
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
            sendMessage({ type: 'candidate', candidate: event.candidate, receiverId: remoteUserId });
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
        statusElement.textContent = `상대방과 연결 중...`;
        startConnectionButton.disabled = true;
        hangupButton.disabled = false;
        await createPeerConnection();
        try {
            await peerConnection.setRemoteDescription(new RTCSessionDescription(message.offer));
            const answer = await peerConnection.createAnswer();
            await peerConnection.setLocalDescription(answer);
            sendMessage({ type: 'answer', answer: answer, receiverId: remoteUserId });
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
            message.userId = userId; // 발신자 ID 추가
            stompClient.send(`/app/signal-${remoteUserId}`, {}, JSON.stringify(message));
        }
    }

    function toggleMute() {
        if (localStream) {
            localStream.getAudioTracks().forEach(track => track.enabled = !track.enabled);
            muteButton.textContent = isMuted ? '마이크 켜기' : '마이크 끄기';
            isMuted = !isMuted;
        }
    }

    function captureLocalImage() {
        const canvas = document.getElementById('captureCanvas');
        canvas.width = localVideo.videoWidth;
        canvas.height = localVideo.videoHeight;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(localVideo, 0, 0, canvas.width, canvas.height);
        const imgDataUrl = canvas.toDataURL('image/png');
        document.getElementById('capturedImageLocal').src = imgDataUrl;
        document.getElementById('capturedImageLocal').style.display = 'block';
    }

    function captureRemoteImage() {
        const canvas = document.getElementById('captureCanvas');
        canvas.width = remoteVideo.videoWidth;
        canvas.height = remoteVideo.videoHeight;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(remoteVideo, 0, 0, canvas.width, canvas.height);
        const imgDataUrl = canvas.toDataURL('image/png');
        document.getElementById('capturedImageRemote').src = imgDataUrl;
        document.getElementById('capturedImageRemote').style.display = 'block';
    }

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