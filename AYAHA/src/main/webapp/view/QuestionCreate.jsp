<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- XSS対策(JSTL)の宣言 --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>CREATE NEW - CHOKORI</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body {
            background-color: #000;
            color: #fff;
            margin: 0;
            padding-bottom: 100px;
        }

        .form-section {
            border-bottom: 1px solid #222;
            padding: 40px 0;
            transition: border-color 0.4s;
        }
        .form-section:focus-within {
            border-bottom: 1px solid #fff;
        }

        .label-text {
            display: block;
            font-size: 0.6rem;
            letter-spacing: 0.3em;
            color: #888;
            margin-bottom: 15px;
            text-transform: uppercase;
        }

        .input-minimal {
            width: 100%;
            background: transparent;
            border: none;
            color: #fff;
            font-size: 1.1rem;
            letter-spacing: 0.05em;
            padding: 5px 0;
            outline: none;
            font-weight: 200;
        }
        .input-minimal::placeholder {
            color: #222;
        }

        textarea.input-minimal {
            min-height: 150px;
            line-height: 1.8;
            resize: none;
        }

        select.input-minimal {
            cursor: pointer;
            appearance: none;
            -webkit-appearance: none;
        }

        .error-message {
            color: #ff3b3b;
            font-size: 0.7rem;
            text-align: center;
            margin-bottom: 20px;
            letter-spacing: 0.2em;
        }

        .submit-area {
            margin-top: 80px;
            text-align: center;
        }

        .btn-publish {
            background: #fff;
            color: #000;
            border: none;
            padding: 20px 80px;
            font-size: 0.8rem;
            letter-spacing: 0.4em;
            text-transform: uppercase;
            cursor: pointer;
            transition: opacity 0.3s;
        }
        .btn-publish:hover {
            opacity: 0.8;
        }

        .cancel-link {
            display: inline-block;
            margin-top: 40px;
            font-size: 0.6rem;
            letter-spacing: 0.2em;
            color: #444;
            text-decoration: none;
        }
    </style>
</head>
<body>

    <header>
        <div class="nav-container">
            <a href="QuestionListServlet" class="nav-logo">CHOKORI</a>
            <nav class="global-nav">
                <a href="QuestionListServlet">COLLECTION</a>
                <a href="MyPageServlet">ARCHIVE</a>
            </nav>
        </div>
    </header>

    <main class="container" style="max-width: 700px;">
        
        <section style="padding: 80px 0 40px;">
            <span class="label-text" style="color:#fff;">New Entry</span>
            <h1 style="font-size: 1.8rem; font-weight: 100; letter-spacing: 0.1em; margin: 0;">Add to Collection</h1>
        </section>

        <%-- 対策(XSS): 入力エラー等のメッセージを安全に表示 --%>
        <c:if test="${not empty errorMessage}">
            <div class="error-message">
                <c:out value="${errorMessage}" />
            </div>
        </c:if>

        <form action="QuestionCreateServlet" method="post">
            
            <div class="form-section">
                <label class="label-text">Subject Title</label>
                <%-- 対策(XSS): 再表示する値(param.title)をエスケープ --%>
                <input type="text" name="title" class="input-minimal" 
                       value="<c:out value='${param.title}' />" placeholder="Untitled Question" required>
            </div>
            
            <div class="form-section">
                <label class="label-text">Tags (Comma Separated)</label>
                <input type="text" name="tags" class="input-minimal" 
                       value="<c:out value='${param.tags}' />" placeholder="e.g. History, Design, Art">
            </div>
            
            <div class="form-section">
                <label class="label-text">Question Content</label>
                <textarea name="content" class="input-minimal" placeholder="Describe the problem..." required><c:out value="${param.content}" /></textarea>
            </div>
            
            <div class="form-section">
                <label class="label-text">Response Type</label>
                <select name="type" class="input-minimal">
                    <option value="単語入力" ${param.type == '単語入力' ? 'selected' : ''}>FREE TEXT INPUT</option>
                    <option value="複数選択" ${param.type == '複数選択' ? 'selected' : ''}>MULTIPLE CHOICE</option>
                    <option value="○×" ${param.type == '○×' ? 'selected' : ''}>TRUE / FALSE</option>
                </select>
            </div>
            
            <div class="form-section">
                <label class="label-text">Definitive Answer</label>
                <input type="text" name="answer" class="input-minimal" 
                       value="<c:out value='${param.answer}' />" placeholder="Correct Solution" required>
            </div>
            
            <div class="submit-area">
                <button type="submit" class="btn-publish">Publish</button>
                <br>
                <a href="QuestionListServlet" class="cancel-link">Discard and Return</a>
            </div>
        </form>
    </main>

    <div class="fixed-character">
        <div class="character">
            <div class="eyes"><div class="eye"></div><div class="eye"></div></div>
        </div>
    </div>
    <jsp:include page="memo_popup.jsp" />
</body>
</html>