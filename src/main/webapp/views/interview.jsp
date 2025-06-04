<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>WebRTC 화면 공유 및 회의 녹화 예제</title>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>

    <style>
        body {
            font-family: 'Malgun Gothic', '맑은 고딕', Arial, sans-serif;
            background-color: #f4f6f9;
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center; /* 전체 콘텐츠 중앙 정렬 */
            min-height: 100vh; /* 최소 높이 설정 */
            box-sizing: border-box; /* 패딩 포함 계산 */
        }

        /* 메인 레이아웃 컨테이너 */
        .main-layout-container {
            display: flex;
            flex-direction: row; /* 비디오와 채팅을 가로로 배치 */
            width: 100%;
            max-width: 1600px; /* 전체 레이아웃의 최대 너비 */
            gap: 20px; /* 비디오 영역과 채팅 영역 사이 간격 */
        }

        /* 비디오 메인 영역 (컨트롤 + 비디오) */
        .video-main-area {
            flex-grow: 1; /* 남은 공간을 모두 차지 */
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 20px; /* 컨트롤과 비디오 컨테이너 사이 간격 */
        }

        #controls {
            background: #fff;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            display: flex;
            align-items: center;
            gap: 10px;
            width: 100%; /* 비디오 영역의 너비에 맞춤 */
            max-width: 900px; /* 너무 커지지 않도록 제한 */
            flex-wrap: wrap;
            justify-content: center;
        }

        input[type="number"], input[type="text"] {
            padding: 8px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 4px;
            flex-grow: 1;
            max-width: 150px;
            min-width: 100px;
        }

        button {
            padding: 8px 15px;
            font-size: 15px;
            border: none;
            background-color: #007bff;
            color: white;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.2s ease;
            white-space: nowrap;
        }

        button:hover:not(:disabled) {
            background-color: #0056b3;
        }

        button:disabled {
            background-color: #999;
            cursor: not-allowed;
            opacity: 0.7;
        }

        #videoContainer {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            justify-content: center; /* 비디오들 중앙 정렬 */
            width: 100%;
            /* min-height: 500px; /* 비디오 컨테이너 최소 높이 (필요시 조절) */
            align-items: center; /* 비디오들 세로 중앙 정렬 */
        }

        .video-wrapper {
            position: relative;
            margin: 0; /* margin 제거, gap으로 처리 */
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            background: #222;
            display: flex;
            justify-content: center;
            align-items: center;
            border: 2px solid transparent;
        }

        /* 로컬 비디오 (메인 화면) */
        #localWrapper {
            width: 800px; /* 로컬 비디오의 기본 너비 */
            height: 450px; /* 16:9 비율 유지 */
            max-width: calc(100% - 40px); /* 패딩 고려 */
            max-height: calc(100vh - 200px); /* 전체 높이 고려 */
        }

        /* 원격 비디오 (작게 여러 개) */
        #remoteStreamDiv .video-wrapper {
            width: 240px; /* 원격 비디오의 너비 */
            height: 180px; /* 4:3 비율 또는 원하는 비율 */
        }

        .video-wrapper.highlight {
            border-color: #007bff;
        }

        .video-wrapper video {
            display: block;
            width: 100%;
            height: 100%;
            object-fit: contain;
            background-color: black;
        }

        .label {
            position: absolute;
            top: 8px;
            left: 8px;
            background: rgba(0,0,0,0.7);
            color: white;
            padding: 4px 8px;
            font-size: 13px;
            border-radius: 4px;
            font-weight: bold;
        }

        /* 채팅 사이드바 */
        #chatContainer {
            width: 350px; /* 채팅창 고정 너비 */
            flex-shrink: 0; /* 공간이 부족해도 줄어들지 않음 */
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            padding: 15px;
            display: flex;
            flex-direction: column;
            height: calc(100vh - 40px); /* 뷰포트 높이에서 body padding 제외 */
            box-sizing: border-box; /* 패딩 포함 계산 */
        }

        #chatBox {
            border: 1px solid #ddd;
            padding: 10px;
            flex-grow: 1; /* 남은 공간을 모두 차지하여 세로로 늘어남 */
            overflow-y: auto;
            margin-bottom: 10px;
            border-radius: 4px;
            background-color: #f9f9f9;
            display: flex;
            flex-direction: column;
        }

        .chat-message-wrapper {
            display: flex;
            margin-bottom: 8px;
        }

        .chat-message {
            max-width: 70%;
            padding: 8px 12px;
            border-radius: 18px;
            font-size: 14px;
            word-wrap: break-word;
            line-height: 1.4;
            box-shadow: 0 1px 1px rgba(0,0,0,0.08);
            white-space: pre-wrap;
        }

        .chat-message strong {
            display: block;
            font-size: 12px;
            margin-bottom: 4px;
            color: #555;
        }

        /* 내가 보낸 메시지 스타일 */
        .my-message-wrapper {
            justify-content: flex-end;
        }

        .my-message {
            background-color: #dcf8c6;
            color: #333;
        }

        .my-message strong {
            text-align: right;
            color: #007bff;
        }

        /* 상대방이 보낸 메시지 스타일 */
        .other-message-wrapper {
            justify-content: flex-start;
        }

        .other-message {
            background-color: #e2e2e2;
            color: #333;
        }

        .other-message strong {
            text-align: left;
            color: #666;
        }

        .chat-input-area {
            display: flex;
            gap: 10px;
        }

        #chatInput {
            flex-grow: 1;
            max-width: none;
            min-width: 50px;
        }

        /* 반응형 디자인을 위한 미디어 쿼리 */
        @media (max-width: 1024px) {
            .main-layout-container {
                flex-direction: column; /* 작은 화면에서는 세로로 쌓이도록 */
            }
            #chatContainer {
                width: 100%; /* 전체 너비 차지 */
                height: 300px; /* 채팅창 높이 고정 */
            }
            #localWrapper {
                width: 100%; /* 화면 너비에 맞춤 */
                height: auto;
                max-width: none;
            }
        }
    </style>
