<%--<!DOCTYPE html>--%>
<%--<html lang="ko">--%>
<%--<head>--%>
<%--    <meta charset="UTF-8">--%>
<%--    <title>WebRTC working example</title>--%>

<%--    <!-- 외부 라이브러리 -->--%>
<%--    <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js"></script>--%>
<%--    <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>--%>

<%--    <!-- 스타일 -->--%>
<%--    <style>--%>
<%--        body {--%>
<%--            font-family: Arial, sans-serif;--%>
<%--            background-color: #f4f6f9;--%>
<%--            padding: 20px;--%>
<%--        }--%>

<%--        #controls {--%>
<%--            margin-bottom: 20px;--%>
<%--        }--%>

<%--        input[type="number"] {--%>
<%--            padding: 5px;--%>
<%--            font-size: 16px;--%>
<%--            width: 100px;--%>
<%--        }--%>

<%--        button {--%>
<%--            padding: 6px 12px;--%>
<%--            font-size: 15px;--%>
<%--            margin-left: 5px;--%>
<%--            border: none;--%>
<%--            background-color: #007bff;--%>
<%--            color: white;--%>
<%--            border-radius: 4px;--%>
<%--            cursor: pointer;--%>
<%--        }--%>

<%--        button:disabled {--%>
<%--            background-color: #999;--%>
<%--            cursor: not-allowed;--%>
<%--        }--%>

<%--        .video-wrapper {--%>
<%--            position: relative;--%>
<%--            display: inline-block;--%>
<%--            margin: 10px;--%>
<%--            border-radius: 10px;--%>
<%--            overflow: hidden;--%>
<%--            box-shadow: 0 4px 12px rgba(0,0,0,0.15);--%>
<%--            background: white;--%>
<%--        }--%>

<%--        .video-wrapper video {--%>
<%--            display: block;--%>
<%--            width: 300px;--%>
<%--            height: auto;--%>
<%--        }--%>

<%--        .label {--%>
<%--            position: absolute;--%>
<%--            top: 5px;--%>
<%--            left: 5px;--%>
<%--            background: rgba(0,0,0,0.6);--%>
<%--            color: white;--%>
<%--            padding: 2px 6px;--%>
<%--            font-size: 14px;--%>
<%--            border-radius: 3px;--%>
<%--        }--%>

<%--        #videoContainer {--%>
<%--            display: flex;--%>
<%--            flex-wrap: wrap;--%>
<%--            gap: 10px;--%>
<%--        }--%>
<%--    </style>--%>
<%--</head>--%>
<%--<body>--%>

<%--<div id="controls">--%>
<%--    <input type="number" id="roomIdInput" placeholder="Room ID" />--%>
<%--    <button type="button" id="enterRoomBtn">Enter Room</button>--%>
<%--    <button type="button" id="startSteamBtn" style="display: none;">Start Streams</button>--%>
<%--</div>--%>

<%--<div id="videoContainer">--%>
<%--    <!-- 내 비디오 -->--%>
<%--    <div class="video-wrapper" id="localWrapper" style="display: none;">--%>
<%--        <video id="localStream" autoplay playsinline muted controls></video>--%>
<%--        <div class="label">Me</div>--%>
<%--    </div>--%>

<%--    <!-- 상대방 비디오 표시 영역 -->--%>
<%--    <div id="remoteStreamDiv"></div>--%>
<%--</div>--%>

<%--<script>--%>
<%--    let localStreamElement = document.querySelector('#localStream');--%>
<%--    const myKey = Math.random().toString(36).substring(2, 11);--%>
<%--    let pcListMap = new Map();--%>
<%--    let roomId;--%>
<%--    let otherKeyList = [];--%>
<%--    let localStream = undefined;--%>
<%--    let stompClient;--%>

<%--    const startCam = async () => {--%>
<%--        if (navigator.mediaDevices !== undefined) {--%>
<%--            await navigator.mediaDevices.getUserMedia({ audio: true, video: true })--%>
<%--                .then(async (stream) => {--%>
<%--                    localStream = stream;--%>
<%--                    stream.getAudioTracks()[0].enabled = true;--%>
<%--                    localStreamElement.srcObject = localStream;--%>
<%--                }).catch(error => {--%>
<%--                    console.error("Error accessing media devices:", error);--%>
<%--                });--%>
<%--        }--%>
<%--    }--%>

