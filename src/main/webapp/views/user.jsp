<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>사용자 정보</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2 class="mb-4">로그인 성공!</h2>
    <p>카카오에서 가져온 사용자 정보:</p>
    <pre>${userInfo}</pre>
    <a href="/" class="btn btn-primary">홈으로 이동</a>
</div>
</body>
</html>
