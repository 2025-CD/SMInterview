<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>이력서 분석 및 최적화</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <style>
        .container {
            margin-top: 50px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .analysis-item {
            margin-bottom: 15px;
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 5px;
        }
        .analysis-item h4 {
            margin-top: 0;
            margin-bottom: 10px;
        }
        .analysis-item strong {
            font-weight: bold;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>이력서 분석 및 최적화</h2>
    <p class="lead">이력서를 업로드하거나 직접 입력하여 AI의 분석 및 최적화 제안을 받아보세요.</p>

    <div class="card mb-3">
        <div class="card-header">파일 업로드</div>
        <div class="card-body">
            <form id="uploadForm" action="/resume/result" method="post" enctype="multipart/form-data">
                <c:if test="${_csrf != null}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </c:if>
                <div class="form-group">
                    <label for="resumeFile" class="form-label">이력서 파일 선택 (PDF, DOC, DOCX 등)</label>
                    <input type="file" class="form-control" id="resumeFile" name="resumeFile">
                </div>
                <div class="form-group">
                    <label for="targetJobFile" class="form-label">목표 직무 선택</label>
                    <select class="form-select" id="targetJobFile" name="targetJob">
                        <option value="">-- 선택하세요 --</option>
                        <option value="소프트웨어 엔지니어 (백엔드)">소프트웨어 엔지니어 (백엔드)</option>
                        <option value="소프트웨어 엔지니어 (프론트엔드)">소프트웨어 엔지니어 (프론트엔드)</option>
                        <option value="데이터 분석가">데이터 분석가</option>
                        <option value="웹 개발자">웹 개발자</option>
                        <option value="마케팅 담당자">마케팅 담당자</option>
                        <option value="기획자">기획자</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">파일 업로드 및 분석</button>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="card-header">텍스트 직접 입력</div>
        <div class="card-body">
            <form id="textForm" action="/resume/result" method="post">
                <c:if test="${_csrf != null}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </c:if>
                <div class="form-group">
                    <label for="resumeText" class="form-label">이력서 텍스트를 직접 입력해주세요.</label>
                    <textarea class="form-control" id="resumeText" name="resumeText" rows="10"></textarea>
                </div>
                <div class="form-group">
                    <label for="targetJobText" class="form-label">목표 직무 선택</label>
                    <select class="form-select" id="targetJobText" name="targetJob">
                        <option value="">-- 선택하세요 --</option>
                        <option value="소프트웨어 엔지니어 (백엔드)">소프트웨어 엔지니어 (백엔드)</option>
                        <option value="소프트웨어 엔지니어 (프론트엔드)">소프트웨어 엔지니어 (프론트엔드)</option>
                        <option value="데이터 분석가">데이터 분석가</option>
                        <option value="웹 개발자">웹 개발자</option>
                        <option value="마케팅 담당자">마케팅 담당자</option>
                        <option value="기획자">기획자</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">텍스트 분석</button>
            </form>
        </div>
    </div>

    <div id="analysisResult" class="mt-4">
        <h3>분석 결과</h3>
        <div id="resultContent">
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 기존 JavaScript 코드는 결과 페이지로 이동하므로 더 이상 필요하지 않습니다.
    // 필요하다면 submit 이벤트만 남겨두고 fetch 부분을 제거해도 됩니다.
    document.getElementById('uploadForm').addEventListener('submit', function(event) {
        // Submit 이벤트는 그대로 둡니다.
    });

    document.getElementById('textForm').addEventListener('submit', function(event) {
        // Submit 이벤트는 그대로 둡니다.
    });
</script>
</body>
</html>