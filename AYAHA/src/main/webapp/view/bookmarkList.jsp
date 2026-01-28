<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>お気に入り一覧 - ちょこり</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <style>
        body { background: #050510 url('${pageContext.request.contextPath}/images/bg-galaxy.jpg') no-repeat center center fixed; background-size: cover; color: #fff; font-family: sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
        .container { background: rgba(255, 255, 255, 0.08); backdrop-filter: blur(20px); padding: 40px; border-radius: 25px; width: 90%; max-width: 600px; border: 1px solid rgba(255, 255, 255, 0.1); }
        .item-card { background: rgba(255, 255, 255, 0.05); padding: 20px; border-radius: 15px; margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center; }
        .btn-solve { background: #fff; color: #000; padding: 8px 20px; border-radius: 50px; text-decoration: none; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h2 style="text-align: center; margin-bottom: 25px;"><i class='bx bxs-heart'></i> お気に入りリスト</h2>
        <c:choose>
            <c:when test="${empty bookmarkedList}">
                <p style="text-align: center; opacity: 0.5;">お気に入りはまだありません。</p>
            </c:when>
            <c:otherwise>
                <c:forEach var="p" items="${bookmarkedList}">
                    <div class="item-card">
                        <div>
                            <span style="font-size: 1.1em; font-weight: bold;"><c:out value="${p.name}" /></span>
                        </div>
                        <div>
                            <a href="StartPlaylistServlet?id=${p.id}" class="btn-solve">解く</a>
                            <a href="BookmarkServlet?questionId=${p.id}&action=remove" style="color: #ff4d94; text-decoration: none; margin-left: 10px;">解除</a>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
        <div style="text-align: center; margin-top: 20px;">
            <a href="main.jsp" style="color: #ccc; text-decoration: none;">メニューへ戻る</a>
        </div>
    </div>
</body>
</html>