<%--    const connectSocket = async () => {--%>
<%--        const socket = new SockJS('/signaling');--%>
<%--        stompClient = Stomp.over(socket);--%>
<%--        stompClient.debug = null;--%>

<%--        stompClient.connect({}, function () {--%>
<%--            console.log('Connected to WebRTC server');--%>

<%--            stompClient.subscribe('/topic/peer/iceCandidate/' + myKey + '/' + roomId, candidate => {--%>
<%--                const key = JSON.parse(candidate.body).key;--%>
<%--                const message = JSON.parse(candidate.body).body;--%>
<%--                if (pcListMap.has(key)) {--%>
<%--                    pcListMap.get(key).addIceCandidate(new RTCIceCandidate(message))--%>
<%--                        .catch(e => console.error(`Error adding ICE candidate for ${key}:`, e));--%>
<%--                }--%>
<%--            });--%>

<%--            stompClient.subscribe('/topic/peer/offer/' + myKey + '/' + roomId, offer => {--%>
<%--                const key = JSON.parse(offer.body).key;--%>
<%--                const message = JSON.parse(offer.body).body;--%>

<%--                if (!pcListMap.has(key)) {--%>
<%--                    const pc = createPeerConnection(key);--%>
<%--                    pcListMap.set(key, pc);--%>
<%--                }--%>

<%--                pcListMap.get(key).setRemoteDescription(new RTCSessionDescription(message))--%>
<%--                    .then(() => {--%>
<%--                        sendAnswer(pcListMap.get(key), key);--%>
<%--                    }).catch(e => console.error(`Error setting remote description for offer from ${key}:`, e));--%>
<%--            });--%>

<%--            stompClient.subscribe('/topic/peer/answer/' + myKey + '/' + roomId, answer => {--%>
<%--                const key = JSON.parse(answer.body).key;--%>
<%--                const message = JSON.parse(answer.body).body;--%>
<%--                if (pcListMap.has(key)) {--%>
<%--                    pcListMap.get(key).setRemoteDescription(new RTCSessionDescription(message))--%>
<%--                        .catch(e => console.error(`Error setting remote description (answer) for ${key}:`, e));--%>
<%--                }--%>
<%--            });--%>

<%--            stompClient.subscribe(`/topic/call/key`, () => {--%>
<%--                stompClient.send(`/app/send/key`, {}, JSON.stringify(myKey));--%>
<%--            });--%>

<%--            stompClient.subscribe(`/topic/send/key`, message => {--%>
<%--                const key = JSON.parse(message.body);--%>
<%--                if (key && key !== myKey && !otherKeyList.includes(key)) {--%>
<%--                    otherKeyList.push(key);--%>
<%--                }--%>
<%--            });--%>
<%--        });--%>
<%--    }--%>

<%--    let onTrack = (event, otherKey) => {--%>
<%--        if (!otherKey) return;--%>

<%--        let existingWrapper = document.getElementById(`wrapper-${otherKey}`);--%>
<%--        if (!existingWrapper) {--%>
<%--            const wrapper = document.createElement('div');--%>
<%--            wrapper.className = 'video-wrapper';--%>
<%--            wrapper.id = `wrapper-${otherKey}`;--%>

<%--            const video = document.createElement('video');--%>
<%--            video.autoplay = true;--%>
<%--            video.controls = true;--%>
<%--            video.id = `video-${otherKey}`;--%>
<%--            wrapper.appendChild(video);--%>

<%--            const label = document.createElement('div');--%>
<%--            label.className = 'label';--%>
<%--            label.innerText = 'other part';--%>
<%--            wrapper.appendChild(label);--%>

<%--            document.getElementById('remoteStreamDiv').appendChild(wrapper);--%>
<%--        }--%>

<%--        const videoEl = document.getElementById(`video-${otherKey}`);--%>
<%--        if (event.track.kind === 'video') {--%>
<%--            const newStream = new MediaStream([event.track]);--%>
<%--            videoEl.srcObject = newStream;--%>
<%--        }--%>
<%--    };--%>