</head>
<body>

<div class="main-layout-container">

    <div class="video-main-area">
        <div id="controls">
            <input type="number" id="roomIdInput" placeholder="방 번호 입력" min="1000" max="9999" />
            <button type="button" id="enterRoomBtn">방 참여</button>
            <button type="button" id="startSteamBtn" style="display: none;">스트림 시작</button>
            <button type="button" id="startRecordBtn" style="display: none;">녹화 시작</button>
            <button type="button" id="stopRecordBtn" style="display: none;" disabled>녹화 끝</button>
        </div>

        <div id="videoContainer">
            <div class="video-wrapper" id="localWrapper" style="display: none;">
                <video id="localStream" autoplay playsinline muted controls></video>
                <div class="label">내 화면</div>
            </div>

            <div id="remoteStreamDiv"></div>
        </div>
    </div>

    <div id="chatContainer" style="display: none;">
        <h3>채팅</h3>
        <div id="chatBox">
        </div>
        <div class="chat-input-area">
            <input type="text" id="chatInput" placeholder="메시지 입력..." />
            <button type="button" id="sendChatBtn">전송</button>
        </div>
    </div>
</div>

<script>
    /*<![CDATA[*/ // JSP의 EL 파싱을 방지하기 위한 CDATA 섹션 시작
    let localStreamElement = document.querySelector('#localStream');
    const myKey = Math.random().toString(36).substring(2, 11);
    let pcListMap = new Map(); // PeerConnection 객체들을 저장
    let roomId;
    let otherKeyList = []; // 현재 방에 있는 다른 참가자들의 키
    let localStream = undefined; // 로컬 스트림 (웹캠 스트림으로 사용될 예정)
    let stompClient; // STOMP 클라이언트

    // 녹화 관련 변수
    let mediaRecorder;
    let recordedChunks = [];
    let recordedBlob; // 최종 녹화된 Blob을 저장

    // 모든 원격 참가자의 스트림을 저장할 Map (오디오 믹싱용)
    // Map<key, MediaStream> 형태로 저장하여 각 참가자의 모든 트랙을 관리
    let remoteStreamMap = new Map();

    // Web Audio API 관련 변수
    let audioContext;
    let destinationStream; // 믹싱된 오디오 스트림이 나가는 곳

    // **새로운 전역 변수 추가: 캔버스 및 애니메이션 관련**
    let canvas;
    let canvasCtx;
    let animationFrameId; // requestAnimationFrame ID

    /**
     * 웹캠 스트림을 가져오는 함수
     * 사용자의 카메라(웹캠) 및 마이크 오디오를 캡처합니다.
     */
    const startCam = async () => {
        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
            try {
                // 카메라(비디오) 및 마이크(오디오) 스트림 요청
                localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });

                // **디버깅을 위한 오디오 트랙 확인**:
                console.log("Local Stream Audio Tracks:", localStream.getAudioTracks().length > 0 ? "YES" : "NO", localStream.getAudioTracks());

                localStreamElement.srcObject = localStream;
                localStreamElement.style.display = 'block'; // 비디오 요소 보이게 설정
                localStreamElement.parentElement.style.display = 'inline-block'; // wrapper 보이게 설정

                // 로컬 스트림이 준비되면 녹화 및 스트림 관련 버튼 표시
                document.querySelector('#startRecordBtn').style.display = 'inline-block'; // 녹화 시작 버튼 표시
                document.querySelector('#stopRecordBtn').style.display = 'inline-block'; // 녹화 끝 버튼도 표시 (초기엔 disabled)
                document.querySelector('#startSteamBtn').style.display = 'inline-block'; // 스트림 시작 버튼 표시

                // 사용자가 카메라/마이크 접근을 중지했을 때 이벤트 처리 (선택 사항)
                localStream.getVideoTracks()[0].onended = () => {
                    console.log('사용자가 카메라/마이크 접근을 중지했습니다.');
                    if (mediaRecorder && mediaRecorder.state !== 'inactive') {
                        mediaRecorder.stop(); // 녹화 중지
                    }
                    stopAllStreamsAndConnections(); // 모든 스트림 및 연결 정리
                    alert("카메라/마이크 접근이 중지되었습니다.");
                };

            } catch (error) {
                console.error("웹캠/마이크 접근 오류:", error);
                // "NotAllowedError"는 사용자가 권한을 거부했음을 의미합니다.
                if (error.name === "NotAllowedError") {
                    alert("카메라 및 마이크 접근 권한이 거부되었습니다. 브라우저 설정에서 권한을 허용해주세요.");
                } else if (error.name === "NotFoundError") {
                    alert("카메라 또는 마이크를 찾을 수 없습니다. 장치 연결 상태를 확인해주세요.");
                } else {
                    alert("웹캠/마이크를 시작할 수 없습니다. 권한을 확인하거나 브라우저 설정을 확인해주세요.");
                }
                // 에러 발생 시 버튼 상태 초기화
                document.querySelector('#startRecordBtn').style.display = 'none';
                document.querySelector('#stopRecordBtn').style.display = 'none';
                document.querySelector('#localWrapper').style.display = 'none';
                document.querySelector('#startSteamBtn').style.display = 'none';
            }
        } else {
            console.warn('이 브라우저에서는 getUserMedia를 지원하지 않습니다. 최신 브라우저를 사용해주세요.');
            alert("죄송합니다. 이 브라우저에서는 웹캠/마이크 접근을 지원하지 않습니다.");
        }
    }

    /**
     * WebSocket 연결 및 STOMP 구독 설정
     */
    const connectSocket = async () => {
        const socket = new SockJS('/signaling');
        stompClient = Stomp.over(socket);
        stompClient.debug = null; // STOMP 디버그 메시지 비활성화 (개발 중에는 활성화하여 메시지 흐름 확인)

        stompClient.connect({}, function () {
            console.log('WebRTC 서버에 연결되었습니다.');

            // ICE Candidate 수신 구독: P2P 연결을 위한 네트워크 정보
            stompClient.subscribe('/topic/peer/iceCandidate/' + myKey + '/' + roomId, candidate => {
                const key = JSON.parse(candidate.body).key;
                const message = JSON.parse(candidate.body).body;
                if (pcListMap.has(key)) {
                    pcListMap.get(key).addIceCandidate(new RTCIceCandidate(message))
                        .catch(e => console.error('ICE 후보 추가 오류 for ' + key + ':', e)); // 문자열 연결
                }
            });

            // Offer 수신 구독: P2P 연결 시작 제안 (Session Description Protocol)
            stompClient.subscribe('/topic/peer/offer/' + myKey + '/' + roomId, offer => {
                const key = JSON.parse(offer.body).key;
                const message = JSON.parse(offer.body).body;

                if (!pcListMap.has(key)) {
                    const pc = createPeerConnection(key);
                    pcListMap.set(key, pc);
                }

                pcListMap.get(key).setRemoteDescription(new RTCSessionDescription(message))
                    .then(() => {
                        sendAnswer(pcListMap.get(key), key); // Offer에 대한 Answer 전송
                    }).catch(e => console.error('원격 설명 설정 오류 (Offer) from ' + key + ':', e)); // 문자열 연결
            });

            // Answer 수신 구독: Offer에 대한 응답
            stompClient.subscribe('/topic/peer/answer/' + myKey + '/' + roomId, answer => {
                const key = JSON.parse(answer.body).key;
                const message = JSON.parse(answer.body).body;
                if (pcListMap.has(key)) {
                    pcListMap.get(key).setRemoteDescription(new RTCSessionDescription(message))
                        .catch(e => console.error('원격 설명 설정 오류 (Answer) for ' + key + ':', e)); // 문자열 연결
                }
            });

            // 새로운 피어가 방에 들어왔을 때 내 키를 알리기 위한 구독
            stompClient.subscribe('/topic/call/key', () => {
                stompClient.send('/app/send/key', {}, JSON.stringify(myKey));
            });

            // 다른 피어의 키 수신 구독 (방에 있는 참가자 목록 업데이트)
            stompClient.subscribe('/topic/send/key', message => {
                const key = JSON.parse(message.body);
                if (key && key !== myKey && !otherKeyList.includes(key)) {
                    otherKeyList.push(key);
                    console.log('새로운 참가자 ' + key + '가 방에 추가되었습니다. 현재 참가자:', otherKeyList); // 문자열 연결
                }
            });

            // 채팅 메시지 수신 구독 (널 문자 제거 로직 추가)
            stompClient.subscribe('/topic/chat/' + roomId, chatMessage => {
                // chatMessage.body의 끝에 붙어있는 널 문자(\u0000)를 제거합니다.
                const cleanedBody = chatMessage.body.replace(/\0/g, '');

                // 디버깅을 위해 콘솔에 파싱된 데이터 출력
                console.log("Original chatMessage.body:", chatMessage.body); // 원본 로그 추가
                console.log("Cleaned body (after null char removal):", cleanedBody); // 클린된 바디 로그 추가

                try {
                    // 이제 깨끗한 JSON 문자열을 파싱합니다.
                    const msgData = JSON.parse(cleanedBody);

                    // 디버깅을 위해 콘솔에 파싱된 데이터 출력
                    console.log("Parsed chat message data (after cleanup):", msgData);

                    // msgData.sender와 msgData.message가 유효한지 다시 한번 확인하고 appendChatMessage 호출
                    if (msgData && msgData.sender && msgData.message) {
                        appendChatMessage(msgData.sender, msgData.message);
                    } else {
                        console.warn("Invalid chat message data received or missing sender/message:", msgData);
                    }
                } catch (e) {
                    // JSON 파싱 오류가 발생했을 경우 콘솔에 기록
                    console.error("JSON parse error for chat message:", e);
                    console.error("Attempted to parse:", cleanedBody);
                }
            });

            // 피어가 방을 나갈 때 처리 (예: '/topic/peer/exit/{roomId}' 같은 메시지 구독)
            // stompClient.subscribe('/topic/peer/exit/' + roomId, message => {
            //     const exitedKey = JSON.parse(message.body).key;
            //     removePeerConnection(exitedKey);
            // });

        }, (error) => {
            console.error("STOMP 연결 오류:", error);
            alert("WebRTC 서버 연결에 실패했습니다. 새로고침 후 다시 시도해주세요.");
        });
    }

    /**
     * 원격 스트림의 트랙이 추가되었을 때 처리하는 함수
     * 각 피어의 스트림을 관리하고 비디오 요소에 연결합니다.
     */
    let onTrack = (event, otherKey) => {
        if (!otherKey) return;

        // 원격 스트림의 비디오 요소를 위한 wrapper 생성/찾기
        let existingWrapper = document.getElementById('wrapper-' + otherKey); // 문자열 연결
        if (!existingWrapper) {
            const wrapper = document.createElement('div');
            wrapper.className = 'video-wrapper';
            wrapper.id = 'wrapper-' + otherKey; // 문자열 연결

            const video = document.createElement('video');
            video.autoplay = true;
            video.controls = true; // 컨트롤 추가하여 소리 확인 용이하게 (개발용)
            video.id = 'video-' + otherKey; // 문자열 연결
            // WebRTC에서는 자신의 오디오가 상대방에게 다시 들리는 것을 방지하기 위해
            // 기본적으로 상대방의 비디오/오디오 요소를 muted 상태로 둡니다.
            // video.muted = true; // 실제 서비스에서는 true로 설정하는 것이 좋음
            video.muted = false; // 테스트를 위해 잠시 false로 설정하여 상대방 소리 확인

            wrapper.appendChild(video);

            const label = document.createElement('div');
            label.className = 'label';
            label.innerText = '상대방 (' + otherKey.substring(0, 4) + '...)'; // 상대방 레이블 (문자열 연결로 변경)
            wrapper.appendChild(label);

            document.getElementById('remoteStreamDiv').appendChild(wrapper);
        }

        const videoEl = document.getElementById('video-' + otherKey); // 문자열 연결
        let remoteStream = remoteStreamMap.get(otherKey);

        // 해당 키에 대한 스트림이 없으면 새 스트림 생성
        if (!remoteStream) {
            remoteStream = new MediaStream();
            remoteStreamMap.set(otherKey, remoteStream);
            videoEl.srcObject = remoteStream; // 비디오 요소에 연결
            console.log('[onTrack] New remote stream created for ' + otherKey + '.'); // 문자열 연결
        }

        // 트랙이 이미 스트림에 추가되었는지 확인하여 중복 추가 방지
        const existingTrack = remoteStream.getTrackById(event.track.id);
        if (!existingTrack) {
            remoteStream.addTrack(event.track); // 스트림에 트랙 추가
            console.log('[onTrack] Track ' + event.track.kind + ' added for ' + otherKey + '. Total tracks in stream: ' + remoteStream.getTracks().length); // 문자열 연결
            if (event.track.kind === 'audio') {
                console.log('[DEBUG] Audio track received from ' + otherKey + ':', event.track); // 문자열 연결
            }
        } else {
            console.log('[onTrack] Track ' + event.track.kind + ' already exists for ' + otherKey + '.'); // 문자열 연결
        }
    };

    /**
     * PeerConnection을 생성하고 이벤트 리스너를 설정하는 함수
     */
    const createPeerConnection = (otherKey) => {
        // STUN/TURN 서버 설정 (ICE 후보 교환을 위한 필수 서버)
        const pcConfig = {
            iceServers: [
                { urls: 'stun:stun.l.google.com:19302' }, // 구글 STUN 서버 (공개)
                // { urls: 'turn:YOUR_TURN_SERVER_URL', username: 'YOUR_USERNAME', credential: 'YOUR_PASSWORD' } // TURN 서버는 방화벽 뒤에서 연결을 가능하게 합니다.
            ]
        };
        const pc = new RTCPeerConnection(pcConfig);

        // ICE Candidate 생성 이벤트 리스너
        pc.addEventListener('icecandidate', (event) => {
            if (event.candidate) {
                // 생성된 ICE 후보를 Signaling 서버를 통해 상대방에게 전송
                stompClient.send('/app/peer/iceCandidate/' + otherKey + '/' + roomId, {}, JSON.stringify({
                    key: myKey,
                    body: event.candidate
                }));
            }
        });

        // 원격 스트림의 트랙이 추가될 때 onTrack 함수 호출
        pc.addEventListener('track', (event) => {
            onTrack(event, otherKey);
        });

        // 로컬 스트림의 모든 트랙을 PeerConnection에 추가 (웹캠 스트림)
        if (localStream) {
            localStream.getTracks().forEach(track => {
                pc.addTrack(track, localStream);
            });
            console.log("Local stream tracks added to PeerConnection:", localStream.getTracks().map(t => t.kind));
        }

        return pc;
    }

    /**
     * Offer(연결 제안)를 생성하고 전송하는 함수
     */
    let sendOffer = (pc, otherKey) => {
        pc.createOffer().then(offer => {
            pc.setLocalDescription(offer); // 로컬 설명 설정
            stompClient.send('/app/peer/offer/' + otherKey + '/' + roomId, {}, JSON.stringify({
                key: myKey,
                body: offer
            })); // Offer를 Signaling 서버를 통해 상대방에게 전송
            console.log('Offer sent to ' + otherKey + '.'); // 문자열 연결
        }).catch(e => console.error('Offer 생성 오류 for ' + otherKey + ':', e)); // 문자열 연결
    };

    /**
     * Answer(연결 응답)를 생성하고 전송하는 함수
     */
    let sendAnswer = (pc, otherKey) => {
        pc.createAnswer().then(answer => {
            pc.setLocalDescription(answer); // 로컬 설명 설정
            stompClient.send('/app/peer/answer/' + otherKey + '/' + roomId, {}, JSON.stringify({
                key: myKey,
                body: answer
            })); // Answer를 Signaling 서버를 통해 상대방에게 전송
            console.log('Answer sent to ' + otherKey + '.'); // 문자열 연결
        }).catch(e => console.error('Answer 생성 오류 for ' + otherKey + ':', e)); // 문자열 연결
    };

    /**
     * 모든 참가자의 오디오 스트림을 믹싱하여 하나의 MediaStream을 생성하는 함수
     * 이 함수는 녹화 시작 직전에 호출되어 현재 존재하는 모든 오디오를 통합합니다.
     */
    const mixAudioStreams = () => {
        // 기존 오디오 컨텍스트가 있다면 닫고 새로 생성하여 이전 연결 정리
        if (audioContext) {
            audioContext.close();
            console.log('Previous AudioContext closed.');
        }
        audioContext = new (window.AudioContext || window.webkitAudioContext)();
        destinationStream = audioContext.createMediaStreamDestination();

        // 1. 내 로컬 스트림(웹캠)의 오디오 트랙을 믹싱
        if (localStream && localStream.getAudioTracks().length > 0) {
            const localAudioSource = audioContext.createMediaStreamSource(localStream);
            localAudioSource.connect(destinationStream);
            console.log("Local audio stream (mic) added to mix.");
        } else {
            console.warn("No local audio stream available for mixing from getUserMedia. (Check browser mic permissions)");
        }

        // 2. 모든 원격 참가자의 오디오 스트림을 믹싱
        remoteStreamMap.forEach((stream, key) => {
            if (stream && stream.getAudioTracks().length > 0) {
                // 원격 스트림의 오디오는 비디오 요소의 muted 속성과는 별개로 믹싱됩니다.
                const remoteAudioSource = audioContext.createMediaStreamSource(stream);
                remoteAudioSource.connect(destinationStream);
                console.log('Remote audio stream from ' + key + ' added to mix.'); // 문자열 연결
            } else {
                console.warn('No audio stream found for remote participant ' + key + ' in remoteStreamMap.'); // 문자열 연결
            }
        });

        // 믹싱된 오디오 스트림 반환
        return destinationStream.stream;
    };

    // --- 채팅 기능 관련 함수 ---
    const chatBox = document.getElementById('chatBox');
    const chatInput = document.getElementById('chatInput');
    const sendChatBtn = document.getElementById('sendChatBtn');

    const appendChatMessage = (senderKey, message) => {
        // 디버깅을 위한 로그 (필요하다면 유지하거나 제거하세요)
        console.log("appendChatMessage called with:", { senderKey, message });

        // 메시지를 감쌀 wrapper div 생성 (정렬을 위해 필요)
        const messageWrapper = document.createElement('div');
        messageWrapper.className = 'chat-message-wrapper';

        const messageElement = document.createElement('div');
        messageElement.className = 'chat-message'; // 기본 말풍선 스타일

        let displaySender;
        if (senderKey === myKey) {
            displaySender = '나';
            messageWrapper.classList.add('my-message-wrapper'); // 내가 보낸 메시지 wrapper
            messageElement.classList.add('my-message'); // 내가 보낸 메시지 말풍선
        } else {
            displaySender = '상대방 (' + senderKey.substring(0, 4) + '...)';
            messageWrapper.classList.add('other-message-wrapper'); // 상대방 메시지 wrapper
            messageElement.classList.add('other-message'); // 상대방 메시지 말풍선
        }

        // 디버깅을 위한 로그 (필요하다면 유지하거나 제거하세요)
        console.log("displaySender:", displaySender);

        // 발신자 이름과 메시지 내용을 별도의 요소로 감싸서 유연하게 스타일링
        const senderSpan = document.createElement('strong');
        senderSpan.textContent = displaySender + ':';
        messageElement.appendChild(senderSpan);

        const messageTextNode = document.createTextNode(message); // 메시지 텍스트 노드 생성
        messageElement.appendChild(messageTextNode);

        // messageElement를 wrapper에 추가
        messageWrapper.appendChild(messageElement);

        // 디버깅을 위한 로그 (필요하다면 유지하거나 제거하세요)
        console.log("messageWrapper.outerHTML (before append):", messageWrapper.outerHTML); // HTML 내용 확인

        chatBox.appendChild(messageWrapper); // wrapper를 chatBox에 추가
        chatBox.scrollTop = chatBox.scrollHeight;

        // 디버깅을 위한 로그 (필요하다면 유지하거나 제거하세요)
        console.log("Message appended. Current chatBox HTML:", chatBox.innerHTML);
    };

    sendChatBtn.addEventListener('click', () => {
        const message = chatInput.value.trim();
        if (message) {
            if (stompClient && stompClient.connected) {
                stompClient.send('/app/chat/' + roomId, {}, JSON.stringify({ sender: myKey, message: message }));
                chatInput.value = ''; // 입력창 비우기
            } else {
                alert("채팅 서버에 연결되지 않았습니다. 방에 먼저 참여해주세요.");
            }
        }
    });

    chatInput.addEventListener('keypress', (event) => {
        if (event.key === 'Enter') {
            sendChatBtn.click();
        }
    });


    // --- 이벤트 리스너 설정 ---

    document.querySelector('#enterRoomBtn').addEventListener('click', async () => {
        const inputRoomId = document.querySelector('#roomIdInput').value;
        if (!inputRoomId || isNaN(inputRoomId) || inputRoomId.trim() === '') {
            alert("유효한 방 번호(숫자)를 입력해주세요.");
            return;
        }
        roomId = inputRoomId;

        // 화면 공유 스트림 가져오기 시도 -> 웹캠 스트림으로 변경
        await startCam();

        // 스트림이 성공적으로 가져와졌을 때만 소켓 연결 및 UI 비활성화
        if (localStream) {
            document.querySelector('#roomIdInput').disabled = true;
            document.querySelector('#enterRoomBtn').disabled = true;
            await connectSocket();
            document.getElementById('chatContainer').style.display = 'flex'; // 채팅창 표시
            alert('방 ' + roomId + '에 참여했습니다. \'스트림 시작\'을 눌러 대화를 시작하세요.'); // 문자열 연결
        } else {
            console.warn("웹캠 스트림을 가져오지 못하여 방 참여를 취소합니다."); // 메시지 수정
        }
    });

    document.querySelector('#startSteamBtn').addEventListener('click', async () => {
        if (!stompClient || !stompClient.connected) {
            alert("먼저 '방 참여' 버튼을 눌러야 스트림을 시작할 수 있습니다.");
            return;
        }
        if (!localStream) {
            alert("웹캠 스트림이 활성화되지 않았습니다. '방 참여'를 먼저 눌러주세요."); // 메시지 수정
            return;
        }

        stompClient.send('/app/call/key', {}, {}); // 방에 있는 다른 사람들에게 내 키 요청

        // 1초 후 다른 피어들에게 Offer 보내기 (다른 참가자들이 응답할 시간 필요)
        setTimeout(() => {
            if (otherKeyList.length === 0) {
                alert("현재 방에 다른 참가자가 없습니다. 잠시 후 다시 시도하거나 다른 참가자를 기다려주세요.");
                return;
            }
            otherKeyList.forEach((key) => {
                if (!pcListMap.has(key)) {
                    const pc = createPeerConnection(key);
                    pcListMap.set(key, pc);
                    sendOffer(pc, key);
                    console.log('Created PeerConnection for ' + key + ' and sent offer.'); // 문자열 연결
                }
            });
            alert("스트림이 시작되었습니다! 다른 참가자와 연결 중입니다.");
        }, 1000); // STOMP 메시지 교환 시간 고려
    });

    /**
     * 녹화 시작 버튼 클릭 핸들러
     */
    document.querySelector('#startRecordBtn').addEventListener('click', async () => {
        if (!localStream || localStream.getTracks().length === 0) {
            console.warn('Cannot start recording: 로컬 스트림이 활성화되지 않았습니다.');
            alert("먼저 '방 참여'를 눌러 웹캠을 시작해주세요."); // 메시지 수정
            return;
        }

        recordedChunks = []; // 이전 녹화 데이터 초기화

        // 1. 모든 오디오 스트림을 믹싱하여 하나의 스트림 생성
        const mixedAudio = mixAudioStreams();

        // **2. 비디오 합성을 위한 캔버스 준비**
        // 캔버스 크기를 모든 비디오를 포함할 수 있도록 적절히 설정
        // 예: 로컬 비디오 (640x480) + 원격 비디오들 (각 640x480)을 2x2 그리드로 배치
        const videoWidth = 640; // 각 비디오의 너비 (예시)
        const videoHeight = 480; // 각 비디오의 높이 (예시)

        // 캔버스 크기 계산 (예: 2x2 그리드, 최대 4명의 참가자를 가정)
        const canvasWidth = videoWidth * 2;
        const canvasHeight = videoHeight * 2;

        canvas = document.createElement('canvas');
        canvas.width = canvasWidth;
        canvas.height = canvasHeight;
        canvasCtx = canvas.getContext('2d');

        // **디버깅용: 캔버스를 잠시 body에 추가하여 확인 (필요시 주석 해제)**
        // document.body.appendChild(canvas);
        // canvas.style.position = 'absolute';
        // canvas.style.top = '0';
        // canvas.style.left = '0';
        // canvas.style.zIndex = '9999';
        // canvas.style.border = '2px solid red';


        // **3. 캔버스에 비디오 스트림을 그리는 함수**
        const drawVideosOnCanvas = () => {
            // 캔버스 초기화 (이전 프레임 지우기)
            canvasCtx.clearRect(0, 0, canvas.width, canvas.height);
            canvasCtx.fillStyle = '#000000'; // 배경색 검정
            canvasCtx.fillRect(0, 0, canvas.width, canvas.height);

            let videoElements = [];
            // 로컬 비디오 추가
            if (localStreamElement.srcObject) {
                videoElements.push(localStreamElement);
            }
            // 원격 비디오들 추가
            remoteStreamMap.forEach((stream, key) => {
                const remoteVideoEl = document.getElementById('video-' + key);
                if (remoteVideoEl && remoteVideoEl.srcObject) {
                    videoElements.push(remoteVideoEl);
                }
            });

            // 비디오 개수에 따라 레이아웃 조정 (예시: 1개, 2개, 3-4개)
            const numVideos = videoElements.length;
            let x = 0;
            let y = 0;
            let currentVideoWidth = videoWidth;
            let currentVideoHeight = videoHeight;

            // 동적으로 캔버스 레이아웃 조정 (예시)
            if (numVideos === 1) { // 1개: 중앙에 크게
                currentVideoWidth = canvasWidth;
                currentVideoHeight = canvasHeight;
                x = 0;
                y = 0;
                canvasCtx.drawImage(videoElements[0], x, y, currentVideoWidth, currentVideoHeight);
            } else if (numVideos === 2) { // 2개: 가로로 나란히
                currentVideoWidth = canvasWidth / 2;
                currentVideoHeight = canvasHeight;
                canvasCtx.drawImage(videoElements[0], 0, 0, currentVideoWidth, currentVideoHeight);
                canvasCtx.drawImage(videoElements[1], currentVideoWidth, 0, currentVideoWidth, currentVideoHeight);
            } else if (numVideos >= 3) { // 3-4개: 2x2 그리드
                currentVideoWidth = canvasWidth / 2;
                currentVideoHeight = canvasHeight / 2;
                videoElements.forEach((videoEl, index) => {
                    const col = index % 2;
                    const row = Math.floor(index / 2);
                    x = col * currentVideoWidth;
                    y = row * currentVideoHeight;
                    canvasCtx.drawImage(videoEl, x, y, currentVideoWidth, currentVideoHeight);
                });
            }


            animationFrameId = requestAnimationFrame(drawVideosOnCanvas);
        };

        // **캔버스 캡처 스트림 생성**
        // 캔버스 프레임 속도는 웹캠 스트림의 프레임 속도에 맞추거나 적절히 설정 (예: 30fps)
        const canvasStream = canvas.captureStream(30); // 30fps로 캔버스 내용을 비디오 스트림으로 캡처

        // **4. 최종 결합 스트림 생성 (캔버스 비디오 + 믹싱 오디오)**
        const combinedStream = new MediaStream();
        if (canvasStream.getVideoTracks().length > 0) {
            combinedStream.addTrack(canvasStream.getVideoTracks()[0]); // 캔버스에서 캡처한 비디오 트랙
            console.log("Canvas video track added to combined stream for recording.");
        } else {
            console.warn("No video track from canvas. Recording will be audio only.");
        }

        if (mixedAudio && mixedAudio.getAudioTracks().length > 0) {
            mixedAudio.getAudioTracks().forEach(track => combinedStream.addTrack(track)); // 믹싱된 오디오 트랙 추가
            console.log("Mixed audio stream added to combined stream for recording.");
        } else {
            console.warn("No mixed audio stream. Recording will be video only (no audio from participants).");
            alert("음성 없이 비디오만 녹화됩니다. 오디오 소스를 확인해주세요 (마이크 권한, 상대방 오디오 스트림 문제).");
        }

        // MediaRecorder를 합쳐진 스트림으로 생성
        mediaRecorder = new MediaRecorder(combinedStream, { mimeType: 'video/webm; codecs=vp8,opus' });

        // 데이터가 사용 가능할 때마다 호출됩니다. (청크 수집)
        mediaRecorder.ondataavailable = (event) => {
            if (event.data.size > 0) {
                recordedChunks.push(event.data);
            }
        };

        // 녹화가 중지될 때 호출됩니다. (파일 저장)
        mediaRecorder.onstop = () => {
            if (animationFrameId) {
                cancelAnimationFrame(animationFrameId);
                animationFrameId = null;
            }

            recordedBlob = new Blob(recordedChunks, { type: 'video/webm' });
            const url = URL.createObjectURL(recordedBlob);

            // 👉 S3 업로드용 FormData 생성
            const formData = new FormData();
            formData.append("file", recordedBlob);

            // ✅ 서버에 업로드 요청
            fetch("/interview/save", {
                method: "POST",
                body: formData
            })
            .then(res => {
                if (res.ok) {
                    alert("✅ 녹화가 S3에 업로드되었습니다.");
                } else {
                    alert("❌ 업로드 실패. 서버 응답 에러.");
                }
            })
            .catch(err => {
                alert("❌ 업로드 중 오류 발생: " + err.message);
            });

            // 🔽 (선택) 다운로드도 같이 진행할 경우 유지
            const a = document.createElement('a');
            a.style = 'display: none';
            a.href = url;
            const timestamp = new Date().toISOString().replace(/:/g, '-').replace(/\./g, '-');
            a.download = "recorded-interview-" + timestamp + ".webm";
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);

            alert("📁 녹화가 로컬에도 저장되었습니다: " + a.download);

            // 버튼 초기화
            document.querySelector('#startRecordBtn').disabled = false;
            document.querySelector('#stopRecordBtn').disabled = true;
        };

        // 녹화 중 오류 발생 시 처리
        mediaRecorder.onerror = (event) => {
            console.error("MediaRecorder error:", event.error);
            alert("녹화 중 오류가 발생했습니다: " + event.error.name + " - " + event.error.message); // 문자열 연결로 변경
            // 오류 발생 시에도 버튼 상태 초기화
            document.querySelector('#startRecordBtn').disabled = false;
            document.querySelector('#stopRecordBtn').disabled = true;
            // **오류 발생 시에도 애니메이션 프레임 중지 및 캔버스 정리**
            if (animationFrameId) {
                cancelAnimationFrame(animationFrameId);
                animationFrameId = null;
            }
            // if (canvas && canvas.parentNode) {
            //     canvas.parentNode.removeChild(canvas);
            //     canvas = null;
            //     canvasCtx = null;
            // }
        };

        // **녹화 시작 전에 캔버스 그리기 시작**
        drawVideosOnCanvas();

        mediaRecorder.start(); // 녹화 시작
        console.log('Recording started with combined video and audio.');
        document.querySelector('#startRecordBtn').disabled = true; // 녹화 시작 버튼 비활성화
        document.querySelector('#stopRecordBtn').disabled = false; // 녹화 끝 버튼 활성화
    });

    /**
     * 녹화 끝 버튼 클릭 핸들러
     */
    document.querySelector('#stopRecordBtn').addEventListener('click', () => {
        if (mediaRecorder && mediaRecorder.state !== 'inactive') {
            mediaRecorder.stop(); // 녹화 중지
            console.log('Recording stopped. Downloading video...');
            // 버튼 상태는 mediaRecorder.onstop에서 처리됩니다.
        }
    });

    /**
     * 모든 스트림과 PeerConnection, WebSocket 연결을 정리하고 UI를 초기화하는 함수
     */
    const stopAllStreamsAndConnections = () => {
        // 로컬 스트림 트랙 중지 및 비디오 요소 초기화
        if (localStream) {
            localStream.getTracks().forEach(track => track.stop());
            localStream = undefined; // localStream 초기화
        }
        if (localStreamElement) {
            localStreamElement.srcObject = null; // 비디오 요소 초기화
        }

        // 모든 PeerConnection 닫기 및 관련 Map 초기화
        pcListMap.forEach(pc => pc.close());
        pcListMap.clear();
        otherKeyList = [];
        remoteStreamMap.clear(); // 원격 스트림 Map 초기화
        document.getElementById('remoteStreamDiv').innerHTML = ''; // 원격 비디오 요소들 삭제

        // STOMP 연결 끊기
        if (stompClient && stompClient.connected) {
            stompClient.disconnect(() => console.log('STOMP 연결이 끊겼습니다.'));
        }

        // Web Audio API Context 종료
        if (audioContext) {
            audioContext.close();
            audioContext = null;
            destinationStream = null;
            console.log('AudioContext closed.');
        }

        // **캔버스 애니메이션 프레임 중지 및 캔버스 정리 추가**
        if (animationFrameId) {
            cancelAnimationFrame(animationFrameId);
            animationFrameId = null;
        }
        if (canvas && canvas.parentNode) {
            canvas.parentNode.removeChild(canvas);
            canvas = null;
            canvasCtx = null;
        }


        // UI 상태 초기화
        document.querySelector('#startRecordBtn').disabled = false;
        document.querySelector('#stopRecordBtn').disabled = true;
        document.querySelector('#startRecordBtn').style.display = 'none';
        document.querySelector('#stopRecordBtn').style.display = 'none';
        document.querySelector('#localWrapper').style.display = 'none';
        document.querySelector('#startSteamBtn').style.display = 'none';
        document.querySelector('#roomIdInput').disabled = false;
        document.querySelector('#enterRoomBtn').disabled = false;
        document.querySelector('#roomIdInput').value = ''; // 방 번호 입력 필드 초기화
        document.getElementById('chatContainer').style.display = 'none'; // 채팅창 숨기기
        chatBox.innerHTML = ''; // 채팅 내용 초기화
    };

    /**
     * 페이지를 떠나기 전에 모든 자원 정리
     */
    window.addEventListener('beforeunload', () => {
        stopAllStreamsAndConnections();
    });
    /*]]>*/ // CDATA 블록 끝
</script>
</body>
</html>