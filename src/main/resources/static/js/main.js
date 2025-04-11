'use strict';

// --- 전역 변수 선언 (값 할당은 window.onload에서) ---
let localVideo = null;
let remoteVideo = null;
let statusDiv = null;
let startButton = null;
let hangupButton = null;
let muteButton = null;
// 캡처 버튼 (선택적)
// let captureLocalButton = null;
// let captureRemoteButton = null;
let stompClient = null;
let localStream = null;
let peerConnection = null;
let localSessionId = null; // 자신의 WebSocket 세션 ID
let remoteSessionId = null; // 매칭된 상대방의 세션 ID
let isMuted = false;
let makingOffer = false; // Offer 생성 경쟁 상태 방지 플래그
let isPolite = false; // Offer 생성 경쟁 시 누가 양보할지 결정 (세션 ID 비교 기반)
let loggedInUserId = null; // 로그인 ID 저장 변수

// --- WebRTC 설정 ---
const pcConfig = {
    'iceServers': [{
        'urls': 'stun:stun.l.google.com:19302'
    }]
};

// --- 초기화 및 DOM 요소 찾기 ---
window.onload = () => {
    console.log("window.onload: DOM 로드 완료됨."); // 디버깅 로그

    // ▼▼▼ DOM 요소 찾는 코드를 여기로 이동 ▼▼▼
    localVideo = document.getElementById('localVideo');
    remoteVideo = document.getElementById('remoteVideo');
    statusDiv = document.getElementById('status');
    startButton = document.querySelector('button[onclick="startConnection()"]');
    hangupButton = document.querySelector('button[onclick="hangUp()"]');
    muteButton = document.getElementById('muteButton');
    // captureLocalButton = document.querySelector('button[onclick="captureLocalImage()"]'); // 필요시 주석 해제
    // captureRemoteButton = document.querySelector('button[onclick="captureRemoteImage()"]'); // 필요시 주석 해제

    // 로그인 ID 가져오기 (여기서 하는 것이 안전)
    // 주의: JSP의 body 태그에 data-userid="..." 로 설정했다고 가정
    try {
        loggedInUserId = document.body.dataset.userid;
        console.log("onload: 가져온 로그인 ID:", loggedInUserId);
        if (!loggedInUserId) {
            console.warn("onload: 로그인 ID를 data-userid 속성에서 찾을 수 없습니다.");
            updateStatus("로그인 정보를 찾을 수 없습니다."); // 사용자에게 알림
        }
    } catch (e) {
        console.error("onload: 로그인 ID 가져오기 실패", e);
        updateStatus("로그인 정보를 가져오는 중 오류 발생");
    }


    // 요소들이 제대로 로드되었는지 확인 (디버깅용)
    if (!localVideo) console.error("onload: localVideo 요소를 찾을 수 없습니다!");
    if (!remoteVideo) console.error("onload: remoteVideo 요소를 찾을 수 없습니다!");
    if (!statusDiv) console.error("onload: statusDiv 요소를 찾을 수 없습니다!");
    if (!startButton) console.error("onload: startButton 요소를 찾을 수 없습니다!");
    if (!hangupButton) console.error("onload: hangupButton 요소를 찾을 수 없습니다!");
    if (!muteButton) console.error("onload: muteButton 요소를 찾을 수 없습니다!"); // 이 로그가 보이면 JSP 확인 필요

    // 버튼 초기 상태 설정
    // 요소가 null이 아닐 때만 disabled 속성 변경
    if (hangupButton) hangupButton.disabled = true;
    if (muteButton) muteButton.disabled = true;
    // if (captureLocalButton) captureLocalButton.disabled = true; // 필요시 주석 해제
    // if (captureRemoteButton) captureRemoteButton.disabled = true; // 필요시 주석 해제
};


