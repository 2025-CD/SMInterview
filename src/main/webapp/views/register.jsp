<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>



<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        function updateJobCategories() {
            console.log("updateJobCategories 함수 실행됨!");
            const jobFieldId = document.getElementById("jobField").value;
            console.log("선택된 jobFieldId:", jobFieldId);

            const jobCategoryDiv = document.getElementById("jobCategoryDiv");
            const jobCategorySelect = document.getElementById("jobCategory");

            // 기존 옵션 초기화
            jobCategorySelect.innerHTML = '<option value="">선택</option>';

            if (!jobFieldId) {
                jobCategoryDiv.style.display = "none"; // 직종이 선택되지 않으면 숨김
                return;
            }

            $.ajax({
                url: "/getJobCategories",
                type: "GET",
                data: { jobFieldId: jobFieldId },
                dataType: "json",
                success: function(response) {
                    console.log("서버 응답:", response);

                    if (response.length > 0) {
                        response.forEach(category => {
                            const option = document.createElement("option");
                            option.value = category.jobcategoryid;  // 서버에서 받아온 ID 값
                            option.textContent = category.categoryName; // 서버에서 받아온 직군명
                            console.log("받아온 직군 ID:", category.jobcategoryid); // 추가된 콘솔 로그
                            console.log("받아온 직군명:", category.categoryName); // 추가된 콘솔 로그
                            jobCategorySelect.appendChild(option);
                        });
                        jobCategoryDiv.style.display = "block"; // 직군 선택창 보이기
                    } else {
                        jobCategoryDiv.style.display = "none"; // 데이터 없으면 숨김
                    }
                },
                error: function(xhr, status, error) {
                    console.error("AJAX 요청 실패:", status, error);
                }
            });
        }
    </script>
</head>
<body>
<div class="container d-flex justify-content-center align-items-center vh-100">
    <div class="card p-4 shadow-lg" style="width: 400px;">
        <h3 class="text-center mb-4">Sign Up</h3>
        <form action="/process-signup" method="POST">

            <div class="mb-3">
                <label for="id" class="form-label">ID</label>
                <input type="text" class="form-control" id="id" name="id" required>
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
<%--            <div class="mb-3">--%>
<%--                <label for="confirm-password" class="form-label">Confirm Password</label>--%>
<%--                <input type="password" class="form-control" id="confirm-password" name="confirmPassword" required>--%>
<%--            </div>--%>

            <!-- 역할 선택 -->
            <div class="mb-3">
            <label class="form-label">역할 선택</label><br>
            <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" name="role" value="1" required> <%-- value 변경 --%>
                <label class="form-check-label">멘토</label>
            </div>
            <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" name="role" value="2" required> <%-- value 변경, required는 하나만 있어도 됨 --%>
                <label class="form-check-label">멘티</label>
            </div>
            <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" name="role" value="0" required> <%-- value 변경 --%>
                <label class="form-check-label">선택 안 함</label>
            </div>
        </div>

            <!-- 직종 선택 -->
            <div class="mb-3">
                <label for="jobField" class="form-label">희망 직종</label>
                <select class="form-select" id="jobField" name="jobfieldid" onchange="updateJobCategories()">
                    <option value="">선택</option>
                    <c:forEach var="jobField" items="${jobFields}">
                        <option value="${jobField.jobfieldid}">${jobField.fieldName}</option>
                    </c:forEach>
                </select>
            </div>

            <!-- 직군 선택 (직종을 선택하면 나타남) -->
            <div class="mb-3" id="jobCategoryDiv" style="display: none;">
                <label for="jobCategory" class="form-label">희망 직군</label>
                <select class="form-select" id="jobCategory" name="jobcategoryid">
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
