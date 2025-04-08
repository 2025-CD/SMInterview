<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>사용자 정보</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2 class="mb-4">로그인 성공!</h2>

    <%-- 세션 값 확인 --%>
    <c:if test="${not empty sessionScope.user}">
        <p>현재 로그인한 사용자 ID: ${sessionScope.user}</p>
    </c:if>
    <c:if test="${empty sessionScope.user}">
        <p>세션에 저장된 사용자가 없습니다.</p>
    </c:if>

    <%-- 카카오에서 가져온 사용자 정보 표시 --%>
    <p>카카오에서 가져온 사용자 정보:</p>
    <pre>${userInfo}</pre>

    <a href="/" class="btn btn-primary">홈으로 이동</a>
</div>
</body>
</html>