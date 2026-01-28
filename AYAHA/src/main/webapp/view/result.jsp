<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Question, model.User, dao.BookmarkDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    Question question = (Question) request.getAttribute("question");
    if (question != null && loginUser != null) {
        BookmarkDAO bDAO = new BookmarkDAO();
        boolean isLiked = bDAO.isBookmarked(loginUser.getId(), question.getId());
        request.setAttribute("isLiked", isLiked);
    }
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <title>結果発表 - ちょこり</title>
    <style>
        body { background-color: #1a1a2e; color: #fff; font-family: sans-serif; }
        .result-container { text-align: center; max-width: 600px; margin: 0 auto; padding: 40px 20px; }
        .answer-box { background: rgba(255,255,255,0.1); padding: 20px; border-radius: 12px; margin: 20px 0; }
        .btn-next { background: #3498db; color: white !important; padding: 15px 40px; text-decoration: none; border-radius: 8px; font-weight: bold; width: 80%; display: block; margin: 20px auto; font-size: 1.1rem; }
        .btn-menu { background: #7f8c8d; color: white !important; padding: 10px 25px; text-decoration: none; border-radius: 5px; display: inline-block; margin-top: 20px; }
        .btn-fav { padding: 10px 20px; border-radius: 30px; text-decoration: none; display: inline-block; margin: 10px 0; font-weight: bold; }
        .fav-add { background: rgba(255,255,255,0.2); border: 1px solid #fff; color: #fff !important; }
        .fav-remove { background: #e74c3c; color: #fff !important; }
    </style>
</head>
<body>
    <div class="result-container">
        <h1 style="color: ${isCorrect ? '#2ecc71' : '#e74c3c'}; font-size: 3rem; margin-top: 0;">
            <c:choose>
                <c:when test="${isCorrect}">正解！</c:when>
                <c:otherwise>残念...</c:otherwise>
            </c:choose>
        </h1>

        <div class="answer-box">
            <p>あなたの回答: <strong><c:out value="${userAnswer}" /></strong></p>
            <p>正しい正解: <strong style="color: #f1c40f;"><c:out value="${question.answer}" /></strong></p>
        </div>

        <c:if test="${not empty question.explanation}">
            <div style="background: #fffde7; color: #333; padding: 15px; border-radius: 8px; text-align: left; border-left: 5px solid #f1c40f; margin-bottom: 20px;">
                <strong style="color: #f39c12;">💡 解説</strong>
                <p style="white-space: pre-wrap; margin-top: 10px;"><c:out value="${question.explanation}" /></p>
            </div>
        </c:if>

        <div style="margin: 20px 0;">
            <c:choose>
                <c:when test="${isLiked}">
                    <a href="BookmarkServlet?questionId=${question.id}&action=remove" class="btn-fav fav-remove">❤️ 解除</a>
                </c:when>
                <c:otherwise>
                    <a href="BookmarkServlet?questionId=${question.id}&action=add" class="btn-fav fav-add">🤍 お気に入り</a>
                </c:otherwise>
            </c:choose>
        </div>

        <hr style="border: 0; border-top: 1px solid rgba(255,255,255,0.1); margin: 30px 0;">

        <div style="margin-top: 10px;">
            <c:if test="${not empty nextQuestionId}">
                <a href="AnswerServlet?id=${nextQuestionId}" class="btn-next">次の問題へ進む 🚀</a>
            </c:if>

            <c:if test="${isPlaylistFinished}">
                <p style="color: #2ecc71; font-weight: bold;">🎉 全て完了しました！</p>
            </c:if>

            <a href="main.jsp" class="btn-menu">メインメニューに戻る</a>
        </div>
    </div>
</body>
</html>