// --- WebSocket 및 STOMP 연결 ---
function startConnection() {
    // loggedInUserId는 이제 onload에서 설정되었으므로, 여기서는 사용하기만 함
    if (!loggedInUserId) {
        // onload에서 이미 경고/오류 로그를 남겼을 수 있으므로 여기서는 상태 업데이트만
        updateStatus("로그인 정보가 없습니다. 먼저 로그인해주세요.");
        console.error("startConnection: 로그인 ID 없음 (페이지 로드 확인)");
        return; // 함수 실행 중단
    }
    // startButton도 onload에서 설정됨
    if (!startButton) {
        console.error("startConnection: 시작 버튼 없음 (페이지 로드 확인)");
        updateStatus("시작 버튼을 찾을 수 없습니다.");
        return;
    }

    updateStatus(`${loggedInUserId}님, 연결 시도 중...`);
    startButton.disabled = true; // 이제 startButton이 null이 아닐 가능성이 높음

    try {
        const socket = new SockJS('/signal');
        stompClient = Stomp.over(socket);
        // 디버깅 메시지 끄기 (필요하면 주석 해제)
        // stompClient.debug = null;
        stompClient.connect({}, onWebSocketConnect, onWebSocketError);
    } catch (error) {
        console.error("SockJS 또는 STOMP 생성 중 오류:", error);
        updateStatus("연결 중 오류 발생 (라이브러리 확인 필요)");
        if (startButton) startButton.disabled = false; // 오류 시 버튼 다시 활성화
    }
}

function onWebSocketError(error) {
    console.error("WebSocket 오류:", error);
    updateStatus('WebSocket 연결 오류. 페이지를 새로고침하세요.');
    // 연결 실패 시 버튼 다시 활성화
    if (startButton) startButton.disabled = false;
    // 필요하다면 hangupButton 등 다른 버튼 상태도 조절
    if (hangupButton) hangupButton.disabled = true;
    if (muteButton) muteButton.disabled = true;
}

// onWebSocketConnect 함수 내에서도 필요 시 loggedInUserId 사용 가능
function onWebSocketConnect() {
    // 세션 ID 추출 로직 (기존과 동일, 단 에러 처리 보강)
    try {
        const transportUrl = stompClient.ws._transport.url;
        const urlParts = transportUrl.split('/');
        localSessionId = urlParts[urlParts.length - 2];
        console.log("내 세션 ID:", localSessionId);
        // 로그인 ID와 세션 ID 함께 표시
        updateStatus(`${loggedInUserId}님 (세션:${localSessionId.substring(0,5)}...), 매칭 대기 중...`);
    } catch (e) {
        console.error("세션 ID 추출 실패:", e);
        // 로그인 ID만이라도 표시
        updateStatus(`${loggedInUserId}님, 세션 ID 확인 실패. 연결을 종료합니다.`);
        hangUp(); // 에러 발생 시 정리하고 종료
        return;
    }

    // 구독 및 매칭 요청 로직 (기존과 동일)
    try {
        stompClient.subscribe('/topic/signal/' + localSessionId, onMessageReceived);
        stompClient.send("/app/match.request", {}, JSON.stringify({}));
        if (hangupButton) hangupButton.disabled = false; // 연결 성공 후 종료 버튼 활성화
    } catch (error) {
        console.error("STOMP 구독 또는 메시지 전송 오류:", error);
        updateStatus("서버 통신 중 오류 발생.");
        hangUp(); // 에러 발생 시 정리하고 종료
    }
}

// 서버로부터 메시지 수신 처리
function onMessageReceived(payload) {
    let message;
    try {
        message = JSON.parse(payload.body);
        console.log("메시지 수신:", message);
    } catch (error) {
        console.error("수신 메시지 JSON 파싱 오류:", error, payload.body);
        return;
    }


    switch (message.type) {
        case 'match_found':
            handleMatchFound(message);
            break;
        case 'offer':
            handleOffer(message);
            break;
        case 'answer':
            handleAnswer(message);
            break;
        case 'ice':
            handleIceCandidate(message);
            break;
        case 'hangup':
            handleHangup();
            break;
        default:
            console.warn("알 수 없는 메시지 유형:", message.type);
    }
}

