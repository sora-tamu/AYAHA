<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>学習画面 - AYAHA</title>
</head>
<body>
    <h2>学習中 (プレイリストID: ${playlistId})</h2>
    
    <c:choose>
        <c:when test="${not empty questions}">
            <c:forEach var="q" items="${questions}">
                <div style="border: 1px solid #333; padding: 15px; margin-bottom: 20px; border-radius: 5px;">
                    <h3>問題: ${q.title}</h3>
                    <p>${q.content}</p>
                    <details>
                        <summary style="cursor:pointer; color: blue;">答えを確認する</summary>
                        <div style="margin-top: 10px; padding: 10px; background-color: #f9f9f9;">
                            <strong>正解:</strong> ${q.answer}
                        </div>
                    </details>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <p>このプレイリストにはまだ問題がありません。</p>
        </c:otherwise>
    </c:choose>

    <hr>
    <a href="MyQuestionsServlet">一覧に戻る</a>
</body>
</html>