<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <title>Mockup AI 모의면접 플랫폼</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet" />
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #dfefff, #f0f5ff);
            color: #333;
            margin: 0;
            padding: 0;
        }

        .hero {
            background: linear-gradient(to right, #5fa8d3, #bee9e8);
            color: white;
            padding: 100px 0;
            text-align: center;
        }
        .section-title {
            font-size: 2rem;
            color: #2c3e50;
            margin-bottom: 1rem;
        }
        .feature-icon {
            font-size: 3rem;
            color: #007bff;
            margin-bottom: 1rem;
        }
        .footer {
            background-color: #f8f9fa;
            padding: 40px 0;
            text-align: center;
        }
        .card:hover {
            background-color: #e9f5ff;
            cursor: pointer;
            transition: background-color 0.3s ease-in-out;
        }
    </style>
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold" href="/">Mockup</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto">

                <li class="nav-item"><a class="nav-link" href="/resume/input">이력서 분석</a></li>
                <li class="nav-item"><a class="nav-link" href="/aiinterview">AI 모의면접</a></li>
                <li class="nav-item"><a class="nav-link" href="/interview">화상 면접</a></li>
                <c:if test="${not empty sessionScope.nickname}">
                    <li class="nav-item"><a class="nav-link" href="/mypage">마이페이지</a></li>
                </c:if>
                <c:choose>
                    <c:when test="${empty sessionScope.user}">
                        <li class="nav-item"><a class="nav-link" href="/login">로그인</a></li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item"><span class="nav-link">${sessionScope.nickname}님</span></li>
                        <li class="nav-item"><a class="nav-link" href="/logout">로그아웃</a></li>
                    </c:otherwise>

                </c:choose>
            </ul>
        </div>
    </div>
</nav>

<header class="hero">
    <div class="container">
        <h1 class="display-4 fw-bold">AI 모의면접으로 준비된 면접을 시작하세요</h1>
        <p class="lead">실전처럼 연습하고, 실력처럼 피드백 받으세요.</p>
        <a href="/aiinterview" class="btn btn-light btn-lg mt-3">AI 면접 시작하기</a>
    </div>
</header>

<section class="py-5">
    <div class="container">
        <h2 class="section-title text-center">Mockup 주요 기능</h2>
        <div class="row text-center mt-4">
            <div class="col-md-4">
                <div class="card p-4" onclick="location.href='/resume/input'">
                    <i class="bi bi-file-earmark-text feature-icon"></i>
                    <h5 class="fw-bold">이력서 분석 및 최적화</h5>
                    <p>AI가 이력서를 분석하고 개선 방향을 제시합니다.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card p-4" onclick="location.href='/aiinterview'">
                    <i class="bi bi-robot feature-icon"></i>
                    <h5 class="fw-bold">AI 모의 면접</h5>
                    <p>실시간 음성 질문 및 답변, 피드백을 제공합니다.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card p-4" onclick="location.href='/interview'">
                    <i class="bi bi-camera-video feature-icon"></i>
                    <h5 class="fw-bold">화상 면접 시스템</h5>
                    <p>사람과 사람 간의 랜덤 또는 지정 면접 매칭 기능을 제공합니다.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<section class="footer">
    <div class="container">
        <h5 class="mb-3">Mockup 위치 안내</h5>
        <div class="mb-3">
            <div id="map" style="height: 300px; width: 100%; border: 1px solid #ccc; border-radius: 8px;"></div>
        </div>
        <p class="text-muted">© 2025 Mockup Inc. All rights reserved.</p>
    </div>
</section>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=YOUR_KAKAO_API_KEY"></script>
<script>
    kakao.maps.load(function () {
        const container = document.getElementById('map');
        const options = {
            center: new kakao.maps.LatLng(37.5665, 126.9780),
            level: 3
        };
        const map = new kakao.maps.Map(container, options);

        const marker = new kakao.maps.Marker({
            position: new kakao.maps.LatLng(37.5665, 126.9780),
            map: map
        });
    });
</script>
</body>
</html>