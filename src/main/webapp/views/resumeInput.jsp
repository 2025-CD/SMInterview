<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI 이력서 분석 및 최적화</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            font-family: 'Noto Sans KR', sans-serif;
            background: linear-gradient(135deg, #f2f7fd, #e0f0ff);
            color: #333;
            line-height: 1.6;
            margin: 0;
            padding: 0;
        }

        .main-content {
            width: 90%;
            max-width: 1200px;
            margin: 30px auto;
            background-color: #fff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }

        .page-header {
            text-align: center;
            padding-bottom: 20px;
            margin-bottom: 30px;
            position: relative;
        }

        .page-header h1 {
            font-size: 2.2em;
            font-weight: 700;
            color: #2c3e50;
        }

        .page-header h1::after {
            content: '';
            display: block;
            width: 60px;
            height: 3px;
            background-color: #3498db;
            margin: 12px auto 0;
        }

        .page-description {
            color: #555;
            font-size: 1.05em;
        }

        .analysis-form {
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 20px;
        }

        .form-card {
            flex: 1;
            min-width: 300px;
            background: #fefefe;
            padding: 20px;
            border: 1px solid #dee2e6;
            border-radius: 12px;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.02);
        }

        .form-card h2 {
            font-size: 1.4em;
            color: #2c3e50;
            margin-bottom: 20px;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }

        .form-label {
            font-weight: 600;
            color: #444;
            margin-bottom: 6px;
        }

        .input-file, .input-textarea, .select-job {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 1em;
        }

        .input-textarea {
            resize: vertical;
            min-height: 160px;
        }

        .submit-button {
            background-color: #3498db;
            color: white;
            padding: 10px 18px;
            border: none;
            border-radius: 6px;
            font-size: 1em;
            transition: background-color 0.3s;
        }

        .submit-button:hover {
            background-color: #2c80b4;
        }

        .analysis-result {
            margin-top: 40px;
            padding: 20px;
            border: 1px solid #ccc;
            border-radius: 10px;
            background-color: #f8f9fa;
        }

        .analysis-result h2 {
            font-size: 1.5em;
            color: #333;
            margin-bottom: 15px;
        }

        @media (max-width: 768px) {
            .analysis-form {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
<div class="container main-content">
    <header class="page-header">
        <h1>AI 이력서 분석 및 최적화</h1>
        <p class="lead page-description">이력서를 업로드하거나 직접 입력하여 AI의 분석 및 최적화 제안을 받아보세요.</p>
    </header>

    <section class="analysis-form">
        <div class="form-card upload-form">
            <h2><i class="fas fa-file-upload"></i> 파일 업로드</h2>
            <form id="uploadForm" action="/resume/result" method="post" enctype="multipart/form-data">
                <c:if test="${_csrf != null}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </c:if>
                <div class="form-group">
                    <label for="resumeFile" class="form-label">이력서 파일 선택 (PDF, DOC, DOCX 등)</label>
                    <input type="file" class="form-control input-file" id="resumeFile" name="resumeFile">
                </div>
                <div class="form-group">
                    <label for="targetJobFile" class="form-label">목표 직무 선택</label>
                    <select class="form-select select-job" id="targetJobFile" name="targetJob">
                        <option value="">-- 선택하세요 --</option>
                        <option value="소프트웨어 엔지니어 (백엔드)">소프트웨어 엔지니어 (백엔드)</option>
                        <option value="소프트웨어 엔지니어 (프론트엔드)">소프트웨어 엔지니어 (프론트엔드)</option>
                        <option value="데이터 분석가">데이터 분석가</option>
                        <option value="웹 개발자">웹 개발자</option>
                        <option value="마케팅 담당자">마케팅 담당자</option>
                        <option value="기획자">기획자</option>
                    </select>
                </div>
                <button type="submit" class="submit-button"><i class="fas fa-upload"></i> 파일 업로드 및 분석</button>
            </form>
        </div>

        <div class="form-card text-form">
            <h2><i class="fas fa-keyboard"></i> 텍스트 직접 입력</h2>
            <form id="textForm" action="/resume/result" method="post">
                <c:if test="${_csrf != null}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </c:if>
                <div class="form-group">
                    <label for="resumeText" class="form-label">이력서 텍스트를 직접 입력해주세요.</label>
                    <textarea class="form-control input-textarea" id="resumeText" name="resumeText" rows="10"></textarea>
                </div>
                <div class="form-group">
                    <label for="targetJobText" class="form-label">목표 직무 선택</label>
                    <select class="form-select select-job" id="targetJobText" name="targetJob">
                        <option value="">-- 선택하세요 --</option>
                        <option value="소프트웨어 엔지니어 (백엔드)">소프트웨어 엔지니어 (백엔드)</option>
                        <option value="소프트웨어 엔지니어 (프론트엔드)">소프트웨어 엔지니어 (프론트엔드)</option>
                        <option value="데이터 분석가">데이터 분석가</option>
                        <option value="웹 개발자">웹 개발자</option>
                        <option value="마케팅 담당자">마케팅 담당자</option>
                        <option value="기획자">기획자</option>
                    </select>
                </div>
                <button type="submit" class="submit-button"><i class="fas fa-magic"></i> 텍스트 분석</button>
            </form>
        </div>
    </section>

    <section class="analysis-result">
        <h2><i class="fas fa-chart-line"></i> 분석 결과</h2>
        <div id="resultContent" class="result-content">
        </div>
    </section>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('uploadForm').addEventListener('submit', function(event) {});
    document.getElementById('textForm').addEventListener('submit', function(event) {});
</script>
</body>
</html>