<%--    const createPeerConnection = (otherKey) => {--%>
<%--        const pc = new RTCPeerConnection();--%>

<%--        pc.addEventListener('icecandidate', (event) => {--%>
<%--            if (event.candidate) {--%>
<%--                stompClient.send('/app/peer/iceCandidate/' + otherKey + '/' + roomId, {}, JSON.stringify({--%>
<%--                    key: myKey,--%>
<%--                    body: event.candidate--%>
<%--                }));--%>
<%--            }--%>
<%--        });--%>

<%--        pc.addEventListener('track', (event) => {--%>
<%--            onTrack(event, otherKey);--%>
<%--        });--%>

<%--        if (localStream) {--%>
<%--            localStream.getTracks().forEach(track => {--%>
<%--                pc.addTrack(track, localStream);--%>
<%--            });--%>
<%--        }--%>

<%--        return pc;--%>
<%--    }--%>

<%--    let sendOffer = (pc, otherKey) => {--%>
<%--        pc.createOffer().then(offer => {--%>
<%--            pc.setLocalDescription(offer);--%>
<%--            stompClient.send('/app/peer/offer/' + otherKey + '/' + roomId, {}, JSON.stringify({--%>
<%--                key: myKey,--%>
<%--                body: offer--%>
<%--            }));--%>
<%--        });--%>
<%--    };--%>

<%--    let sendAnswer = (pc, otherKey) => {--%>
<%--        pc.createAnswer().then(answer => {--%>
<%--            pc.setLocalDescription(answer);--%>
<%--            stompClient.send('/app/peer/answer/' + otherKey + '/' + roomId, {}, JSON.stringify({--%>
<%--                key: myKey,--%>
<%--                body: answer--%>
<%--            }));--%>
<%--        });--%>
<%--    };--%>

<%--    document.querySelector('#enterRoomBtn').addEventListener('click', async () => {--%>
<%--        await startCam();--%>
<%--        if (localStream) {--%>
<%--            document.querySelector('#localWrapper').style.display = 'inline-block';--%>
<%--            document.querySelector('#startSteamBtn').style.display = '';--%>
<%--        }--%>

<%--        roomId = document.querySelector('#roomIdInput').value;--%>
<%--        document.querySelector('#roomIdInput').disabled = true;--%>
<%--        document.querySelector('#enterRoomBtn').disabled = true;--%>

<%--        await connectSocket();--%>
<%--    });--%>

<%--    document.querySelector('#startSteamBtn').addEventListener('click', async () => {--%>
<%--        stompClient.send(`/app/call/key`, {}, {});--%>
<%--        setTimeout(() => {--%>
<%--            otherKeyList.forEach((key) => {--%>
<%--                if (!pcListMap.has(key)) {--%>
<%--                    const pc = createPeerConnection(key);--%>
<%--                    pcListMap.set(key, pc);--%>
<%--                    sendOffer(pc, key);--%>
<%--                }--%>
<%--            });--%>
<%--        }, 1000);--%>
<%--    });--%>

<%--    window.addEventListener('beforeunload', () => {--%>
<%--        if (stompClient && stompClient.connected) {--%>
<%--            stompClient.disconnect();--%>
<%--        }--%>
<%--        pcListMap.forEach(pc => pc.close());--%>
<%--        if (localStream) {--%>
<%--            localStream.getTracks().forEach(track => track.stop());--%>
<%--        }--%>
<%--    });--%>
<%--</script>--%>

<%--</body>--%>
<%--</html>--%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>WebRTC working example</title>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f9;
            padding: 20px;
        }

        #controls {
            margin-bottom: 20px;
        }

        input[type="number"] {
            padding: 5px;
            font-size: 16px;
            width: 100px;
        }

        button {
            padding: 6px 12px;
            font-size: 15px;
            margin-left: 5px;
            border: none;
            background-color: #007bff;
            color: white;
            border-radius: 4px;
            cursor: pointer;
        }

        button:disabled {
            background-color: #999;
            cursor: not-allowed;
        }

        .video-wrapper {
            position: relative;
            display: inline-block;
            margin: 10px;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            background: white;
        }

        .video-wrapper video {
            display: block;
            width: 300px;
            height: auto;
        }

        .label {
            position: absolute;
            top: 5px;
            left: 5px;
            background: rgba(0,0,0,0.6);
            color: white;
            padding: 2px 6px;
            font-size: 14px;
            border-radius: 3px;
        }

        #videoContainer {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
    </style>
