<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Playlist, model.User, dao.BookmarkDAO, util.DBManager" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    User loginUser = (User) session.getAttribute("loginUser");
    String dbRealPath = application.getRealPath("/WEB-INF/db/main_v3.db");
    DBManager.setRealPath(dbRealPath);
    BookmarkDAO bDAO = new BookmarkDAO();
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>SNS問題検索 - ちょこり</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: sans-serif; }
        body {
            min-height: 100vh; display: flex; justify-content: center; align-items: center;
            background: #050510 url('${pageContext.request.contextPath}/images/bg-galaxy.jpg') no-repeat center center fixed;
            background-size: cover; color: #fff;
        }
        .container {
            background: rgba(255, 255, 255, 0.08); backdrop-filter: blur(20px);
            padding: 40px; border-radius: 25px; width: 95%; max-width: 800px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .result-item { 
            background: rgba(255, 255, 255, 0.05); padding: 20px; border-radius: 15px; 
            margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center;
        }
        .result-title { font-size: 1.2em; color: #00d4ff; text-decoration: none; font-weight: bold; }
        .btn-solve { background: linear-gradient(135deg, #00d4ff, #008cff); color: white; padding: 10px 25px; border-radius: 50px; text-decoration: none; font-weight: bold; }
        .back-link { 
            display: inline-block; margin-top: 20px; color: rgba(255,255,255,0.6); 
            text-decoration: none; border: 1px solid rgba(255,255,255,0.2); 
            padding: 10px 20px; border-radius: 50px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2 style="text-align: center; margin-bottom: 25px;">SNS問題検索</h2>
        
        <form action="${pageContext.request.contextPath}/view/SearchServlet" method="get" style="display:flex; gap:10px; margin-bottom:30px;">
            <input type="text" name="keyword" value="<c:out value='${lastKeyword}' />" placeholder="検索ワード..." style="flex:1; padding:12px; border-radius:50px; border:none;">
            <button type="submit" style="padding:10px 25px; border-radius:50px; border:none; cursor:pointer; font-weight:bold;">検索</button>
        </form>

        <div class="result-list">
            <c:forEach var="p" items="${searchResults}">
                <%
                    Playlist pVar = (Playlist)pageContext.getAttribute("p");
                    boolean isLiked = (loginUser != null) ? bDAO.isBookmarked(loginUser.getId(), pVar.getId()) : false;
                    request.setAttribute("isLiked", isLiked);
                %>
                <div class="result-item">
                    <div>
                        <a href="PlaylistDetailServlet?playlistId=${p.id}" class="result-title"><c:out value="${p.name}" /></a><br>
                        <div style="margin-top: 10px;">
                            <c:choose>
                                <c:when test="${isLiked}">
                                    <a href="BookmarkServlet?questionId=${p.id}&action=remove" style="color: #ff4d94; text-decoration: none;"><i class='bx bxs-heart'></i> 解除</a>
                                </c:when>
                                <c:otherwise>
                                    <a href="BookmarkServlet?questionId=${p.id}&action=add" style="color: rgba(255,255,255,0.4); text-decoration: none;"><i class='bx bx-heart'></i> お気に入り</a>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <a href="StartPlaylistServlet?id=${p.id}" class="btn-solve">解く</a>
                </div>
            </c:forEach>
        </div>
        
        <div style="text-align: center;">
            <a href="main.jsp" class="back-link">
                <i class='bx bx-left-arrow-alt'></i> メインメニューへ戻る
            </a>
        </div>
    </div>
</body>
</html>