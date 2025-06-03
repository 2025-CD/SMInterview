<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>마이페이지</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #dfefff, #f0f5ff);
            color: #333;
            margin: 0;
            padding: 0;
        }

        .card {
            transition: background-color 0.3s ease-in-out;
        }

        .card:hover {
            background-color: #e9f5ff;
            cursor: pointer;
        }

        .btn-category {
            width: 100%;
            margin-bottom: 15px;
            padding: 15px;
            font-size: 1.1rem;
            background-color: #ffffff;
            border: 1px solid #dee2e6;
            transition: background-color 0.2s ease;
        }

        .btn-category:hover {
            background-color: #e0f0ff;
        }

        .profile-box {
            text-align: center;
            margin-bottom: 20px;
        }

        .profile-box img {
            width: 100px;
            height: 100px;
            object-fit: cover;
            border-radius: 50%;
            margin-bottom: 10px;
            border: 3px solid #bee9e8;
        }

        .profile-name {
            font-weight: bold;
            font-size: 1.2rem;
        }

        .profile-id {
            color: #666;
            font-size: 0.95rem;
        }
    </style>
</head>
<body>
<div class="container d-flex justify-content-center align-items-center vh-100">
    <div class="card p-4 shadow-lg" style="width: 400px;">
        <div class="profile-box">
            <div class="profile-name">${nickname}</div>
            <div class="profile-id">@${sessionScope.loginid.id}</div>
        </div>


        <a href="/user" class="btn btn-category">회원수정</a>
        <a href="/files" class="btn btn-category">이력서 분석 결과</a>
        <a href="/interview/mock" class="btn btn-category">AI 면접 내용</a>
        <a href="/interview/ai" class="btn btn-category">화상 면접 내용</a>
    </div>
</div>
</body>
</html>
