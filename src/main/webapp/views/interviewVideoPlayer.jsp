<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>인터뷰 영상 재생</title>
</head>
<body>
    <h2>인터뷰 영상 보기</h2>
    <video width="640" height="480" controls autoplay>
        <source src="/video/view?key=${videoKey}" type="video/webm">
        브라우저가 video 태그를 지원하지 않습니다.
    </video>
</body>
</html>
