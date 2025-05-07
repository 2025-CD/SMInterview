<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI 이력서 분석 결과</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <style>
        /* Custom Styles - Input 페이지와 동일 */
        body {
            font-family: sans-serif;
            background-color: #f8f8f8;
            color: #333;
            line-height: 1.6;
            margin: 0;
            padding: 0;
        }

        .main-content {
            width: 80%;
            margin: 20px auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }

        .page-header {
            text-align: center;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
            margin-bottom: 20px;
        }

        .page-header h1 {
            color: #444;
            font-size: 2em;
            margin-bottom: 10px;
        }

        .page-description {
            color: #777;
            font-size: 1.1em;
        }

        /* analysis-form 스타일은 결과 페이지에서 필요 없지만, 전체 스타일 일관성을 위해 남겨둡니다 */
        .analysis-form {
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
        }

        .form-card {
            width: 48%;
            margin-bottom: 20px;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 8px;
        }

        .form-card h2 {
            color: #555;
            font-size: 1.5em;
            margin-bottom: 15px;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-label {
            display: block;
            margin-bottom: 5px;
            color: #666;
            font-weight: bold;
        }

        .input-file, .input-textarea, .select-job {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 1em;
        }

        .input-textarea {
            resize: vertical;
        }

        .submit-button {
            background-color: #e67e22;  /* Orange */
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1.1em;
            transition: background-color 0.3s ease;
        }

        .submit-button:hover {
            background-color: #d35400;  /* Darker orange */
        }

        /* analysis-result 스타일 - 결과 내용 표시 영역 */
        .analysis-result {
            margin-top: 30px;
            padding: 20px; /* 결과 영역 자체에 패딩 적용 */
            border: 1px solid #ddd; /* 결과 영역 전체에 테두리 적용 */
            border-radius: 8px; /* 결과 영역 전체에 둥근 모서리 적용 */
            background-color: #fff; /* 배경색 */
        }

        .analysis-result h2 {
            color: #555;
            font-size: 1.5em;
            margin-bottom: 20px; /* 제목 아래 간격 늘림 */
            border-bottom: 1px solid #eee; /* 제목 아래 구분선 */
            padding-bottom: 10px;
        }

        /* 개별 카테고리 결과 스타일 */
        .category-result {
            margin-bottom: 20px; /* 각 카테고리 블록 하단 간격 */
            padding: 15px; /* 각 카테고리 블록 내부 패딩 */
            border: 1px solid #eee; /* 각 카테고리 블록 테두리 */
            border-radius: 6px; /* 각 카테고리 블록 둥근 모서리 */
            background-color: #f9f9f9; /* 각 카테고리 블록 배경색 */
        }

        .category-result h3 {
            color: #666;
            font-size: 1.3em;
            margin-top: 0;
            margin-bottom: 10px; /* 카테고리 제목 아래 간격 */
            border-bottom: 1px dashed #ccc; /* 카테고리 제목 아래 점선 */
            padding-bottom: 5px;
        }

        .category-result strong {
            color: #444;
            display: block; /* 라벨을 블록 요소로 만들어 다음 내용과 분리 */
            margin-bottom: 5px;
            font-size: 1.1em;
        }

        .category-result p {
            margin-bottom: 10px;
            padding-left: 10px; /* 내용 들여쓰기 */
            border-left: 3px solid #e67e22; /* 좌측에 오렌지색 선 */
            padding-left: 10px; /* 들여쓰기 */
        }
        .category-result p:last-child {
            margin-bottom: 0; /* 마지막 단락 하단 마진 제거 */
        }

        .result-actions {
            margin-top: 20px;
            text-align: center;
        }

        .result-actions a {
            display: inline-block;
            margin: 0 10px;
            padding: 10px 15px;
            background-color: #5cb85c; /* Success green */
            color: white;
            border-radius: 5px;
            text-decoration: none;
            transition: background-color 0.3s ease;
        }

        .result-actions a:hover {
            background-color: #4cae4c; /* Darker green */
        }
        .result-actions a:last-child {
            background-color: #f0ad4e; /* Warning yellow */
        }
        .result-actions a:last-child:hover {
            background-color: #ec971f; /* Darker yellow */
        }


        /* Responsive Design */
        @media (max-width: 768px) {
            .main-content {
                width: 95%;
            }
            .analysis-form { /* 결과 페이지에서는 이 스타일은 사용되지 않음 */
                flex-direction: column;
            }
            .form-card { /* 결과 페이지에서는 이 스타일은 사용되지 않음 */
                width: 100%;
            }
            .category-result {
                padding: 10px;
            }
            .category-result p {
                padding-left: 5px;
                border-left: 2px solid #e67e22;
            }
        }
    </style>
</head>
<body>
<div class="container main-content">
    <header class="page-header">
        <h1>AI 이력서 분석 결과</h1>
        <p class="lead page-description">제출하신 이력서에 대한 AI 분석 결과 및 최적화 제안입니다.</p>
    </header>

    <section class="analysis-result">
        <h2>분석 상세 내용</h2>

        <div id="resultContent" class="result-content">
            <c:if test="${not empty analysisResult}">
                <c:forEach var="categoryEntry" items="${analysisResult}">
                    <%-- 각 카테고리를 별도의 div로 감싸서 스타일 적용 --%>
                    <div class="category-result">
                            <%-- 카테고리 제목 --%>
                        <h3>${categoryEntry.key}</h3>

                            <%-- 분석 내용 --%>
                        <div>
                            <strong>분석:</strong>
                            <p>${categoryEntry.value['분석']}</p>
                        </div>

                            <%-- 개선 제안 --%>
                        <div>
                            <strong>개선 제안:</strong>
                            <p>${categoryEntry.value['개선 제안']}</p>
                        </div>
                    </div> <%-- .category-result end --%>
                </c:forEach>
            </c:if>

            <c:if test="${empty analysisResult}">
                <p>분석 결과가 없습니다. 다시 시도해주세요.</p>
            </c:if>
        </div> <%-- #resultContent end --%>
    </section>

    <div class="result-actions">
        <a href="/resume/input">다시 분석하기</a>
        <a href="/">홈으로 돌아가기</a>
    </div>

</div> <%-- .main-content end --%>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<%-- Marked.js는 결과 내용이 Markdown일 경우 사용합니다. --%>
<%-- 현재 코드는 일반 텍스트로 가정하고 있으나, 필요시 Marked.js를 사용하도록 수정 가능합니다. --%>
<%--
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const resultContentDiv = document.getElementById('resultContent');
        // 서버에서 받은 결과 텍스트가 Markdown 형식이라면
        // resultContentDiv.innerHTML = marked.parse(resultContentDiv.innerText);
        // 이 코드를 사용하여 Markdown을 HTML로 변환할 수 있습니다.
        // 단, XSS 공격에 취약해질 수 있으므로 주의가 필요합니다.
        // 서버에서 HTML로 변환하여 전달하는 것이 더 안전합니다.
    });
</script>
--%>
</body>
</html>