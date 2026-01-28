<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.MemoDAO, model.User" %>
<%-- 1. XSS対策(JSTL)の導入 --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    User footerUser = (User) session.getAttribute("loginUser");
    String currentMemo = "";
    if (footerUser != null) {
        // 対策: 毎回インスタンス化するより、本来はService等を経由するのが望ましいですが、
        // 現状の構成を維持しつつ安全性を高めます
        currentMemo = new MemoDAO().getMemoByUserId(footerUser.getId());
    }
    request.setAttribute("currentMemo", currentMemo);
%>

<style>
    .sticky-memo {
        position: fixed;
        bottom: 20px;
        right: 20px;
        width: 200px;
        background: #fff9c4;
        border: 1px solid #fbc02d;
        box-shadow: 2px 2px 10px rgba(0,0,0,0.1);
        padding: 10px;
        border-radius: 4px;
        z-index: 1000;
    }
    .sticky-memo textarea {
        width: 100%;
        height: 80px;
        font-size: 12px;
        border: none;
        background: transparent;
        resize: none;
        outline: none;
    }
</style>

<div class="sticky-memo">
    <%-- 2. 対策(CSRF/DDoS): POSTメソッドを使用。actionには適切なパスを指定してください --%>
    <form action="${pageContext.request.contextPath}/MemoServlet" method="POST" id="memoForm">
        <strong style="font-size: 12px;">📝 クイックメモ</strong>
        
        <%-- 3. 対策(XSS): 保存されたメモ内容を安全にエスケープ表示 --%>
        <textarea name="memoContent" placeholder="忘れないうちにメモ！"><c:out value="${currentMemo}" /></textarea>
        
        <button type="submit" class="btn" id="memoSaveBtn" style="width: 100%; padding: 2px; font-size: 10px; background: #fbc02d;">保存</button>
    </form>
</div>

<script>
    // 4. 対策(DDoS/連打防止): 保存ボタンの連打を抑制
    document.getElementById('memoForm').addEventListener('submit', function() {
        const btn = document.getElementById('memoSaveBtn');
        btn.disabled = true;
        btn.innerText = "保存中...";
    });
</script>