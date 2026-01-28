<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User, dao.MemoDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    User mu = (User) session.getAttribute("loginUser");
    String popupMemo = "";
    if (mu != null) {
        // main.jspでパス設定済みであることを前提
        popupMemo = new dao.MemoDAO().getMemo(mu.getId());
    }
    request.setAttribute("memoContent", popupMemo);
%>
<style>
    /* スタイル設定（既存のものを維持） */
    #memo-trigger { position: fixed; bottom: 20px; right: 20px; background: #f1c40f; color: white; padding: 12px 20px; border-radius: 50px; cursor: pointer; z-index: 1000; box-shadow: 0 4px 10px rgba(0,0,0,0.2); font-weight: bold; }
    #memo-popup { position: fixed; bottom: 80px; right: 20px; width: 300px; background: white; border-radius: 10px; z-index: 1000; display: none; overflow: hidden; border: 1px solid #ddd; box-shadow: 0 5px 20px rgba(0,0,0,0.1); }
    #memo-area-popup { width: 100%; height: 150px; border: none; padding: 10px; resize: none; outline: none; font-size: 14px; }
    #memo-save-btn-popup { width: 100%; padding: 10px; border: none; background: #2ecc71; color: white; cursor: pointer; font-weight: bold; }
</style>

<div id="memo-trigger" onclick="toggleMemo()">📝 メモを書く</div>

<div id="memo-popup">
    <textarea id="memo-area-popup" placeholder="ここにメモを入力..."><c:out value="${memoContent}" /></textarea>
    <button onclick="saveMemoAjax()" id="memo-save-btn-popup">保存する</button>
</div>

<script>
function toggleMemo() {
    const p = document.getElementById('memo-popup');
    p.style.display = (p.style.display === 'none' || p.style.display === '') ? 'block' : 'none';
}

let isMemoSaving = false;
function saveMemoAjax() {
    if (isMemoSaving) return;

    const content = document.getElementById('memo-area-popup').value;
    const btn = document.getElementById('memo-save-btn-popup');
    const displayArea = document.getElementById('main-memo-display'); // main.jspの表示枠
    
    isMemoSaving = true;
    btn.innerText = "保存中..."; 
    btn.disabled = true;

    const params = new URLSearchParams();
    params.append('memo', content);

    fetch('SaveMemoServlet', { 
        method: 'POST', 
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params 
    })
    .then(res => {
        if (res.ok) {
            btn.innerText = "保存完了！";
            // main.jsp側の表示もリアルタイムで更新
            if (displayArea) {
                displayArea.innerText = content || "メモはまだありません。";
            }
            setTimeout(() => {
                btn.innerText = "保存する";
                btn.disabled = false;
                isMemoSaving = false;
            }, 2000);
        }
    })
    .catch(err => {
        alert("保存に失敗しました");
        btn.disabled = false;
        isMemoSaving = false;
    });
}
</script>