<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>인터뷰 영상</title>
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
        }

        .file-link {
            display: block;
            width: 100%;
            padding: 15px;
            margin-bottom: 10px;
            font-size: 1.05rem;
            background-color: #ffffff;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            text-decoration: none;
            color: #333;
            transition: background-color 0.2s ease;
        }

        .file-link:hover {
            background-color: #e0f0ff;
        }

        .title {
            font-weight: bold;
            font-size: 1.4rem;
            margin-bottom: 20px;
            text-align: center;
        }
    </style>
</head>
<body>
<div class="container d-flex justify-content-center align-items-center vh-100">
    <div class="card p-4 shadow-lg" style="width: 500px;">
        <div class="title">면접 영상 목록</div>

        <c:forEach var="entry" items="${fileMap}">
            <a class="file-link" href="/video/watch?key=${entry.key}">
                ${entry.value}
            </a>
        </c:forEach>

    </div>
</div>
</body>
</html>
