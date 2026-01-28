<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Question" %>
<%@ page import="java.util.List" %>
<%-- 1. XSS対策のためにJSTLを導入 --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% 
    Question q = (Question) request.getAttribute("question"); 
    List<String> shuffledChoices = (List<String>) request.getAttribute("shuffledChoices");
    
    // JSTLで利用するためにスコープにセット
    request.setAttribute("q", q);
    request.setAttribute("shuffledChoices", shuffledChoices);
%>
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="../css/style.css">
    <title>問題に挑戦 - ちょこり</title>
    <style>
        .choice-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            margin-top: 20px;
        }
        .btn-choice {
            padding: 15px;
            background: #fff;
            border: 2px solid #28a745;
            border-radius: 8px;
            cursor: pointer;
            font-weight: bold;
            transition: 0.3s;
        }
        .btn-choice:hover {
            background: #28a745;
            color: #fff;
        }
    </style>
</head>
<body>
    <div class="container">
        <div style="text-align: right;">
            <%-- 対策(XSS): クリア率の表示にfmtタグを使用 --%>
            <span class="btn btn-primary" style="font-size: 0.7em;">
                クリア率: <fmt:formatNumber value="${q.clearRate}" pattern="0.0" />%
            </span>
        </div>

        <%-- 対策(XSS): タイトルと問題文を c:out でエスケープ --%>
        <h2><c:out value="${q.title}" /></h2>
        <p style="background: #eee; padding: 20px; border-radius: 8px; white-space: pre-wrap;"><c:out value="${q.content}" /></p>

        <form action="AnswerServlet" method="POST">
            <%-- 対策(SQLインジェクション補助): IDを安全に埋め込み --%>
            <input type="hidden" name="id" value="${q.id}">
            
            <c:choose>
                <%-- ○×クイズ形式 --%>
                <c:when test="${q.type == '○×'}">
                    <div style="text-align: center; font-size: 1.5em; margin: 20px 0;">
                        <label><input type="radio" name="userAnswer" value="○" required> ○</label> &nbsp;
                        <label><input type="radio" name="userAnswer" value="×" required> ×</label>
                    </div>
                    <button type="submit" class="btn btn-success" style="width: 100%;">回答を送信</button>
                </c:when>

                <%-- 複数選択形式 --%>
                <c:when test="${q.type == '複数選択' && not empty shuffledChoices}">
                    <p>正しい選択肢をクリックしてください：</p>
                    <div class="choice-grid">
                        <c:forEach var="choice" items="${shuffledChoices}">
                            <%-- 対策(XSS): 選択肢の内容を c:out でエスケープ --%>
                            <button type="submit" name="userAnswer" value="<c:out value='${choice}' />" class="btn-choice">
                                <c:out value="${choice}" />
                            </button>
                        </c:forEach>
                    </div>
                </c:when>

                <%-- 単語入力形式（デフォルト） --%>
                <c:otherwise>
                    <input type="text" name="userAnswer" placeholder="回答を入力してください" required autocomplete="off">
                    <button type="submit" class="btn btn-success" style="width: 100%; margin-top: 20px;">回答を送信</button>
                </c:otherwise>
            </c:choose>
        </form>
    </div>
    <jsp:include page="memo_popup.jsp" />
</body>
</html>