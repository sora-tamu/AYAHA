<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Question, dao.BookmarkDAO, model.User" %>
<%-- 1. XSS対策(JSTL)の導入 --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    BookmarkDAO bDAO = new BookmarkDAO();
    List<Question> bookmarkedList = bDAO.getBookmarkedQuestions(loginUser.getId());
    // JSTLで扱うためにリクエストスコープにセット
    request.setAttribute("bookmarkedList", bookmarkedList);
%>
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="../css/style.css">
    <title>お気に入り問題 - ちょこり</title>
</head>
<body>
    <div class="container">
        <h2>❤️ お気に入り問題</h2>
        
        <c:choose>
            <c:when test="${empty bookmarkedList}">
                <p style="text-align: center; color: #999;">お気に入りの問題はまだありません。</p>
            </c:when>
            <c:otherwise>
                <c:forEach var="q" items="${bookmarkedList}">
                    <div style="border-bottom: 1px solid #eee; padding: 15px 0; display: flex; justify-content: space-between;">
                        <%-- 対策(XSS): タイトルを安全にエスケープ表示 --%>
                        <strong><c:out value="${q.title}" /></strong>
                        
                        <%-- 対策(SQLi/XSS): URLパラメータを安全に構築 --%>
                        <a href="AnswerServlet?id=${q.id}" class="btn btn-primary" style="font-size: 0.8em;">解く</a>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
        
        <p style="text-align: center; margin-top: 20px;"><a href="main.jsp">メニューに戻る</a></p>
    </div>
    <jsp:include page="memo_popup.jsp" />
</body>
</html>