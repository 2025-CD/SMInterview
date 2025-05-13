// 'use strict';
//
// // --- 전역 변수 선언 (값 할당은 window.onload에서) ---
// let localVideo = null;
// let remoteVideo = null;
// let statusDiv = null;
// let startButton = null;
// let hangupButton = null;
// let muteButton = null;
// // 캡처 버튼 (선택적)
// // let captureLocalButton = null;
// // let captureRemoteButton = null;
// let stompClient = null;
// let localStream = null;
// let peerConnection = null;
// // let localSessionId = null; // 더 이상 매칭 관리에 직접 사용되지 않음
// let loggedInUserId = null; // 자신의 로그인 ID
// let remoteUserId = null; // 매칭된 상대방의 사용자 ID
// let isMuted = false;
// let makingOffer = false; // Offer 생성 경쟁 상태 방지 플래그
// // PeerConnection 협상 주도권 결정 (사용자 ID 비교 기반)
// // 세션 ID가 아닌 사용자 ID를 사용하므로 비교 기준 변경
// let isPolite = false; // Offer 생성 경쟁 시 누가 양보할지 결정 (사용자 ID 비교 기반)
//
// // --- WebRTC 설정 ---
// const pcConfig = {
//     'iceServers': [{
//         'urls': 'stun:stun.l.google.com:19302'
//     }]
// };
//
// // --- 초기화 및 DOM 요소 찾기 ---
// window.onload = () => {
//     console.log("window.onload: DOM 로드 완료됨."); // 디버깅 로그
//
//     // ▼▼▼ DOM 요소 찾는 코드를 여기로 이동 ▼▼▼
//     localVideo = document.getElementById('localVideo');
//     remoteVideo = document.getElementById('remoteVideo');
//     statusDiv = document.getElementById('status');
//     startButton = document.querySelector('button[onclick="startConnection()"]');
//     hangupButton = document.querySelector('button[onclick="hangUp()"]');
//     muteButton = document.getElementById('muteButton');
//     // captureLocalButton = document.querySelector('button[onclick="captureLocalImage()"]'); // 필요시 주석 해제
//     // captureRemoteButton = document.querySelector('button[onclick="captureRemoteImage()"]'); // 필요시 주석 해제
//
//     // 로그인 ID 가져오기 (여기서 하는 것이 안전)
//     // 주의: JSP의 body 태그에 data-userid="..." 로 설정했다고 가정
//     try {
//         loggedInUserId = document.body.dataset.userid;
//         console.log("onload: 가져온 로그인 ID:", loggedInUserId);
//         if (!loggedInUserId || loggedInUserId === 'null' || loggedInUserId === 'undefined') { // 로그인 안된 상태의 예외 처리 추가
//             console.error("onload: 로그인 ID를 data-userid 속성에서 찾을 수 없거나 유효하지 않습니다. 로그인이 필요합니다.");
//             updateStatus("로그인 정보를 찾을 수 없습니다. 로그인이 필요합니다."); // 사용자에게 알림
//             // 로그인 버튼 외 다른 버튼 비활성화 등 UI 처리 필요
//             if (startButton) startButton.disabled = true;
//             if (hangupButton) hangupButton.disabled = true;
//             if (muteButton) muteButton.disabled = true;
//             // capture buttons disabled
//             return; // 이후 코드 실행 중단
//         }
//     } catch (e) {
//         console.error("onload: 로그인 ID 가져오기 실패", e);
//         updateStatus("로그인 정보를 가져오는 중 오류 발생");
//         if (startButton) startButton.disabled = true;
//         if (hangupButton) hangupButton.disabled = true;
//         if (muteButton) muteButton.disabled = true;
//         // capture buttons disabled
//         return; // 이후 코드 실행 중단
//     }
//
//
//     // 요소들이 제대로 로드되었는지 확인 (디버깅용)
//     if (!localVideo) console.error("onload: localVideo 요소를 찾을 수 없습니다!");
//     if (!remoteVideo) console.error("onload: remoteVideo 요소를 찾을 수 없습니다!");
//     if (!statusDiv) console.error("onload: statusDiv 요소를 찾을 수 없습니다!");
//     if (!startButton) console.error("onload: startButton 요소를 찾을 수 없습니다!");
//     // hangupButton, muteButton은 없을 수도 있으니 null 체크
//     if (!hangupButton) console.warn("onload: hangupButton 요소를 찾을 수 없습니다!");
//     if (!muteButton) console.warn("onload: muteButton 요소를 찾을 수 없습니다!");
//
//
//     // 버튼 초기 상태 설정
//     // 요소가 null이 아닐 때만 disabled 속성 변경
//     if (startButton) startButton.disabled = false; // 로그인 ID가 있다면 시작 버튼 활성화
//     if (hangupButton) hangupButton.disabled = true;
//     if (muteButton) muteButton.disabled = true;
//     // if (captureLocalButton) captureLocalButton.disabled = true; // 필요시 주석 해제
//     // if (captureRemoteButton) captureRemoteButton.disabled = true; // 필요시 주석 해제
//
//     // 상태 초기 메시지
//     updateStatus(`${loggedInUserId}님, 연결 준비 중...`);
// };
//
//
// // --- WebSocket 및 STOMP 연결 ---
// function startConnection() {
//     // loggedInUserId는 이제 onload에서 설정되었으므로, 여기서는 유효성 재확인
//     if (!loggedInUserId || loggedInUserId === 'null' || loggedInUserId === 'undefined') {
//         updateStatus("로그인 정보가 없습니다. 먼저 로그인해주세요.");
//         console.error("startConnection: 로그인 ID 없음 또는 유효하지 않음.");
//         return; // 함수 실행 중단
//     }
//     // startButton도 onload에서 설정됨
//     if (!startButton) {
//         console.error("startConnection: 시작 버튼 없음 (페이지 로드 확인)");
//         updateStatus("시작 버튼을 찾을 수 없습니다.");
//         return;
//     }
//
//
//     updateStatus(`${loggedInUserId}님, 서버 연결 시도 중...`);
//     startButton.disabled = true; // 시작 버튼 비활성화
//
//     try {
//         // SockJS 및 STOMP 연결 시도
//         const socket = new SockJS('/signal'); // WebSocket EndPoint 주소
//         stompClient = Stomp.over(socket);
//         // 디버깅 메시지 끄기 (필요하면 주석 해제)
//         // stompClient.debug = null;
//
//         // connect 성공/실패 콜백 함수 지정
//         stompClient.connect({}, onWebSocketConnect, onWebSocketError);
//
//     } catch (error) {
//         console.error("SockJS 또는 STOMP 생성/연결 중 오류:", error);
//         updateStatus("서버 연결 중 오류 발생.");
//         if (startButton) startButton.disabled = false; // 오류 시 버튼 다시 활성화
//         // 필요하다면 hangupButton 등 다른 버튼 상태도 조절
//         if (hangupButton) hangupButton.disabled = true;
//         if (muteButton) muteButton.disabled = true;
//     }
// }
//
// function onWebSocketError(error) {
//     console.error("WebSocket 연결 오류:", error);
//     updateStatus('서버 연결 오류. 페이지를 새로고침하거나 다시 시도하세요.');
//     // 연결 실패 시 버튼 상태 초기화
//     if (startButton) startButton.disabled = false;
//     if (hangupButton) hangupButton.disabled = true;
//     if (muteButton) muteButton.disabled = true;
//
//     // 오류 발생 시 전역 변수 초기화 (새로운 연결 시도 대비)
//     stompClient = null;
//     peerConnection = null;
//     localStream = null;
//     // localSessionId = null; // 이제 사용 안 함
//     remoteUserId = null;
//     isMuted = false;
//     makingOffer = false;
//     isPolite = false;
// }
//
// // WebSocket 및 STOMP 연결 성공 시 호출
// function onWebSocketConnect(frame) { // connect 성공 시 frame 인자를 받을 수 있음
//     // STOMP 연결이 완전히 확립됨. 이 시점부터 메시지 송수신 가능.
//     console.log("WebSocket 및 STOMP 연결 성공:", frame);
//
//     // Spring에서 Principal이 설정되었다면 frame.headers.user-name에 사용자 ID가 담겨 올 수 있음
//     // 하지만 우리는 이미 localUserId를 가지고 있고, 서버는 Principal에서 ID를 얻으므로 클라이언트는 알 필요 없음.
//
//     // 더 이상 매칭 관리에 세션 ID를 직접 사용하지 않지만, 로그에 남기거나 특정 상황에 필요할 수는 있습니다.
//     // try {
//     //     const transportUrl = stompClient.ws._transport.url;
//     //     const urlParts = transportUrl.split('/');
//     //     localSessionId = urlParts[urlParts.length - 2];
//     //     console.log("내 세션 ID (참고용):", localSessionId);
//     // } catch (e) {
//     //     console.warn("세션 ID 추출 실패:", e);
//     //     // 심각한 오류는 아닐 수 있으므로 연결을 끊지는 않지만, 상황에 따라 처리 필요
//     // }
//
//     updateStatus(`${loggedInUserId}님, 서버 연결 완료. 매칭 대기 중...`);
//
//     try {
//         // 사용자별 개인 메시지 큐 구독
//         // 서버에서 convertAndSendToUser(userId, "/queue/signal", ...) 로 보낸 메시지를 받습니다.
//         // STOMP 명세에 따라 /user 접두사는 구독 시 자동으로 추가됩니다.
//         stompClient.subscribe('/user/queue/signal', onMessageReceived);
//         console.log("사용자별 메시지 큐 구독 완료: /user/queue/signal");
//
//
//         // 매칭 요청 메시지 전송
//         // 이제 사용자 ID를 메시지 내용에 담아 보냅니다.
//         // 서버는 이 메시지를 받고 Principal에서도 사용자 ID를 얻어 매칭 서비스에 전달합니다.
//         stompClient.send("/app/match.request", {}, JSON.stringify({ userId: loggedInUserId }));
//         console.log(`매칭 요청 전송: /app/match.request (User ID: ${loggedInUserId})`);
//
//         // 연결 성공 후 '연결 종료' 버튼 활성화
//         if (hangupButton) hangupButton.disabled = false;
//
//     } catch (error) {
//         console.error("STOMP 구독 또는 메시지 전송 중 오류:", error);
//         updateStatus("서버 통신 설정 중 오류 발생.");
//         hangUp(); // 에러 발생 시 정리하고 종료
//     }
// }
//
// // 서버로부터 메시지 수신 처리
// function onMessageReceived(payload) {
//     let message;
//     try {
//         message = JSON.parse(payload.body);
//         console.log("메시지 수신:", message);
//         // 메시지에 발신자(sender) 정보가 포함되어 있다면 활용 가능
//         // console.log("메시지 발신자 (상대방):", message.sender);
//     } catch (error) {
//         console.error("수신 메시지 JSON 파싱 오류:", error, payload.body);
//         return;
//     }
//
//
//     switch (message.type) {
//         case 'match_found':
//             // 매칭 성공 메시지에서 상대방의 사용자 ID를 받습니다.
//             handleMatchFound(message);
//             break;
//         case 'offer':
//             // Offer 메시지 처리
//             handleOffer(message); // Offer 메시지 자체에 SDP 정보 포함
//             break;
//         case 'answer':
//             // Answer 메시지 처리
//             handleAnswer(message); // Answer 메시지 자체에 SDP 정보 포함
//             break;
//         case 'ice':
//             // ICE Candidate 메시지 처리
//             handleIceCandidate(message); // ICE Candidate 정보 포함
//             break;
//         case 'hangup':
//             // 상대방 연결 종료 메시지 처리
//             handleHangup(message); // 누가 종료했는지 sender 정보 포함될 수 있음
//             break;
//         default:
//             console.warn("알 수 없는 메시지 유형:", message.type);
//     }
// }
//
// // --- 매칭 성공 처리 ---
// async function handleMatchFound(message) {
//     // 이제 메시지에서 상대방의 '사용자 ID'를 받습니다.
//     if (!message.partnerId) {
//         console.error("match_found 메시지에 partnerId(사용자 ID)가 없습니다.", message);
//         updateStatus("매칭 오류 발생 (상대방 사용자 정보 없음)");
//         hangUp(); // 오류 시 연결 종료
//         return;
//     }
//     remoteUserId = message.partnerId; // 매칭된 상대방 사용자 ID 저장
//     console.log(`매칭 성공! 상대방 사용자 ID: ${remoteUserId}`);
//     // 상태 메시지에 상대방 ID 표시
//     updateStatus(`매칭 성공! 상대방(${remoteUserId})과 연결 준비 중...`);
//
//     // 사용자 ID 문자열을 비교하여 Offer 생성 주도권 결정 (Polite/Impolite)
//     // 두 사용자 ID를 사전 순으로 비교하여 작은 쪽이 Polite
//     isPolite = loggedInUserId < remoteUserId;
//     console.log(`나는 ${isPolite ? 'polite' : 'impolite'} peer 입니다 (내 ID: ${loggedInUserId}, 상대 ID: ${remoteUserId}).`);
//
//
//     try {
//         // 1. 로컬 미디어(웹캠, 마이크) 가져오기
//         // 이 부분은 매칭 성공 후에 실행되는 것이 맞습니다.
//         await setupLocalMedia();
//         // 2. RTCPeerConnection 생성 및 설정
//         createPeerConnection();
//         // 3. 로컬 스트림을 PeerConnection에 추가
//         if (!peerConnection || !localStream) {
//             throw new Error("PeerConnection 또는 LocalStream 준비 안됨");
//         }
//         localStream.getTracks().forEach(track => {
//             // addTrack 전에 트랙 상태 확인 (선택적)
//             if (track.readyState === 'live') {
//                 peerConnection.addTrack(track, localStream);
//             } else {
//                 console.warn(`Track state is not 'live', skipping addTrack: ${track.kind}`);
//             }
//         });
//         console.log('로컬 스트림 트랙 추가 완료');
//         updateStatus(`로컬 미디어 준비 완료. 상대방(${remoteUserId})과 연결 중...`);
//
//         // Impolite peer (사용자 ID가 더 큰 쪽)가 먼저 Offer 생성 시도
//         // Perfect Negotiation 로직 (Impolite가 먼저 Offer 생성)
//         if (!isPolite) {
//             console.log('Impolite peer: Offer 생성 시도');
//             await makeOffer();
//         } else {
//             console.log('Polite peer: 상대방의 Offer를 기다립니다.');
//             // Polite peer는 onnegotiationneeded 이벤트에서 상대방 Offer 충돌 시 양보합니다.
//             // 또는, Impolite peer가 Offer를 보내지 않으면 일정 시간 후 Offer를 직접 생성 시도하는 로직 추가 가능 (복잡)
//         }
//
//     } catch (error) {
//         console.error("매칭 후 미디어/PeerConnection 설정 오류:", error);
//         updateStatus(`미디어 또는 연결 설정 중 오류 발생: ${error.message}`);
//         hangUp(); // 설정 실패 시 연결 종료
//     }
// }
//
//
// // --- WebRTC 로직 ---
//
// // 1. 로컬 미디어 가져오기
// async function setupLocalMedia() {
//     // localVideo가 있는지 다시 확인 (onload에서 실패했을 수도 있으므로)
//     if (!localVideo) {
//         console.error("setupLocalMedia: localVideo 요소를 찾을 수 없습니다.");
//         const error = new Error("Local video element not found");
//         updateStatus("로컬 비디오 요소를 찾을 수 없습니다.");
//         throw error; // 오류 전파
//     }
//
//     try {
//         // 사용자에게 카메라/마이크 접근 권한 요청
//         const stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
//
//         localVideo.srcObject = stream; // 로컬 비디오 요소에 스트림 연결
//         localStream = stream; // 전역 변수에 스트림 저장
//         console.log("로컬 미디어 스트림 획득 성공");
//
//         // 마이크 음소거 버튼 활성화 및 초기 상태 설정
//         if (muteButton) {
//             muteButton.disabled = false;
//             // 스트림에 오디오 트랙이 있는지 확인하여 isMuted 초기화
//             const audioTracks = localStream.getAudioTracks();
//             if (audioTracks.length > 0) {
//                 isMuted = !audioTracks[0].enabled; // 기본적으로 오디오 켜져 있으면 isMuted = false
//                 muteButton.textContent = isMuted ? '마이크 켜기' : '마이크 음소거';
//             } else {
//                 // 오디오 트랙이 없으면 음소거 버튼 비활성화
//                 if (muteButton) muteButton.disabled = true;
//                 console.warn("No audio track found in local stream. Mute button disabled.");
//             }
//         }
//
//
//     } catch (error) {
//         console.error('getUserMedia() 오류:', error);
//         // 사용자에게 더 친절한 메시지 표시
//         if (error.name === 'NotAllowedError' || error.name === 'PermissionDeniedError') {
//             updateStatus('웹캠/마이크 접근 권한이 필요합니다. 브라우저 설정에서 허용해주세요.');
//         } else if (error.name === 'NotFoundError' || error.name === 'DevicesNotFoundError') {
//             updateStatus('사용 가능한 웹캠/마이크 장치를 찾을 수 없습니다.');
//         } else {
//             updateStatus('웹캠/마이크 접근 실패: ' + error.message);
//         }
//         throw error; // 오류를 상위로 전파하여 hangUp() 호출 유도
//     }
// }
//
// // 2. RTCPeerConnection 생성
// function createPeerConnection() {
//     // 이미 연결이 있다면 종료 후 새로 생성 (방어 코드)
//     if (peerConnection) {
//         console.warn("기존 PeerConnection이 존재하여 종료합니다.");
//         peerConnection.close();
//     }
//
//     try {
//         // PeerConnection 객체 생성
//         peerConnection = new RTCPeerConnection(pcConfig);
//         console.log('RTCPeerConnection 생성됨:', pcConfig);
//
//         // --- 이벤트 핸들러 설정 ---
//         // ICE Candidate 생성 시
//         peerConnection.onicecandidate = handleIceCandidateEvent;
//         // 상대방 미디어 트랙 수신 시
//         peerConnection.ontrack = handleTrackEvent;
//         // PeerConnection 상태 변경 시
//         peerConnection.onconnectionstatechange = handleConnectionStateChangeEvent;
//         // 협상(Negotiation) 필요 시 (로컬 스트림 추가, 데이터 채널 생성 등)
//         peerConnection.onnegotiationneeded = handleNegotiationNeededEvent;
//         // 시그널링 상태 변경 시 (디버깅용)
//         peerConnection.onsignalingstatechange = handleSignalingStateChangeEvent;
//         // ICE 연결 상태 변경 시 (디버깅용)
//         peerConnection.oniceconnectionstatechange = handleIceConnectionStateChangeEvent;
//
//
//     } catch (error) {
//         console.error("RTCPeerConnection 생성 실패:", error);
//         updateStatus("WebRTC 연결 객체 생성 실패.");
//         throw error; // 오류 전파
//     }
// }
//
// // 이벤트 핸들러 함수 분리 (가독성 향상)
// function handleIceCandidateEvent(event) {
//     // event.candidate는 생성된 ICE 후보 정보입니다. 모든 후보 생성 후에는 null이 됩니다.
//     if (event.candidate) {
//         console.log('ICE Candidate 생성:', event.candidate.candidate ? event.candidate.candidate.substring(0, 40) + '...' : 'null'); // candidate 속성 존재 확인
//         // 생성된 ICE Candidate를 상대방에게 전달
//         sendMessage({ type: 'ice', candidate: event.candidate });
//     } else {
//         console.log('모든 ICE Candidate 생성 완료');
//     }
// }
//
// function handleTrackEvent(event) {
//     // 상대방으로부터 미디어 트랙(오디오/비디오)이 추가될 때 발생
//     console.log('상대방 미디어 트랙 수신:', event.track, event.streams[0]);
//     // remoteVideo 요소가 있는지 확인
//     if (!remoteVideo) {
//         console.error("handleTrackEvent: remoteVideo 요소를 찾을 수 없습니다.");
//         return; // 요소 없으면 처리 불가
//     }
//
//     // event.streams[0]는 해당 트랙이 속한 MediaStream입니다.
//     // 보통 처음 수신하는 스트림을 remoteVideo의 srcObject로 설정합니다.
//     // 이미 설정되어 있다면 (예: 오디오/비디오 트랙이 따로 올 경우) 다시 설정하지 않습니다.
//     if (remoteVideo.srcObject !== event.streams[0]) {
//         remoteVideo.srcObject = event.streams[0];
//         console.log('상대방 비디오 스트림 설정 완료');
//         updateStatus('상대방 화면 연결 성공!');
//     }
// }
//
// function handleConnectionStateChangeEvent(event) {
//     if (!peerConnection) {
//         console.log('PeerConnection 상태 변경 이벤트 발생했으나 PeerConnection이 null임.');
//         return; // 이미 종료된 경우 무시
//     }
//     console.log('PeerConnection 상태 변경:', peerConnection.connectionState);
//     // PeerConnection 연결 상태 변화에 따른 처리
//     switch (peerConnection.connectionState) {
//         case 'new':
//             console.log('PeerConnection 상태: New');
//             updateStatus('연결 초기화 중...');
//             break;
//         case 'connecting':
//             console.log('PeerConnection 상태: Connecting');
//             updateStatus('상대방과 연결 시도 중...');
//             break;
//         case 'connected':
//             console.log('PeerConnection 상태: Connected!');
//             updateStatus(`상대방(${remoteUserId})과 연결되었습니다.`);
//             // 연결 성공 시 UI 업데이트 (예: 대화 시작 알림, 버튼 상태 변경)
//             break;
//         case 'disconnected':
//             console.warn('PeerConnection 상태: Disconnected! (일시적일 수 있음)');
//             updateStatus('연결이 끊겼습니다. 재연결 시도 중...'); // 복구 로직 필요
//             // 재연결 로직은 복잡하므로 여기서는 상태 알림만
//             break;
//         case 'failed':
//             console.error('PeerConnection 상태: Failed! 연결 실패!');
//             updateStatus('연결 실패.');
//             hangUp(); // 실패 시 연결 종료 (ICE Restart 등 고려 가능)
//             break;
//         case 'closed':
//             console.log('PeerConnection 상태: Closed.');
//             // updateStatus('연결이 종료되었습니다.'); // closeConnection에서 처리
//             break;
//         default:
//             console.log('PeerConnection 상태: 알 수 없음 (' + peerConnection.connectionState + ')');
//             break;
//     }
// }
//
// function handleSignalingStateChangeEvent(event) {
//     if (!peerConnection) return; // 이미 종료된 경우 무시
//     console.log('PeerConnection 시그널링 상태 변경:', peerConnection.signalingState);
//     // 시그널링 상태 변화에 따른 처리 (협상 과정 디버깅)
//     switch (peerConnection.signalingState) {
//         case 'stable':
//             console.log('Signaling State: Stable (협상 완료 또는 필요 없음)');
//             makingOffer = false; // 안정 상태에서는 Offer 생성 경쟁 상태 해제
//             break;
//         case 'have-local-offer':
//             console.log('Signaling State: Have Local Offer (로컬 Offer 설정됨)');
//             break;
//         case 'have-remote-offer':
//             console.log('Signaling State: Have Remote Offer (원격 Offer 설정됨)');
//             break;
//         case 'have-local-pranswer':
//             console.log('Signaling State: Have Local Pranswer');
//             break;
//         case 'have-remote-pranswer':
//             console.log('Signaling State: Have Remote Pranswer');
//             break;
//         case 'closed':
//             console.log('Signaling State: Closed');
//             break;
//         default:
//             console.log('Signaling State: 알 수 없음 (' + peerConnection.signalingState + ')');
//             break;
//     }
// }
//
// function handleIceConnectionStateChangeEvent(event) {
//     if (!peerConnection) return; // 이미 종료된 경우 무시
//     console.log('PeerConnection ICE 연결 상태 변경:', peerConnection.iceConnectionState);
//     // ICE 연결 상태 변화에 따른 처리 (네트워크 연결 상태 디버깅)
//     switch (peerConnection.iceConnectionState) {
//         case 'new':
//             console.log('ICE Connection State: New');
//             break;
//         case 'checking':
//             console.log('ICE Connection State: Checking...');
//             updateStatus('최적의 연결 경로 찾는 중...');
//             break;
//         case 'connected':
//             console.log('ICE Connection State: Connected');
//             updateStatus('네트워크 연결 경로 찾음.');
//             break;
//         case 'completed':
//             console.log('ICE Connection State: Completed');
//             break;
//         case 'failed':
//             console.error('ICE Connection State: Failed!');
//             updateStatus('네트워크 연결 경로 찾기 실패.');
//             break;
//         case 'disconnected':
//             console.warn('ICE Connection State: Disconnected!');
//             updateStatus('네트워크 연결 끊김.');
//             break;
//         case 'closed':
//             console.log('ICE Connection State: Closed');
//             break;
//         default:
//             console.log('ICE Connection State: 알 수 없음 (' + peerConnection.iceConnectionState + ')');
//             break;
//     }
// }
//
//
// // 협상 필요 이벤트 핸들러 (Perfect Negotiation 패턴 구현)
// async function handleNegotiationNeededEvent() {
//     if (!peerConnection) return; // PeerConnection 없으면 무시
//     console.log("onnegotiationneeded 이벤트 발생");
//     try {
//         // Offer 생성 경쟁 상태 방지 및 시그널링 상태 확인
//         // makingOffer 플래그: 이미 Offer 생성 중이면 다시 시도하지 않음
//         // signalingState !== 'stable': Offer/Answer 교환 등 시그널링 과정 중이면 다시 시도하지 않음
//         if (makingOffer || peerConnection.signalingState !== 'stable') {
//             console.log(`onnegotiationneeded: 스킵 (makingOffer=${makingOffer}, state=${peerConnection.signalingState})`);
//             return;
//         }
//
//         // Polite/Impolite 패턴 적용:
//         // Polite peer (사용자 ID 작은 쪽)는 onnegotiationneeded가 발생해도 즉시 Offer를 만들지 않고
//         // Impolite peer가 먼저 Offer를 만들기를 기다립니다.
//         // 만약 Impolite peer가 Offer를 보냈는데 Offer 충돌이 발생하면 Impolite peer가 양보하고,
//         // Polite peer는 수신된 Offer를 처리합니다.
//         // 이 로직은 handleOffer 함수에서 Offer 충돌 시 처리됩니다.
//         // 여기서는 Impolite peer만 onnegotiationneeded 시 Offer를 생성하도록 합니다.
//         if (!isPolite) {
//             console.log("onnegotiationneeded: Impolite peer가 Offer 생성을 시도합니다.");
//             await makeOffer();
//         } else {
//             console.log("onnegotiationneeded: Polite peer는 Impolite peer가 Offer를 만들기를 기다립니다.");
//         }
//     } catch (error) {
//         console.error("Negotiation Needed 처리 중 오류:", error);
//         // 오류 발생 시 연결 종료 고려
//         // hangUp();
//     }
// }
//
//
// // Offer 생성 및 전송
// async function makeOffer() {
//     if (!peerConnection) {
//         console.error("makeOffer: PeerConnection 없음");
//         updateStatus("PeerConnection 객체가 준비되지 않았습니다.");
//         return;
//     }
//     // 시그널링 상태가 stable이 아닐 때는 Offer를 만들면 안 됩니다.
//     // Perfect Negotiation 패턴에서 makingOffer 플래그와 함께 사용됩니다.
//     if (peerConnection.signalingState !== 'stable') {
//         console.warn(`makeOffer: 현재 시그널링 상태(${peerConnection.signalingState})에서는 Offer 생성 불가.`);
//         return;
//     }
//
//     makingOffer = true; // Offer 생성 시작 플래그 설정
//     console.log('Offer 생성 시작');
//     updateStatus('연결 제안(Offer) 생성 중...');
//
//     try {
//         // RTCPeerConnection의 createOffer 메소드로 Offer SDP 생성
//         const offer = await peerConnection.createOffer();
//
//         // 생성된 Offer가 유효한지 확인 (setLocalDescription 전에)
//         // createOffer와 setLocalDescription 사이에 시그널링 상태가 변할 수 있습니다.
//         if (peerConnection.signalingState !== 'stable') {
//             console.warn(`makeOffer: Offer 생성 후 상태 변경(${peerConnection.signalingState}), Offer 적용 취소`);
//             makingOffer = false;
//             return; // 상태가 변했으면 현재 Offer는 무효
//         }
//
//
//         // 생성된 Offer를 로컬 설명으로 설정
//         await peerConnection.setLocalDescription(offer);
//         console.log('Local Description 설정 (Offer)'); // SDP 내용은 너무 길어서 로그 축소
//
//         // 로컬 Offer 정보를 상대방에게 전송 (시그널링 서버 이용)
//         // 메시지 유형을 'offer'로 설정하고, SDP 정보를 담아 보냅니다.
//         sendMessage({ type: 'offer', sdp: offer.sdp });
//         console.log('Offer 메시지 전송 완료');
//
//     } catch (error) {
//         console.error('Offer 생성 또는 설정 실패:', error);
//         updateStatus("연결 제안 생성 실패.");
//         // 오류 발생 시 연결 종료 고려
//         // hangUp();
//     } finally {
//         makingOffer = false; // Offer 생성 종료 플래그 해제
//     }
// }
//
// // Offer 수신 처리
// async function handleOffer(message) {
//     if (!peerConnection) {
//         console.error('handleOffer: PeerConnection 없음');
//         updateStatus("PeerConnection 객체가 준비되지 않았습니다.");
//         // PeerConnection이 없으면 Offer를 처리할 수 없으므로 연결 종료 고려
//         hangUp();
//         return;
//     }
//     if (!message.sdp) {
//         console.error("handleOffer: SDP 정보가 없는 Offer 메시지 수신");
//         // 유효하지 않은 메시지 수신 시 연결 종료 고려
//         // hangUp();
//         return;
//     }
//
//     console.log('Offer 수신'); // SDP 내용은 너무 길어서 로그 축소
//     updateStatus('연결 제안(Offer) 수신.');
//
//     try {
//         // Perfect Negotiation 패턴: Offer 충돌 처리
//         // Impolite peer가 Offer를 만들고 있는데 Polite peer로부터 Offer가 온 경우 (충돌)
//         // 또는 시그널링 상태가 stable이 아닌 경우 (이미 다른 협상 진행 중)
//         const offerCollision = makingOffer || peerConnection.signalingState !== 'stable';
//         // Polite peer가 아니면서 Offer 충돌이 발생한 경우, 수신된 Offer를 무시합니다.
//         // (Impolite peer는 자신의 Offer가 먼저라고 간주하고 계속 진행)
//         const ignoreOffer = !isPolite && offerCollision;
//         if (ignoreOffer) {
//             console.log("Offer 충돌 감지: Impolite peer가 수신된 Offer를 무시합니다.");
//             return; // Offer 처리 중단
//         }
//
//         // Offer 메시지로부터 받은 SDP 정보를 원격 설명으로 설정
//         // new RTCSessionDescription({ type: 'offer', sdp: message.sdp }) 객체 생성
//         await peerConnection.setRemoteDescription(new RTCSessionDescription({ type: 'offer', sdp: message.sdp }));
//         console.log('Remote Description 설정 (Offer) 성공');
//         updateStatus('원격 설명 설정 완료.');
//
//         // 원격 Offer를 설정했으므로, 이에 대한 응답(Answer) 생성
//         const answer = await peerConnection.createAnswer();
//         console.log('Answer 생성');
//         updateStatus('연결 응답(Answer) 생성 중...');
//
//         // 생성된 Answer를 로컬 설명으로 설정
//         await peerConnection.setLocalDescription(answer);
//         console.log('Local Description 설정 (Answer)'); // SDP 내용 로그 축소
//
//         // 로컬 Answer 정보를 상대방에게 전송 (시그널링 서버 이용)
//         sendMessage({ type: 'answer', sdp: answer.sdp });
//         console.log('Answer 전송 완료');
//         updateStatus('연결 응답(Answer) 전송 완료.');
//
//     } catch (error) {
//         console.error('Offer 처리 또는 Answer 생성 실패:', error);
//         updateStatus("연결 제안 처리 실패.");
//         // 오류 발생 시 연결 종료 고려
//         // hangUp();
//     }
// }
//
// // Answer 수신 처리
// async function handleAnswer(message) {
//     if (!peerConnection) {
//         console.error('handleAnswer: PeerConnection 없음');
//         updateStatus("PeerConnection 객체가 준비되지 않았습니다.");
//         // PeerConnection 없으면 Answer를 처리할 수 없으므로 연결 종료 고려
//         hangUp();
//         return;
//     }
//     // Answer는 Offer를 보낸 상태(have-local-offer)에서만 받아야 정상입니다.
//     if (peerConnection.signalingState !== 'have-local-offer') {
//         console.error(`Answer 수신: 잘못된 시그널링 상태(${peerConnection.signalingState}). Answer를 처리할 수 없습니다.`);
//         // 잘못된 상태의 Answer 수신 시 무시하거나 연결 종료 고려
//         // hangUp();
//         return;
//     }
//     if (!message.sdp) {
//         console.error("handleAnswer: SDP 정보가 없는 Answer 메시지 수신");
//         // 유효하지 않은 메시지 수신 시 연결 종료 고려
//         // hangUp();
//         return;
//     }
//
//     console.log('Answer 수신'); // SDP 내용 로그 축소
//     updateStatus('연결 응답(Answer) 수신.');
//
//     try {
//         // Answer 메시지로부터 받은 SDP 정보를 원격 설명으로 설정
//         // new RTCSessionDescription({ type: 'answer', sdp: message.sdp }) 객체 생성
//         await peerConnection.setRemoteDescription(new RTCSessionDescription({ type: 'answer', sdp: message.sdp }));
//         console.log('Remote Description 설정 (Answer) 성공');
//         updateStatus('원격 설명 설정 완료.');
//
//     } catch (error) {
//         console.error('Answer 처리 실패:', error);
//         updateStatus("연결 응답 처리 실패.");
//         // 오류 발생 시 연결 종료 고려
//         // hangUp();
//     }
// }
//
// // ICE Candidate 수신 처리
// async function handleIceCandidate(message) {
//     if (!peerConnection) {
//         console.warn('ICE Candidate 수신: PeerConnection 없음. Candidate를 추가할 수 없습니다.');
//         // PeerConnection 없으면 Candidate를 추가할 수 없으므로 무시
//         return;
//     }
//     if (!message.candidate) {
//         console.warn('ICE Candidate 수신: Candidate 정보 없음.');
//         // Candidate 정보 없으면 무시
//         return;
//     }
//
//     console.log('ICE Candidate 수신:', message.candidate.candidate ? message.candidate.candidate.substring(0,40) + '...' : 'null');
//     // updateStatus('네트워크 정보 수신.'); // 너무 빈번할 수 있어 상태 업데이트는 생략
//
//     try {
//         // Trickle ICE: Candidate를 받는 즉시 PeerConnection에 추가 시도
//         // addIceCandidate 메소드는 비동기이며, Remote Description이 설정되기 전이라도 호출 가능합니다.
//         // 브라우저가 내부적으로 Remote Description 설정될 때까지 Candidate를 큐에 넣어둡니다.
//         await peerConnection.addIceCandidate(new RTCIceCandidate(message.candidate));
//         // console.log('ICE Candidate 추가 시도 성공'); // 성공 로그는 너무 빈번할 수 있음
//     } catch (error) {
//         // ICE Candidate 추가 실패 시 처리
//         // peerConnection.signalingState가 'stable' 상태에서 Candidate 추가 실패는 무시 가능 (이미 협상 완료)
//         // 그 외 상태에서의 실패는 문제일 수 있음
//         if (peerConnection.signalingState !== 'closed') { // 연결이 닫힌 상태가 아니면 오류 처리
//             console.error('ICE Candidate 추가 실패:', error);
//             // updateStatus("네트워크 경로 정보 추가 실패."); // 너무 빈번할 수 있어 주석 처리
//         } else {
//             // console.warn("Closed 상태에서 ICE Candidate 추가 오류 (무시됨):", error.message);
//         }
//     }
// }
//
// // 연결 종료 처리 (상대방이 연결을 끊었을 때 또는 서버에서 끊김 알림 시)
// function handleHangup(message) {
//     // 누가 연결을 끊었는지 메시지에서 확인 가능 (message.sender 사용)
//     const hangupSenderId = message && message.sender ? message.sender : '상대방';
//     console.log(`${hangupSenderId}가 연결을 종료했습니다.`);
//     updateStatus(`${hangupSenderId}가 연결을 종료했습니다.`);
//
//     closeConnection(); // 로컬 정리 작업 수행
// }
//
// // --- 메시지 전송 ---
// // 이 함수는 시그널링 메시지를 서버로 전송합니다.
// // 서버는 메시지 타입과 현재 사용자의 Principal (사용자 ID)을 보고
// // matchingService를 통해 상대방 사용자 ID를 찾은 후, convertAndSendToUser로 라우팅합니다.
// function sendMessage(message) {
//     // stompClient 존재 및 연결 상태, 그리고 매칭된 상대방 사용자 ID가 있는지 확인
//     // 매칭 전에는 Offer/Answer/ICE 메시지를 보내면 안 됩니다.
//     if (stompClient && stompClient.connected && remoteUserId) {
//         try {
//             const destination = `/app/signal.${message.type}`; // 서버의 @MessageMapping 주소
//
//             // 메시지에 발신자 (자신의 사용자 ID) 정보를 명시적으로 추가 (선택적이지만 유용)
//             // 서버에서는 Principal을 통해 발신자를 알지만, 메시지 내용 자체에 포함시키면 디버깅이나 클라이언트 처리 시 편리합니다.
//             message.sender = loggedInUserId;
//             message.receiver = remoteUserId; // 메시지 내용에 수신자 정보도 포함
//
//             stompClient.send(destination, {}, JSON.stringify(message));
//             // console.log(`메시지 전송 (${destination}) 성공:`, message.type); // 상세 로그 필요시
//
//         } catch (error) {
//             console.error(`메시지 전송 실패 (${message.type}):`, error);
//             // 메시지 전송 실패 시 연결 종료 고려
//             // hangUp();
//         }
//     } else {
//         let reason = [];
//         if (!stompClient || !stompClient.connected) reason.push("STOMP 연결 안됨");
//         if (!remoteUserId) reason.push("매칭된 상대방 없음");
//         console.warn(`메시지 전송 실패 (${message.type}): ${reason.join(', ')}. 메시지 내용:`, message);
//         // 매칭 전 시그널 메시지 전송 시도 발생 가능성 있음.
//         // 또는 연결이 이미 끊겼는데 메시지 전송 시도.
//     }
// }
//
// // --- 연결 종료 ---
// function hangUp() {
//     console.log('연결 종료 시작...');
//     // 상태 메시지 업데이트
//     updateStatus('연결 종료 중...');
//
//     // 연결된 상태이고 상대방이 있을 경우에만 'hangup' 메시지 전송 시도
//     // remoteUserId가 null이 아니면 매칭이 되었었다는 의미
//     if (stompClient && stompClient.connected && remoteUserId) {
//         // 서버에 명시적으로 연결 종료 메시지 전송
//         // 서버는 이 메시지를 받고 matchingService에서 사용자 제거 및 상대방에게 알림
//         sendMessage({ type: 'hangup' });
//         console.log('Hangup 메시지 전송 완료');
//     } else {
//         console.log('Hangup 메시지 전송 스킵: STOMP 연결 안되거나 매칭 상대 없음.');
//     }
//
//     // 로컬 정리 작업 수행 (PeerConnection, Stream 등 해제)
//     closeConnection();
// }
//
// // 실제 연결 정리 함수
// function closeConnection() {
//     console.log('연결 정리 중...');
//     updateStatus('연결 종료됨.'); // 정리 시작 상태
//
//     // PeerConnection 객체 정리
//     if (peerConnection) {
//         console.log('PeerConnection 객체 정리 시작...');
//         // 이벤트 핸들러 제거 (메모리 누수 방지)
//         peerConnection.onicecandidate = null;
//         peerConnection.ontrack = null;
//         peerConnection.onconnectionstatechange = null;
//         peerConnection.onnegotiationneeded = null;
//         peerConnection.onsignalingstatechange = null;
//         peerConnection.oniceconnectionstatechange = null;
//
//         // Sender 트랙 중지 (미디어 장치 해제)
//         try {
//             // getSenders()는 PeerConnection에 추가된 모든 RTCRtpSender 객체 목록을 반환
//             // 각 Sender는 연결에 보내는 트랙(오디오, 비디오 등)을 관리합니다.
//             peerConnection.getSenders().forEach(sender => {
//                 if (sender.track) {
//                     console.log('Stopping sender track:', sender.track.kind);
//                     sender.track.stop(); // 트랙 중지 (카메라/마이크 해제)
//                     // 트랙이 중지되면 PeerConnection에서도 자동으로 제거되거나,
//                     // 명시적으로 removeTrack(sender) 호출 가능 (보통 stop()만으로 충분)
//                 }
//             });
//             console.log('PeerConnection sender tracks stopped.');
//         } catch (error) {
//             // getSenders()가 아직 준비되지 않았거나 다른 이유로 오류 발생 가능
//             console.warn("PeerConnection sender 트랙 중지 중 오류:", error);
//             // 로컬 스트림이 있다면 그쪽에서 트랙을 중지하는 것이 더 확실할 수 있습니다.
//         }
//
//
//         // PeerConnection 닫기
//         peerConnection.close();
//         peerConnection = null; // 참조 해제
//         console.log('PeerConnection 종료됨.');
//     } else {
//         console.log("정리: PeerConnection 이미 null");
//     }
//
//     // 로컬 미디어 스트림 중지 (카메라/마이크 명시적 해제)
//     // localStream이 PeerConnection에 추가된 트랙들의 소스이므로 여기서 중지하는 것이 중요
//     if (localStream) {
//         console.log('로컬 미디어 스트림 중지 시작...');
//         localStream.getTracks().forEach(track => {
//             console.log('Stopping local stream track:', track.kind);
//             track.stop(); // 트랙 중지 (카메라/마이크 LED 꺼짐)
//         });
//         localStream = null; // 참조 해제
//         // 로컬 비디오 요소의 srcObject 초기화
//         if (localVideo) localVideo.srcObject = null;
//         console.log('로컬 미디어 스트림 중지 완료.');
//     } else {
//         console.log("정리: localStream 이미 null");
//     }
//
//     // 원격 비디오 요소 초기화 (상대방 화면 지우기)
//     if (remoteVideo) remoteVideo.srcObject = null;
//     console.log('원격 비디오 요소 초기화.');
//
//     // STOMP 연결 종료
//     if (stompClient && stompClient.connected) {
//         console.log('STOMP 연결 해제 시작...');
//         try {
//             // STOMP 연결 해제 메시지 전송 후 콜백 실행
//             stompClient.disconnect(() => {
//                 console.log('STOMP 연결 해제 완료.');
//                 stompClient = null; // 연결 해제 후 참조 해제
//             });
//         } catch (error) {
//             // disconnect 중 오류 발생 시 (예: 이미 연결 끊김)
//             console.error("STOMP 연결 해제 중 오류:", error);
//             stompClient = null; // 오류 발생 시에도 참조 해제
//         }
//     } else {
//         console.log("정리: stompClient 연결 안됨 또는 이미 null");
//         stompClient = null; // 확실히 null 처리
//     }
//
//     // 전역 변수 상태 초기화
//     // localSessionId = null; // 이제 사용 안 함
//     remoteUserId = null; // 상대방 사용자 ID 초기화
//     isMuted = false;
//     makingOffer = false;
//     isPolite = false; // 상태 초기화 추가
//
//     // 버튼 상태 초기화
//     if (muteButton) {
//         muteButton.textContent = '마이크 켜기';
//         muteButton.disabled = true; // 스트림 없으면 비활성화
//     }
//     if (startButton) startButton.disabled = false; // 시작 버튼 다시 활성화
//     if (hangupButton) hangupButton.disabled = true; // 종료 버튼 비활성화
//     // 캡처 버튼 등 다른 UI 요소 초기화...
//
//     console.log('연결 정리 완료.');
//     updateStatus('연결이 완전히 종료되었습니다.'); // 최종 상태 업데이트
// }
//
//
// // --- 유틸리티 함수 ---
//
// // 상태 메시지 업데이트
// function updateStatus(message) {
//     // statusDiv가 로드되었는지 확인 후 업데이트
//     if (statusDiv) {
//         statusDiv.textContent = message;
//     } else {
//         // statusDiv가 아직 없으면 (onload 전 호출 등) 콘솔에만 출력
//         console.log("updateStatus (statusDiv 없음):", message);
//     }
// }
//
// // 마이크 음소거/해제 토글
// function toggleMute() {
//     if (!localStream) {
//         console.warn("toggleMute: 로컬 스트림 없음");
//         updateStatus("로컬 스트림이 준비되지 않았습니다.");
//         return;
//     }
//     if (!muteButton) {
//         console.error("toggleMute: 음소거 버튼 요소를 찾을 수 없습니다.");
//         return;
//     }
//
//     let audioTracks = localStream.getAudioTracks();
//     if (audioTracks.length === 0) {
//         console.warn("toggleMute: 로컬 스트림에 오디오 트랙이 없습니다.");
//         updateStatus("로컬 스트림에 오디오 트랙이 없습니다.");
//         if (muteButton) muteButton.disabled = true;
//         return;
//     }
//
//     audioTracks.forEach(track => {
//         track.enabled = !track.enabled; // 현재 상태의 반대로 설정 (토글)
//     });
//
//     // isMuted 상태 업데이트 (audioTracks[0].enabled의 반대)
//     isMuted = !audioTracks[0].enabled;
//
//     muteButton.textContent = isMuted ? '마이크 켜기' : '마이크 음소거';
//     console.log(isMuted ? '마이크 음소거됨' : '마이크 켜짐');
// }
//
// // --- 이미지 캡처 (선택적) ---
// // 기존 코드와 동일
// function captureImage(videoElementId, imageElementId) {
//     const video = document.getElementById(videoElementId);
//     const canvas = document.getElementById('captureCanvas');
//     const image = document.getElementById(imageElementId);
//
//     if (!video || !video.srcObject || video.videoWidth === 0) {
//         console.warn(`캡처 실패: 비디오(${videoElementId}) 준비 안됨`);
//         return;
//     }
//     if (!canvas) {
//         console.error("캡처 실패: captureCanvas 요소를 찾을 수 없음");
//         return;
//     }
//     if (!image) {
//         console.error(`캡처 실패: ${imageElementId} 요소를 찾을 수 없음`);
//         return;
//     }
//
//     canvas.width = video.videoWidth;
//     canvas.height = video.videoHeight;
//     try {
//         const ctx = canvas.getContext('2d');
//         ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
//         image.src = canvas.toDataURL('image/png');
//         image.style.display = 'block';
//     } catch (error) {
//         console.error("이미지 캡처 중 오류:", error);
//     }
// }
//
// function captureLocalImage() {
//     captureImage('localVideo', 'capturedImageLocal');
// }
//
// function captureRemoteImage() {
//     captureImage('remoteVideo', 'capturedImageRemote');
// }
//
// // --- 초기화 ---
// // window.onload 는 위에서 정의됨