// --- 매칭 성공 처리 ---
async function handleMatchFound(message) {
    if (!message.partnerId) {
        console.error("match_found 메시지에 partnerId가 없습니다.", message);
        updateStatus("매칭 오류 발생 (상대방 정보 없음)");
        return;
    }
    remoteSessionId = message.partnerId; // 매칭된 상대방 세션 ID 저장
    console.log("매칭 성공! 상대방:", remoteSessionId);
    updateStatus(`매칭 성공! 상대방(${remoteSessionId.substring(0, 5)}...)과 연결 준비 중...`);

    // 세션 ID 비교하여 Offer 생성 주도권 결정 (Polite/Impolite)
    isPolite = localSessionId < remoteSessionId;
    console.log(`나는 ${isPolite ? 'polite' : 'impolite'} peer 입니다.`);

    try {
        // 1. 로컬 미디어(웹캠, 마이크) 가져오기
        await setupLocalMedia();
        // 2. RTCPeerConnection 생성 및 설정
        createPeerConnection();
        // 3. 로컬 스트림을 PeerConnection에 추가
        if (!peerConnection || !localStream) {
            throw new Error("PeerConnection 또는 LocalStream 준비 안됨");
        }
        localStream.getTracks().forEach(track => peerConnection.addTrack(track, localStream));
        console.log('로컬 스트림 트랙 추가 완료');
        updateStatus(`로컬 미디어 준비 완료. 상대방(${remoteSessionId.substring(0, 5)}...)과 연결 중...`);

        // Impolite peer (세션 ID가 더 큰 쪽)가 먼저 Offer 생성 시도
        if (!isPolite) {
            console.log('Impolite peer: Offer 생성 시도');
            await makeOffer();
        }

    } catch (error) {
        console.error("매칭 후 미디어/PeerConnection 설정 오류:", error);
        updateStatus(`미디어 또는 연결 설정 중 오류 발생: ${error.message}`);
        hangUp(); // 설정 실패 시 연결 종료
    }
}


// --- WebRTC 로직 ---

// 1. 로컬 미디어 가져오기
async function setupLocalMedia() {
    try {
        const stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
        if (localVideo) { // localVideo 요소가 있는지 확인
            localVideo.srcObject = stream;
        } else {
            console.error("setupLocalMedia: localVideo 요소를 찾을 수 없습니다.");
            throw new Error("Local video element not found");
        }
        localStream = stream;
        console.log("로컬 미디어 스트림 획득 성공");
        // 마이크 음소거 버튼 활성화
        if (muteButton) muteButton.disabled = false;
    } catch (error) {
        console.error('getUserMedia() 오류:', error);
        // 사용자에게 더 친절한 메시지 표시
        if (error.name === 'NotAllowedError' || error.name === 'PermissionDeniedError') {
            updateStatus('웹캠/마이크 접근 권한이 필요합니다.');
        } else if (error.name === 'NotFoundError' || error.name === 'DevicesNotFoundError') {
            updateStatus('사용 가능한 웹캠/마이크 장치가 없습니다.');
        } else {
            updateStatus('웹캠/마이크 접근 실패: ' + error.message);
        }
        throw error; // 오류를 상위로 전파하여 hangUp() 호출 유도
    }
}

// 2. RTCPeerConnection 생성
function createPeerConnection() {
    // 이미 연결이 있다면 종료 후 새로 생성 (방어 코드)
    if (peerConnection) {
        console.warn("기존 PeerConnection이 존재하여 종료합니다.");
        peerConnection.close();
    }

    try {
        peerConnection = new RTCPeerConnection(pcConfig);
        console.log('RTCPeerConnection 생성됨:', pcConfig);

        // 이벤트 핸들러 설정
        peerConnection.onicecandidate = handleIceCandidateEvent;
        peerConnection.ontrack = handleTrackEvent;
        peerConnection.onconnectionstatechange = handleConnectionStateChangeEvent;
        peerConnection.onnegotiationneeded = handleNegotiationNeededEvent;

    } catch (error) {
        console.error("RTCPeerConnection 생성 실패:", error);
        updateStatus("WebRTC 연결 객체 생성 실패.");
        throw error; // 오류 전파
    }
}

// 이벤트 핸들러 함수 분리 (가독성 향상)
function handleIceCandidateEvent(event) {
    if (event.candidate) {
        console.log('ICE Candidate 생성:', event.candidate.candidate.substring(0, 40) + '...');
        sendMessage({ type: 'ice', candidate: event.candidate });
    } else {
        console.log('모든 ICE Candidate 생성 완료');
    }
}

function handleTrackEvent(event) {
    console.log('상대방 미디어 트랙 수신:', event.track, event.streams[0]);
    if (remoteVideo && remoteVideo.srcObject !== event.streams[0]) {
        remoteVideo.srcObject = event.streams[0];
        console.log('상대방 비디오 스트림 설정 완료');
        updateStatus('상대방 화면 연결 성공!');
    } else if (!remoteVideo) {
        console.error("handleTrackEvent: remoteVideo 요소를 찾을 수 없습니다.");
    }
}

