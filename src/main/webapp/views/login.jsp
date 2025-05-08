<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Mock UP 로그인</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #dfefff, #f0f5ff);
            font-family: 'Segoe UI', sans-serif;
        }

        .login-card {
            background-color: #fff;
            padding: 30px;
            border-radius: 12px;
            width: 380px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
        }

        .btn-login {
            background-color: #007bff;
            color: white;
        }

        .btn-login:hover {
            background-color: #0056b3;
        }

        .btn-kakao {
            background-color: #FEE500;
            color: #3C1E1E;
            font-weight: bold;
        }

        .btn-kakao:hover {
            background-color: #ffd900;
        }

        .ai-icon {
            transition: transform 0.3s ease-in-out;
        }

        .ai-icon:hover {
            transform: scale(1.2) rotate(8deg);
        }

        .error-msg {
            color: red;
            font-size: 0.9rem;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
<div class="container d-flex flex-column justify-content-center align-items-center vh-100">

    <!-- 상단 로고 영역 -->
    <div class="text-center mb-4">
        <i class="fas fa-robot fa-3x text-primary mb-2 ai-icon"></i>
        <h5 class="text-primary fw-semibold">AI와 함께하는 스마트한 모의면접</h5>
    </div>

    <!-- 로그인 카드 -->
    <div class="login-card">
        <div class="login-header text-center mb-4">
            <h2><i class="fas fa-user-circle me-2"></i>Mock UP 로그인</h2>
            <p class="text-muted" style="font-size: 0.95rem;">AI 기반 모의면접 플랫폼</p>
        </div>

        <!-- 로그인 에러 메시지 -->
        <c:if test="${not empty loginError}">
            <div class="error-msg text-center">${loginError}</div>
        </c:if>

        <!-- 로그인 폼 (컨트롤러에 맞춰 action 수정) -->
        <form action="/loginimpl" method="post">
            <div class="mb-3">
                <label for="id" class="form-label">아이디</label>
                <input type="text" class="form-control" id="id" name="id" required>
            </div>
            <div class="mb-3">
                <label for="password" class="form-label">비밀번호</label>
                <input type="password" class="form-control" id="password" name="password" required>
            </div>
            <button type="submit" class="btn btn-login w-100 mb-3">로그인</button>
        </form>

        <hr>
        <a href="/oauth2/authorization/kakao" class="btn btn-kakao w-100">Kakao 로그인</a>
    </div>
</div>
</body>
</html>
