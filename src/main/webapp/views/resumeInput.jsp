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
    <style>
        /* Custom Styles  */
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


        .analysis-result {
            margin-top: 30px;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 8px;
        }


        .analysis-result h2 {
            color: #555;
            font-size: 1.5em;
            margin-bottom: 15px;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }


        .result-content {
            /* Style for displaying analysis results  */
        }


        /* Responsive Design  */
        @media (max-width: 768px) {
            .main-content {
                width: 95%;
            }
            .analysis-form {
                flex-direction: column;
            }
            .form-card {
                width: 100%;
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
            <h2>파일 업로드</h2>
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
                <button type="submit" class="btn btn-primary submit-button">파일 업로드 및 분석</button>
            </form>
        </div>


        <div class="form-card text-form">
            <h2>텍스트 직접 입력</h2>
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
                <button type="submit" class="btn btn-primary submit-button">텍스트 분석</button>
            </form>
        </div>
    </section>


    <section class="analysis-result">
        <h2>분석 결과</h2>
        <div id="resultContent" class="result-content">
        </div>
    </section>
</div>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    //  Your existing JavaScript
    document.getElementById('uploadForm').addEventListener('submit', function(event) {
    });


    document.getElementById('textForm').addEventListener('submit', function(event) {
    });
</script>
</body>
</html>