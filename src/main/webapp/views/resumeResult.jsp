<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI 이력서 분석 결과</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #dfefff, #f0f5ff);
            color: #333;
            margin: 0;
            padding: 0;
        }
        .main-content {
            max-width: 960px;
            margin: 40px auto;
            background-color: #fff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
        }
        .page-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .page-header h1 {
            font-size: 2.2rem;
            color: #2c3e50;
        }
        .page-description {
            color: #6c757d;
        }
        .analysis-result {
            margin-top: 20px;
            background-color: #f8fbff;
            border: 1px solid #dee2e6;
            border-radius: 10px;
            padding: 25px;
        }
        .analysis-result h2 {
            font-size: 1.5rem;
            border-bottom: 1px solid #ccc;
            margin-bottom: 20px;
            color: #333;
        }
        .category-result {
            background-color: #ffffff;
            border: 1px solid #e3e6ea;
            border-left: 5px solid #0d6efd;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .category-result h3 {
            color: #0d6efd;
            font-size: 1.2rem;
            margin-bottom: 15px;
        }
        .category-result strong {
            color: #333;
            font-weight: 600;
        }
        .category-result p {
            margin-bottom: 12px;
            padding-left: 12px;
            border-left: 3px solid #ffc107;
            background-color: #fef9e7;
            padding: 10px;
            border-radius: 4px;
        }
        .result-actions {
            margin-top: 30px;
            text-align: center;
        }
        .result-actions a {
            display: inline-block;
            margin: 0 8px;
            padding: 10px 20px;
            font-size: 1rem;
            border-radius: 6px;
            text-decoration: none;
            color: #fff;
        }
        .result-actions a:first-child {
            background-color: #0d6efd;
        }
        .result-actions a:first-child:hover {
            background-color: #0b5ed7;
        }
        .result-actions a:last-child {
            background-color: #6c757d;
        }
        .result-actions a:last-child:hover {
            background-color: #5a6268;
        }
        @media (max-width: 768px) {
            .main-content {
                margin: 20px;
                padding: 20px;
            }
        }
    </style>
</head>
<body>
<div class="container main-content">
    <header class="page-header">
        <h1><i class="fas fa-chart-line me-2"></i>AI 이력서 분석 결과</h1>
        <p class="lead page-description">제출하신 이력서에 대한 AI 분석 결과 및 최적화 제안입니다.</p>
    </header>

    <section class="analysis-result">
        <h2><i class="fas fa-lightbulb me-2"></i>분석 상세 내용</h2>

        <div id="resultContent" class="result-content">
            <c:if test="${not empty analysisResult}">
                <c:forEach var="categoryEntry" items="${analysisResult}">
                    <div class="category-result">
                        <h3>${categoryEntry.key}</h3>
                        <div>
                            <strong>분석:</strong>
                            <p>${categoryEntry.value['분석']}</p>
                        </div>
                        <div>
                            <strong>개선 제안:</strong>
                            <p>${categoryEntry.value['개선 제안']}</p>
                        </div>
                    </div>
                </c:forEach>
            </c:if>
            <c:if test="${empty analysisResult}">
                <p>분석 결과가 없습니다. 다시 시도해주세요.</p>
            </c:if>
        </div>
    </section>

    <div class="result-actions">
        <a href="/resume/input"><i class="fas fa-redo me-1"></i>다시 분석하기</a>
        <a href="/"><i class="fas fa-home me-1"></i>홈으로 돌아가기</a>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
