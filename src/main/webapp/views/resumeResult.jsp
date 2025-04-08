<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>이력서 분석 결과</title>
</head>
<body>
<h1>이력서 분석 결과</h1>
<hr>

<c:if test="${not empty analysisResult}">
    <c:forEach var="category" items="${analysisResult}">
        <div>
            <h2>${category.key}</h2>
            <div>
                <strong>분석:</strong>
                <p>${category.value['분석']}</p> <%-- 수정: 점(.) 대신 대괄호([]) 사용 --%>
            </div>
            <div>
                <strong>개선 제안:</strong>
                <p>${category.value['개선 제안']}</p> <%-- 수정: 점(.) 대신 대괄호([]) 사용 --%>
            </div>
            <hr>
        </div>
    </c:forEach>
</c:if>

<c:if test="${empty analysisResult}">
    <p>분석 결과가 없습니다.</p>
</c:if>

<br>
<a href="/resume/input">다시 분석하기</a>
<a href="/">홈으로 돌아가기</a>
</body>
</html>