function handleConnectionStateChangeEvent(event) {
    if (!peerConnection) return; // 이미 종료된 경우 무시
    console.log('PeerConnection 상태 변경:', peerConnection.connectionState);
    switch (peerConnection.connectionState) {
        case 'connected':
            console.log('PeerConnection 연결 성공!');
            // updateStatus('상대방과 연결되었습니다.'); // ontrack에서 이미 처리될 수 있음
            break;
        case 'disconnected':
            console.warn('PeerConnection 연결 끊김 (일시적일 수 있음)');
            updateStatus('연결이 일시적으로 끊겼습니다. 재연결 시도 중...');
            // 재연결 로직은 복잡하므로 여기서는 상태 알림만
            break;
        case 'failed':
            console.error('PeerConnection 연결 실패!');
            updateStatus('연결 실패.');
            // ICE Restart 등 고려 가능
            // hangUp(); // 실패 시 연결 종료
            break;
        case 'closed':
            console.log('PeerConnection 연결 종료됨.');
            // updateStatus('연결이 종료되었습니다.'); // closeConnection에서 처리
            break;
    }
}

async function handleNegotiationNeededEvent() {
    if (!peerConnection) return;
    console.log("onnegotiationneeded 이벤트 발생");
    try {
        // Offer 생성 경쟁 방지
        if (makingOffer || peerConnection.signalingState !== 'stable') {
            console.log(`onnegotiationneeded: 스킵 (makingOffer=${makingOffer}, state=${peerConnection.signalingState})`);
            return;
        }

        if (isPolite) {
            console.log("onnegotiationneeded: Polite peer는 Offer 생성을 상대에게 맡깁니다.");
            // 필요하다면 여기에 Offer 요청 메시지를 보내는 로직 추가 가능
        } else {
            console.log("onnegotiationneeded: Impolite peer가 Offer 생성을 시도합니다.");
            await makeOffer();
        }
    } catch (error) {
        console.error("Negotiation Needed 처리 중 오류:", error);
    }
}


// Offer 생성 및 전송
async function makeOffer() {
    if (!peerConnection) {
        console.error("makeOffer: PeerConnection 없음");
        return;
    }
    // 이미 Offer 교환 중이면 중단 (signalingState 확인)
    if (peerConnection.signalingState !== 'stable') {
        console.warn(`makeOffer: 잘못된 상태(${peerConnection.signalingState})에서는 Offer 생성 불가`);
        return;
    }

    makingOffer = true;
    console.log('Offer 생성 시작');
    try {
        const offer = await peerConnection.createOffer();
        // 생성된 Offer가 유효한지 확인 (setLocalDescription 전에)
        if (peerConnection.signalingState !== 'stable') {
            console.warn(`makeOffer: Offer 생성 후 상태 변경(${peerConnection.signalingState}), Offer 적용 취소`);
            makingOffer = false;
            return;
        }
        await peerConnection.setLocalDescription(offer);
        console.log('Local Description 설정 (Offer)'); // SDP 내용은 너무 길어서 로그 축소
        sendMessage({ type: 'offer', sdp: offer.sdp });
    } catch (error) {
        console.error('Offer 생성 또는 설정 실패:', error);
        updateStatus("연결 제안 생성 실패.");
    } finally {
        makingOffer = false;
    }
}

// Offer 수신 처리
async function handleOffer(message) {
    if (!peerConnection) {
        console.error('handleOffer: PeerConnection 없음');
        return; // PeerConnection 없으면 처리 불가
    }
    if (!message.sdp) {
        console.error("handleOffer: SDP 정보가 없는 Offer 메시지 수신");
        return;
    }

    console.log('Offer 수신'); // SDP 내용은 너무 길어서 로그 축소

    try {
        // Perfect Negotiation: Offer 충돌 처리
        const offerCollision = makingOffer || peerConnection.signalingState !== 'stable';
        const ignoreOffer = !isPolite && offerCollision;
        if (ignoreOffer) {
            console.log("Offer 충돌: Impolite peer가 수신된 Offer를 무시합니다.");
            return;
        }

        // Remote Description 설정 (Offer)
        await peerConnection.setRemoteDescription(new RTCSessionDescription({ type: 'offer', sdp: message.sdp }));
        console.log('Remote Description 설정 (Offer) 성공');

        // Answer 생성 및 설정
        const answer = await peerConnection.createAnswer();
        await peerConnection.setLocalDescription(answer);
        console.log('Local Description 설정 (Answer)'); // SDP 내용 로그 축소

        // Answer 전송
        sendMessage({ type: 'answer', sdp: answer.sdp });
        console.log('Answer 전송 완료');

    } catch (error) {
        console.error('Offer 처리 또는 Answer 생성 실패:', error);
        updateStatus("연결 제안 처리 실패.");
    }
}

