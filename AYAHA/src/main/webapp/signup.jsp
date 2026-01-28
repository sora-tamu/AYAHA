<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- XSS対策(JSTL)の宣言 --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>CREATE ARCHIVE - CHOKORI</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />

    <style>
        body {
            background-color: #000;
            color: #fff;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
        }

        .signup-container {
            width: 100%;
            max-width: 400px;
            padding: 40px 20px;
        }

        h1 {
            font-size: 0.9rem;
            letter-spacing: 0.5em;
            font-weight: 200;
            text-align: center;
            text-transform: uppercase;
            margin-bottom: 60px;
            color: #fff;
        }

        .input-group {
            margin-bottom: 35px;
        }

        .input-group label {
            display: block;
            font-size: 0.6rem;
            letter-spacing: 0.2em;
            color: #888;
            margin-bottom: 10px;
            text-transform: uppercase;
        }

        .password-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-group input {
            width: 100%;
            background: transparent !important;
            border: none !important;
            border-bottom: 1px solid #444 !important;
            color: #fff !important;
            font-size: 1rem !important;
            letter-spacing: 0.1em;
            padding: 10px 0 !important;
            border-radius: 0 !important;
            transition: border-color 0.4s ease;
        }

        .input-group input:focus {
            outline: none;
            border-bottom: 1px solid #fff !important;
        }

        .toggle-password {
            position: absolute;
            right: 0;
            font-size: 1.1rem;
            color: #444;
            cursor: pointer;
            user-select: none;
            transition: color 0.3s ease;
            padding-bottom: 8px;
        }

        .toggle-password:hover {
            color: #fff;
        }

        .btn-submit {
            width: 100%;
            background: transparent;
            border: 1px solid #fff;
            color: #fff;
            padding: 18px 0;
            font-size: 0.8rem;
            letter-spacing: 0.4em;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 20px;
        }

        .btn-submit:hover {
            background: #fff;
            color: #000;
        }

        .footer-link {
            margin-top: 50px;
            text-align: center;
        }

        .footer-link a {
            font-size: 0.7rem;
            letter-spacing: 0.2em;
            color: #666;
            text-decoration: none;
            transition: color 0.3s;
        }

        .footer-link a:hover {
            color: #fff;
        }

        .error-message {
            color: #ff3b3b;
            font-size: 0.65rem;
            letter-spacing: 0.1em;
            margin-top: 10px;
            text-transform: uppercase;
        }
    </style>
</head>
<body>

    <div class="signup-container">
        
        <h1>Create Archive</h1>

        <%-- 脆弱性対策(XSS): サーバー側からのエラー表示 --%>
        <c:if test="${not empty errorMessage}">
            <div class="error-message" style="text-align: center; margin-bottom: 20px;">
                <c:out value="${errorMessage}" />
            </div>
        </c:if>
        
        <form action="UserRegisterServlet" method="post" id="signupForm">
            <div class="input-group">
                <label>Identify as (User Name)</label>
                <%-- 脆弱性対策(XSS): 入力値の保持の際もエスケープ --%>
                <input type="text" name="userName" value="<c:out value='${param.userName}' />" required autocomplete="off" placeholder="YOUR NAME">
            </div>
            
            <div class="input-group">
                <label>Secure Key (Password)</label>
                <div class="password-wrapper">
                    <input type="password" name="password" id="pass" required placeholder="MIN 4 CHARS">
                    <span class="material-symbols-outlined toggle-password" data-target="pass">visibility</span>
                </div>
            </div>

            <div class="input-group">
                <label>Verify Key (Confirm Password)</label>
                <div class="password-wrapper">
                    <input type="password" name="confirmPassword" id="confirmPass" required placeholder="RE-ENTER">
                    <span class="material-symbols-outlined toggle-password" data-target="confirmPass">visibility</span>
                </div>
                <div id="error" class="error-message"></div>
            </div>

            <button type="submit" class="btn-submit">Register</button>
        </form>

        <div class="footer-link">
            <a href="login.jsp">RETURN TO SIGN IN</a>
        </div>
    </div>

    <script>
        // --- 目のアイコンの切り替え処理 ---
        document.querySelectorAll('.toggle-password').forEach(button => {
            button.addEventListener('click', function() {
                const targetId = this.getAttribute('data-target');
                const input = document.getElementById(targetId);
                
                const isPassword = input.getAttribute('type') === 'password';
                input.setAttribute('type', isPassword ? 'text' : 'password');
                this.textContent = isPassword ? 'visibility_off' : 'visibility';
            });
        });

        // --- パスワード一致チェック ---
        const form = document.getElementById('signupForm');
        const pass = document.getElementById('pass');
        const confirm = document.getElementById('confirmPass');
        const error = document.getElementById('error');

        form.addEventListener('submit', (e) => {
            if (pass.value !== confirm.value) {
                e.preventDefault();
                error.textContent = "Keys do not match.";
            } else {
                error.textContent = "";
            }
        });
    </script>
</body>
</html>