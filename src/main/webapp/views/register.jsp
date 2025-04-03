<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script>
        function updateJobCategories() {
            const jobField = document.getElementById("jobField").value;
            const jobCategoryDiv = document.getElementById("jobCategoryDiv");
            const jobCategorySelect = document.getElementById("jobCategory");

            const jobCategories = {
                "IT": ["백엔드", "프론트엔드", "클라우드", "데이터 엔지니어"],
                "금융": ["애널리스트", "투자은행", "회계사", "재무 관리자"],
                "제조": ["생산관리", "품질관리", "기계설계", "자동화 엔지니어"]
            };

            // 기존 옵션 제거
            jobCategorySelect.innerHTML = '<option value="">선택</option>';

            // 선택한 직군에 따라 옵션 추가
            if (jobCategories[jobField]) {
                jobCategories[jobField].forEach(category => {
                    const option = document.createElement("option");
                    option.value = category;
                    option.textContent = category;
                    jobCategorySelect.appendChild(option);
                });
                jobCategoryDiv.style.display = "block"; // 보이도록 설정
            } else {
                jobCategoryDiv.style.display = "none"; // 숨김 처리
            }
        }
    </script>
</head>
<body>
<div class="container d-flex justify-content-center align-items-center vh-100">
    <div class="card p-4 shadow-lg" style="width: 400px;">
        <h3 class="text-center mb-4">Sign Up</h3>
        <form action="/process-signup" method="POST">

            <div class="mb-3">
                <label for="userid" class="form-label">ID</label>
                <input type="text" class="form-control" id="userid" name="userid" required>
            </div>
            <div class="mb-3">
                <label for="username" class="form-label">Name</label>
                <input type="text" class="form-control" id="username" name="username" required>
            </div>
            <div class="mb-3">
                <label for="email" class="form-label">Email</label>
                <input type="email" class="form-control" id="email" name="email" required>
            </div>
            <div class="mb-3">
                <label for="password" class="form-label">Password</label>
                <input type="password" class="form-control" id="password" name="password" required>
            </div>
            <div class="mb-3">
                <label for="confirm-password" class="form-label">Confirm Password</label>
                <input type="password" class="form-control" id="confirm-password" name="confirmPassword" required>
            </div>

            <!-- 역할 선택 -->
            <div class="mb-3">
                <label class="form-label">역할 선택</label><br>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="role" value="mentor" required>
                    <label class="form-check-label">멘토</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="role" value="mentee">
                    <label class="form-check-label">멘티</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="role" value="none">
                    <label class="form-check-label">선택 안 함</label>
                </div>
            </div>

            <!-- 직종 선택 -->
            <div class="mb-3">
                <label for="jobField" class="form-label">희망 직종</label>
                <select class="form-select" id="jobField" name="jobField" onchange="updateJobCategories()">
                    <option value="">선택</option>
                    <option value="IT">IT</option>
                    <option value="금융">금융</option>
                    <option value="제조">제조</option>
                </select>
            </div>

            <!-- 직군 선택 (직종을 선택하면 나타남) -->
            <div class="mb-3" id="jobCategoryDiv" style="display: none;">
                <label for="jobCategory" class="form-label">희망 직군</label>
                <select class="form-select" id="jobCategory" name="jobCategory">
                    <option value="">선택</option>
                </select>
            </div>

            <button type="submit" class="btn btn-primary w-100">Sign Up</button>
        </form>
        <p class="text-center mt-3">
            Already have an account? <a href="/login">Login here</a>
        </p>
    </div>
</div>
</body>
</html>