// Answer 수신 처리
async function handleAnswer(message) {
    if (!peerConnection) {
        console.error('handleAnswer: PeerConnection 없음');
        return;
    }
    if (peerConnection.signalingState !== 'have-local-offer') {
        console.error(`Answer 수신: 잘못된 상태(${peerConnection.signalingState})`);
        return; // Local Offer를 보낸 상태가 아니면 Answer를 처리할 수 없음
    }
    if (!message.sdp) {
        console.error("handleAnswer: SDP 정보가 없는 Answer 메시지 수신");
        return;
    }

    console.log('Answer 수신'); // SDP 내용 로그 축소
    try {
        // Remote Description 설정 (Answer)
        await peerConnection.setRemoteDescription(new RTCSessionDescription({ type: 'answer', sdp: message.sdp }));
        console.log('Remote Description 설정 (Answer) 성공');
    } catch (error) {
        console.error('Answer 처리 실패:', error);
        updateStatus("연결 응답 처리 실패.");
    }
}

// ICE Candidate 수신 처리
async function handleIceCandidate(message) {
    if (!peerConnection) {
        console.warn('ICE Candidate 수신: PeerConnection 없음');
        return; // PeerConnection 없으면 처리 불가
    }
    if (!message.candidate) {
        console.warn('ICE Candidate 수신: Candidate 정보 없음');
        return; // Candidate 정보 없으면 처리 불가
    }

    console.log('ICE Candidate 수신:', message.candidate.candidate.substring(0,40) + '...');

    try {
        // Trickle ICE: Candidate를 받는 즉시 추가 시도
        // Remote Description이 설정되기 전이라도 추가 가능 (브라우저가 내부적으로 큐에 넣음)
        await peerConnection.addIceCandidate(new RTCIceCandidate(message.candidate));
        // console.log('ICE Candidate 추가 시도'); // 성공 로그는 불필요할 수 있음
    } catch (error) {
        // 이미 Remote Description 설정이 끝난 상태(stable)에서 Candidate 추가 실패는 무시 가능
        if (peerConnection.signalingState !== 'stable') {
            console.error('ICE Candidate 추가 실패:', error);
            // updateStatus("네트워크 경로 정보 추가 실패."); // 너무 빈번할 수 있어 주석 처리
        } else {
            // console.warn("Stable 상태에서 ICE Candidate 추가 오류 (무시 가능):", error.message);
        }
    }
}

// 연결 종료 처리 (상대방이 연결을 끊었을 때)
function handleHangup() {
    console.log('상대방이 연결을 종료했습니다.');
    updateStatus('상대방이 연결을 종료했습니다.');
    closeConnection();
}

// --- 메시지 전송 ---
function sendMessage(message) {
    // stompClient 존재 및 연결 상태, remoteSessionId 존재 여부 확인
    if (stompClient && stompClient.connected && remoteSessionId) {
        try {
            const destination = `/app/signal.${message.type}`;
            stompClient.send(destination, {}, JSON.stringify(message));
            // console.log(`메시지 전송 (${destination}):`, message.type); // 상세 로그 필요시
        } catch (error) {
            console.error(`메시지 전송 실패 (${message.type}):`, error);
        }
    } else {
        let reason = [];
        if (!stompClient) reason.push("stompClient 없음");
        else if (!stompClient.connected) reason.push("STOMP 연결 안됨");
        if (!remoteSessionId) reason.push("remoteSessionId 없음");
        console.warn(`메시지 전송 실패 (${message.type}): ${reason.join(', ')}`);
    }
}

// --- 연결 종료 ---
function hangUp() {
    console.log('연결 종료 시작...');
    // 연결된 상태에서만 hangup 메시지 전송 시도
    if (peerConnection && stompClient && stompClient.connected && remoteSessionId) {
        sendMessage({ type: 'hangup' }); // 상대방에게 종료 알림
    }
    closeConnection(); // 로컬 정리 작업 수행
}

