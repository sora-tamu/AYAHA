<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <title>問題の編集 - ちょこり</title>
    <script>
        let isSubmitted = false;
        function validateSubmit() {
            if (isSubmitted) return false;
            isSubmitted = true;
            const btn = document.getElementById("updateBtn");
            btn.innerText = "更新中...";
            btn.style.opacity = "0.6";
            return true;
        }
    </script>
</head>
<body>
<div class="container">
    <h1>問題の編集</h1>
    
    <form action="${pageContext.request.contextPath}/view/UpdateQuestionServlet" method="POST" onsubmit="return validateSubmit()">
        <input type="hidden" name="id" value="<c:out value='${question.id}' />">

        <div class="form-group">
            <label>タイトル</label>
            <input type="text" name="title" value="<c:out value='${question.title}' />" required class="input-minimal">
        </div>

        <div class="form-group">
            <label>問題内容</label>
            <textarea name="content" required class="input-minimal" style="height: 100px;"><c:out value="${question.content}" /></textarea>
        </div>

        <div class="form-group">
            <label>正解</label>
            <input type="text" name="answer" value="<c:out value='${question.answer}' />" required class="input-minimal">
        </div>

        <div class="form-group">
            <label>解説 (任意)</label>
            <textarea name="explanation" class="input-minimal"><c:out value="${question.explanation}" /></textarea>
        </div>

        <div class="form-group">
            <label>タグ (カンマ区切り)</label>
            <input type="text" name="tags" value="<c:out value='${question.tags}' />" class="input-minimal" placeholder="例: 歴史,江戸時代">
        </div>

        <div class="form-group">
            <label>
                <input type="checkbox" name="isPublic" value="1" ${question.isPublic ? 'checked' : ''}> 公開する
            </label>
        </div>

        <button type="submit" id="updateBtn" class="btn btn-success" style="width: 100%; padding: 15px;">更新を保存</button>
    </form>
    
    <p style="text-align: center; margin-top: 20px;">
        <a href="${pageContext.request.contextPath}/view/MyQuestionsServlet">キャンセルして戻る</a>
    </p>
</div>
</body>
</html>