</head>
<body>

<div id="controls">
    <input type="number" id="roomIdInput" placeholder="Room ID" />
    <button type="button" id="enterRoomBtn">Enter Room</button>
    <button type="button" id="startSteamBtn" style="display: none;">Start Streams</button>
    <button type="button" id="recordBtn" style="display: none;">Record</button>
</div>

<div id="videoContainer">
    <div class="video-wrapper" id="localWrapper" style="display: none;">
        <video id="localStream" autoplay playsinline muted controls></video>
        <div class="label">Me</div>
    </div>

    <div id="remoteStreamDiv"></div>
</div>

<script>
    let localStreamElement = document.querySelector('#localStream');
    const myKey = Math.random().toString(36).substring(2, 11);
    let pcListMap = new Map();
    let roomId;
    let otherKeyList = [];
    let localStream = undefined;
    let remoteStream = undefined;
    let stompClient;
    let mediaRecorder;
    let recordedChunks = [];
    let isRecording = false;
    const recordBtn = document.querySelector('#recordBtn');

    const startCam = async () => {
        if (navigator.mediaDevices !== undefined) {
            await navigator.mediaDevices.getUserMedia({ audio: true, video: true })
                .then(async (stream) => {
                    localStream = stream;
                    stream.getAudioTracks()[0].enabled = true;
                    localStreamElement.srcObject = localStream;
                }).catch(error => {
                    console.error("Error accessing media devices:", error);
                });
        }
    }

    const connectSocket = async () => {
        const socket = new SockJS('/signaling');
        stompClient = Stomp.over(socket);
        stompClient.debug = null;

        stompClient.connect({}, function () {
            console.log('Connected to WebRTC server');

            stompClient.subscribe('/topic/peer/iceCandidate/' + myKey + '/' + roomId, candidate => {
                const key = JSON.parse(candidate.body).key;
                const message = JSON.parse(candidate.body).body;
                if (pcListMap.has(key)) {
                    pcListMap.get(key).addIceCandidate(new RTCIceCandidate(message))
                        .catch(e => console.error(`Error adding ICE candidate for ${key}:`, e));
                }
            });

            stompClient.subscribe('/topic/peer/offer/' + myKey + '/' + roomId, offer => {
                const key = JSON.parse(offer.body).key;
                const message = JSON.parse(offer.body).body;

                if (!pcListMap.has(key)) {
                    const pc = createPeerConnection(key);
                    pcListMap.set(key, pc);
                }

                pcListMap.get(key).setRemoteDescription(new RTCSessionDescription(message))
                    .then(() => {
                        sendAnswer(pcListMap.get(key), key);
                    }).catch(e => console.error(`Error setting remote description for offer from ${key}:`, e));
            });

            stompClient.subscribe('/topic/peer/answer/' + myKey + '/' + roomId, answer => {
                const key = JSON.parse(answer.body).key;
                const message = JSON.parse(answer.body).body;
                if (pcListMap.has(key)) {
                    pcListMap.get(key).setRemoteDescription(new RTCSessionDescription(message))
                        .catch(e => console.error(`Error setting remote description (answer) for ${key}:`, e));
                }
            });

            stompClient.subscribe(`/topic/call/key`, () => {
                stompClient.send(`/app/send/key`, {}, JSON.stringify(myKey));
            });

            stompClient.subscribe(`/topic/send/key`, message => {
                const key = JSON.parse(message.body);
                if (key && key !== myKey && !otherKeyList.includes(key)) {
                    otherKeyList.push(key);
                }
            });
        });
    }

    let onTrack = (event, otherKey) => {
        if (!otherKey) return;

        let existingWrapper = document.getElementById(`wrapper-${otherKey}`);
        let videoEl;
        if (!existingWrapper) {
            const wrapper = document.createElement('div');
            wrapper.className = 'video-wrapper';
            wrapper.id = `wrapper-${otherKey}`;

            const video = document.createElement('video');
            video.autoplay = true;
            video.controls = true;
            video.id = `video-${otherKey}`;
            wrapper.appendChild(video);
            videoEl = video;

            const label = document.createElement('div');
            label.className = 'label';
            label.innerText = 'other part';
            wrapper.appendChild(label);

            document.getElementById('remoteStreamDiv').appendChild(wrapper);
        } else {
            videoEl = document.getElementById(`video-${otherKey}`);
        }

        if (event.track.kind === 'video') {
            const newStream = new MediaStream([event.track]);
            videoEl.srcObject = newStream;
            remoteStream = newStream;
            if (localStream && remoteStream && !recordBtn.style.display) {
                recordBtn.style.display = '';
            }
        }
    };

    const createPeerConnection = (otherKey) => {
        const pc = new RTCPeerConnection();

        pc.addEventListener('icecandidate', (event) => {
            if (event.candidate) {
                stompClient.send('/app/peer/iceCandidate/' + otherKey + '/' + roomId, {}, JSON.stringify({
                    key: myKey,
                    body: event.candidate
                }));
            }
        });

        pc.addEventListener('track', (event) => {
            onTrack(event, otherKey);
        });

        if (localStream) {
            localStream.getTracks().forEach(track => {
                pc.addTrack(track, localStream);
            });
        }

        return pc;
    }

    let sendOffer = (pc, otherKey) => {
        pc.createOffer().then(offer => {
            pc.setLocalDescription(offer);
            stompClient.send('/app/peer/offer/' + otherKey + '/' + roomId, {}, JSON.stringify({
                key: myKey,
                body: offer
            }));
        });
    };

    let sendAnswer = (pc, otherKey) => {
        pc.createAnswer().then(answer => {
            pc.setLocalDescription(answer);
            stompClient.send('/app/peer/answer/' + otherKey + '/' + roomId, {}, JSON.stringify({
                key: myKey,
                body: answer
            }));
        });
    };

    document.querySelector('#enterRoomBtn').addEventListener('click', async () => {
        await startCam();
        if (localStream) {
            document.querySelector('#localWrapper').style.display = 'inline-block';
            document.querySelector('#startSteamBtn').style.display = '';
        }

        roomId = document.querySelector('#roomIdInput').value;
        document.querySelector('#roomIdInput').disabled = true;
        document.querySelector('#enterRoomBtn').disabled = true;

        await connectSocket();
    });

    document.querySelector('#startSteamBtn').addEventListener('click', async () => {
        stompClient.send(`/app/call/key`, {}, {});
        setTimeout(() => {
            otherKeyList.forEach((key) => {
                if (!pcListMap.has(key)) {
                    const pc = createPeerConnection(key);
                    pcListMap.set(key, pc);
                    sendOffer(pc, key);
                }
            });
        }, 1000);
    });

    recordBtn.addEventListener('click', () => {
        if (!isRecording) {
            startRecording();
        } else {
            stopRecording();
        }
    });

    function startRecording() {
        recordedChunks = [];
        const allTracks = [...localStream.getVideoTracks(), ...localStream.getAudioTracks(), ...remoteStream.getVideoTracks(), ...remoteStream.getAudioTracks()];
        const mixedStream = new MediaStream(allTracks);

        mediaRecorder = new MediaRecorder(mixedStream, {
            mimeType: 'video/webm;codecs=vp9,opus'
        });

        mediaRecorder.ondataavailable = (event) => {
            if (event.data.size > 0) {
                recordedChunks.push(event.data);
            }
        };

        mediaRecorder.onstop = () => {
            const blob = new Blob(recordedChunks, { type: 'video/webm' });
            const url = URL.createObjectURL(blob);
            const now = new Date().toISOString().replace(/:/g, '-');
            const a = document.createElement('a');
            a.href = url;
            a.download = `webrtc-recording-${now}.webm`;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
            recordBtn.innerText = 'Record';
            isRecording = false;
        };

        mediaRecorder.start(10);
        recordBtn.innerText = 'Stop Recording';
        isRecording = true;
    }

    function stopRecording() {
        if (mediaRecorder && mediaRecorder.state === 'recording') {
            mediaRecorder.stop();
        }
    }

    window.addEventListener('beforeunload', () => {
        if (stompClient && stompClient.connected) {
            stompClient.disconnect();
        }
        pcListMap.forEach(pc => pc.close());
        if (localStream) {
            localStream.getTracks().forEach(track => track.stop());
        }
        if (mediaRecorder && mediaRecorder.state === 'recording') {
            mediaRecorder.stop();
        }
    });
</script>

</body>
</html>