// 실제 연결 정리 함수
function closeConnection() {
    console.log('연결 정리 중...');
    updateStatus('연결 종료됨.');

    // PeerConnection 종료
    if (peerConnection) {
        // 이벤트 핸들러 제거
        peerConnection.onicecandidate = null;
        peerConnection.ontrack = null;
        peerConnection.onconnectionstatechange = null;
        peerConnection.onnegotiationneeded = null;

        // Sender 트랙 중지 시도 (오류 발생 가능성 있음)
        try {
            peerConnection.getSenders().forEach(sender => {
                if (sender.track) {
                    sender.track.stop();
                }
            });
        } catch (error) {
            console.warn("Sender 트랙 중지 중 오류:", error);
        }

        // PeerConnection 닫기
        peerConnection.close();
        peerConnection = null;
        console.log('PeerConnection 종료됨.');
    } else {
        console.log("정리: PeerConnection 이미 null");
    }


    // 로컬 미디어 스트림 중지
    if (localStream) {
        localStream.getTracks().forEach(track => track.stop());
        localStream = null;
        if (localVideo) localVideo.srcObject = null; // 비디오 요소 초기화
        console.log('로컬 미디어 스트림 중지됨.');
    } else {
        console.log("정리: localStream 이미 null");
    }

    // 원격 비디오 초기화
    if (remoteVideo) remoteVideo.srcObject = null;

    // STOMP 연결 종료
    if (stompClient && stompClient.connected) {
        try {
            stompClient.disconnect(() => {
                console.log('STOMP 연결 해제 완료.');
                stompClient = null; // 연결 해제 후 null로 설정
            });
        } catch (error) {
            console.error("STOMP 연결 해제 중 오류:", error);
            stompClient = null; // 오류 발생 시에도 null 처리
        }
    } else {
        console.log("정리: stompClient 연결 안됨 또는 이미 null");
        stompClient = null; // 확실히 null 처리
    }

    // 상태 초기화
    localSessionId = null;
    remoteSessionId = null;
    isMuted = false;
    makingOffer = false;
    isPolite = false; // 상태 초기화 추가

    // 버튼 상태 초기화
    if (muteButton) {
        muteButton.textContent = '마이크 켜기';
        muteButton.disabled = true;
    }
    if (startButton) startButton.disabled = false;
    if (hangupButton) hangupButton.disabled = true;
    // 캡처 버튼 등 다른 UI 요소 초기화...
}


// --- 유틸리티 함수 ---

// 상태 메시지 업데이트
function updateStatus(message) {
    // statusDiv가 로드되었는지 확인 후 업데이트
    if (statusDiv) {
        statusDiv.textContent = message;
    } else {
        // statusDiv가 아직 없으면 (onload 전 호출 등) 콘솔에만 출력
        console.log("updateStatus (statusDiv 없음):", message);
    }
}

// 마이크 음소거/해제 토글
function toggleMute() {
    if (!localStream) {
        console.warn("toggleMute: 로컬 스트림 없음");
        return;
    }
    if (!muteButton) {
        console.error("toggleMute: 음소거 버튼 없음");
        return;
    }

    let audioEnabled = false;
    localStream.getAudioTracks().forEach(track => {
        track.enabled = !track.enabled; // 상태 토글
        audioEnabled = track.enabled; // 현재 상태 저장
    });

    isMuted = !audioEnabled; // isMuted는 오디오 비활성화 상태
    muteButton.textContent = isMuted ? '마이크 켜기' : '마이크 음소거';
    console.log(isMuted ? '마이크 음소거됨' : '마이크 켜짐');
}

// --- 이미지 캡처 (선택적) ---
function captureImage(videoElementId, imageElementId) {
    const video = document.getElementById(videoElementId);
    // 캔버스는 onload에서 찾지 않았으므로 여기서 찾거나, 미리 찾아둠
    const canvas = document.getElementById('captureCanvas');
    const image = document.getElementById(imageElementId);

    // 모든 요소가 존재하는지 확인
    if (!video || !video.srcObject || video.videoWidth === 0) {
        console.warn(`캡처 실패: 비디오(${videoElementId}) 준비 안됨`);
        return;
    }
    if (!canvas) {
        console.error("캡처 실패: captureCanvas 요소를 찾을 수 없음");
        return;
    }
    if (!image) {
        console.error(`캡처 실패: ${imageElementId} 요소를 찾을 수 없음`);
        return;
    }


    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    try {
        const ctx = canvas.getContext('2d');
        ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
        image.src = canvas.toDataURL('image/png');
        image.style.display = 'block';
    } catch (error) {
        console.error("이미지 캡처 중 오류:", error);
    }
}

function captureLocalImage() {
    captureImage('localVideo', 'capturedImageLocal');
}

function captureRemoteImage() {
    captureImage('remoteVideo', 'capturedImageRemote');
}

// --- 초기화 ---
// window.onload 는 위에서 정의됨