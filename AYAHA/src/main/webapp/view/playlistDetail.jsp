<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <title>問題一覧 - ちょこり</title>
</head>
<body>
    <div class="container">
        <h2>プレイリスト詳細 (ID: ${playlistId})</h2>
        
        <div style="margin-top: 20px;">
            <c:forEach var="q" items="${questions}">
                <div class="result-item" style="border-bottom: 1px solid #eee; padding: 15px 0; display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <strong><c:out value="${q.title}" /></strong>
                        <p style="font-size: 0.8em; color: #666;"><c:out value="${q.content}" /></p>
                    </div>
                    
                    <div style="display: flex; gap: 10px;">
                        <%-- 編集ボタン --%>
                        <a href="${pageContext.request.contextPath}/view/EditQuestionServlet?id=${q.id}" class="btn" style="background: #3498db; color: white; padding: 5px 10px; text-decoration: none; border-radius: 5px;">編集</a>

                        <%-- 問題削除用のフォーム --%>
                        <form action="${pageContext.request.contextPath}/view/PlaylistDetailServlet" method="POST" onsubmit="return confirm('この問題を削除しますか？');" style="margin: 0;">
                            <input type="hidden" name="action" value="deleteQuestion">
                            <input type="hidden" name="questionId" value="${q.id}">
                            <input type="hidden" name="playlistId" value="${playlistId}">
                            <button type="submit" style="background: #e74c3c; color: white; border: none; padding: 5px 10px; border-radius: 5px; cursor: pointer;">削除</button>
                        </form>
                    </div>
                </div>
            </c:forEach>
        </div>
        
        <p><a href="${pageContext.request.contextPath}/view/MyQuestionsServlet">プレイリスト一覧に戻る</a></p>
    </div>
</body>
</html>