<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container d-flex justify-content-center align-items-center vh-100">
    <div class="card p-4 shadow-lg" style="width: 400px;">
        <h3 class="text-center mb-4">로그인</h3>
        <a href="/oauth2/authorization/google" class="btn btn-danger w-100 mb-2">Google 로그인</a>
        <a href="/oauth2/authorization/naver" class="btn btn-success w-100 mb-2">Naver 로그인</a>
        <a href="/oauth2/authorization/kakao" class="btn btn-warning w-100 mb-2">Kakao 로그인</a>
        <p class="text-center mt-3">
            계정이 없나요? <a href="/register">회원가입</a>
        </p>
    </div>
</div>
</body>
</html>
