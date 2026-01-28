<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AUTHENTICATION - CHOKORI</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Nunito:wght@200..1000&display=swap');

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: "Nunito", sans-serif;
        }

        body {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            /* 背景画像：宇宙のデザインに合わせたパスを指定 */
            background: url('${pageContext.request.contextPath}/images/bg-galaxy.jpg') no-repeat;
            background-size: cover;
            background-position: center;
            overflow: hidden;
            position: relative;
        }

        /* アニメーション用キャンバスを背景の一番奥に */
        #canvas {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 0;
            pointer-events: none;
        }

        /* 画像のようなグラスモーフィズム・コンテナ */
        .wrapper {
            position: relative;
            z-index: 10; /* コンテンツを前面に */
            width: 420px;
            background: rgba(255, 255, 255, 0.05); /* 非常に薄い白 */
            border: 2px solid rgba(255, 255, 255, 0.1); /* 繊細な境界線 */
            backdrop-filter: blur(15px) saturate(180%); /* 強いぼかし */
            color: #fff;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.8);
        }

        .wrapper h1 {
            font-size: 32px;
            text-align: center;
            letter-spacing: 0.15em;
            text-transform: uppercase;
            margin-bottom: 30px;
            font-weight: 300;
            /* 地球のような青い光をタイトルにも適用 */
            text-shadow: 0 0 10px rgba(0, 212, 255, 0.6);
        }

        .error-message {
            color: #ff4d4d;
            font-size: 0.75rem;
            text-align: center;
            margin-bottom: 20px;
            background: rgba(255, 77, 77, 0.1);
            padding: 8px;
            border-radius: 5px;
        }

        /* 入力ボックス（画像のデザインを反映） */
        .input-box {
            position: relative;
            width: 100%;
            height: 55px;
            margin: 25px 0;
        }

        .input-box input {
            width: 100%;
            height: 100%;
            background: rgba(255, 255, 255, 0.05) !important;
            border: 1px solid rgba(255, 255, 255, 0.2) !important;
            border-radius: 50px !important;
            outline: none;
            font-size: 16px !important;
            color: #fff !important;
            padding: 0 50px 0 25px !important;
            transition: 0.3s;
        }

        .input-box input:focus {
            border-color: rgba(0, 212, 255, 0.8) !important;
            box-shadow: 0 0 15px rgba(0, 212, 255, 0.3);
        }

        /* アイコン */
        .input-box i, .input-box .toggle-password {
            position: absolute;
            right: 20px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 20px;
            color: rgba(255, 255, 255, 0.6);
        }

        .input-box .toggle-password {
            cursor: pointer;
        }

        /* サインインボタン */
        .btn {
            width: 100%;
            height: 50px;
            background: linear-gradient(90deg, #00d4ff, #008cff);
            border: none;
            outline: none;
            border-radius: 50px;
            cursor: pointer;
            font-size: 16px;
            color: #fff;
            font-weight: 700;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            transition: 0.3s;
            margin-top: 10px;
            box-shadow: 0 4px 15px rgba(0, 212, 255, 0.4);
        }

        .btn:hover {
            transform: scale(1.03);
            box-shadow: 0 6px 20px rgba(0, 212, 255, 0.6);
        }

        .register-link {
            font-size: 14px;
            text-align: center;
            margin-top: 25px;
            color: rgba(255, 255, 255, 0.7);
        }

        .register-link a {
            color: #00d4ff;
            text-decoration: none;
            font-weight: 700;
        }

        .register-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

    <canvas id="canvas"></canvas>

    <div class="wrapper">
        <form action="LoginServlet" method="post" id="loginForm">
            <h1>Authentication</h1>

            <c:if test="${not empty errorMessage}">
                <div class="error-message">
                    <c:out value="${errorMessage}" />
                </div>
            </c:if>

            <div class="input-box">
                <input type="text" name="userName" placeholder="Username" value="<c:out value='${param.userName}' />" required autocomplete="username">
                <i class='bx bxs-user'></i>
            </div>

            <div class="input-box">
                <input type="password" name="password" id="password" placeholder="Password" required autocomplete="current-password">
                <span class="material-symbols-outlined toggle-password" id="togglePassword">visibility</span>
            </div>

            <button type="submit" class="btn" id="submitBtn">Sign In</button>

            <div class="register-link">
                <p>New explorer? <a href="signup.jsp">Create Account</a></p>
            </div>
        </form>
    </div>

    <script type="module">
        import TubesCursor from "https://cdn.jsdelivr.net/npm/threejs-components@0.0.19/build/cursors/tubes1.min.js"

        const canvas = document.getElementById('canvas');
        const app = TubesCursor(canvas, {
            tubes: {
                // 画像の青い光に合わせた色に変更
                colors: ["#00d4ff", "#008cff", "#6958d5"],
                lights: { intensity: 300, colors: ["#00d4ff", "#ffffff", "#008cff"] }
            }
        });

        // 物理マウスの完全ブロック
        const blockMouse = (e) => {
            if (e.isTrusted) {
                e.stopImmediatePropagation();
                e.stopPropagation();
            }
        };
        window.addEventListener('mousemove', blockMouse, true);
        window.addEventListener('pointermove', blockMouse, true);

        // 自動描画アニメーション（中央の地球の周りを回るようなイメージ）
        let time = 0;
        function animate() {
            const radius = Math.min(window.innerWidth, window.innerHeight) * 0.3;
            // 画像の軌道に近い動き（円形）
            const posX = radius * Math.cos(time) + window.innerWidth / 2;
            const posY = radius * Math.sin(time) + window.innerHeight / 2;

            window.dispatchEvent(new MouseEvent('mousemove', {
                clientX: posX,
                clientY: posY,
                bubbles: true
            }));

            time += 0.01;
            requestAnimationFrame(animate);
        }
        animate();
    </script>
    
    <script>
        const togglePassword = document.getElementById('togglePassword');
        const passwordInput = document.getElementById('password');
        togglePassword.addEventListener('click', function() {
            const isPassword = passwordInput.getAttribute('type') === 'password';
            passwordInput.setAttribute('type', isPassword ? 'text' : 'password');
            this.textContent = isPassword ? 'visibility_off' : 'visibility';
        });
    </script>
</body>
</html>