<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User, dao.MemoDAO, util.DBManager" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    String dbPath = application.getRealPath("/WEB-INF/db/main_v3.db");
    util.DBManager.setRealPath(dbPath);

    dao.MemoDAO memoDAO = new dao.MemoDAO();
    String currentMemo = memoDAO.getMemo(loginUser.getId());
    
    request.setAttribute("loginUserName", loginUser.getName());
    request.setAttribute("currentMemo", currentMemo);
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>メインメニュー - ちょこり</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Nunito:wght@200..1000&display=swap">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/memory-game.css">
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: "Nunito", "Meiryo", sans-serif; }
        body {
            display: flex; justify-content: center; align-items: center; min-height: 100vh;
            background: #050510 url('${pageContext.request.contextPath}/images/bg-galaxy.jpg') no-repeat center center/cover;
            background-attachment: fixed; color: #fff; overflow-x: hidden;
        }
        #canvas { position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: 0; pointer-events: none; }
        .container { position: relative; z-index: 10; width: 90%; max-width: 500px; background: rgba(255, 255, 255, 0.07); border: 1px solid rgba(255, 255, 255, 0.15); backdrop-filter: blur(20px) saturate(180%); border-radius: 25px; padding: 40px; box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5); text-align: center; }
        h1 { font-size: 1.6rem; font-weight: 300; margin-bottom: 10px; text-shadow: 0 0 15px rgba(0, 212, 255, 0.6); }
        p { color: rgba(255, 255, 255, 0.7); margin-bottom: 30px; }
        .memo-section { text-align: left; margin-bottom: 30px; }
        .memo-section h4 { font-size: 0.85rem; color: #00d4ff; margin-bottom: 8px; display: flex; align-items: center; gap: 5px; }
        .memo-display { background: rgba(255, 255, 165, 0.1); border-left: 3px solid #f1c40f; padding: 15px; color: #eee; min-height: 60px; font-size: 0.9rem; white-space: pre-wrap; border-radius: 0 10px 10px 0; }
        .menu-grid { display: grid; gap: 15px; }
        .btn { display: block; padding: 14px; border-radius: 50px; text-decoration: none; font-weight: bold; font-size: 0.95em; transition: 0.3s; border: none; cursor: pointer; }
        .btn-primary { background: linear-gradient(135deg, #00d4ff, #008cff); color: white; box-shadow: 0 4px 15px rgba(0, 212, 255, 0.3); }
        .btn-warning { background: rgba(241, 196, 15, 0.15); border: 1px solid #f1c40f; color: #f1c40f; }
        .btn-success { background: rgba(46, 204, 113, 0.15); border: 1px solid #2ecc71; color: #2ecc71; }
        .btn:hover { transform: scale(1.03); filter: brightness(1.1); }
        .logout-link { display: inline-block; margin-top: 25px; color: rgba(255, 255, 255, 0.4); text-decoration: none; font-size: 0.85em; transition: 0.3s; }
        .logout-link:hover { color: #ff4d4d; }

        /* --- モーダル制御 --- */
        #game-trigger {
            position: fixed; bottom: 20px; left: 20px;
            background: linear-gradient(135deg, #6563ff, #4341d4);
            color: white; padding: 12px 20px; border-radius: 50px;
            cursor: pointer; z-index: 1000; box-shadow: 0 4px 15px rgba(101, 99, 255, 0.4);
            font-weight: bold; display: flex; align-items: center; gap: 8px; transition: 0.3s;
        }
        #game-trigger:hover { transform: scale(1.1); filter: brightness(1.2); }

        #game-modal {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.85); backdrop-filter: blur(8px);
            z-index: 2000; justify-content: center; align-items: center;
        }
        .modal-content { position: relative; }
        .close-game {
            position: absolute; top: -50px; right: 0; color: #fff;
            font-size: 2.5rem; cursor: pointer; transition: 0.3s;
        }
        .close-game:hover { color: #ff4d4d; }
    </style>
</head>
<body>
    <canvas id="canvas"></canvas>

    <div class="container">
        <h1>こんにちは、<c:out value="${loginUserName}" /> さん</h1>
        <p>今日は何を学習しますか？</p>
        
        <div class="memo-section">
            <h4><i class='bx bx-note'></i> 現在のメモ用紙</h4>
            <div id="main-memo-display" class="memo-display">
                <c:choose>
                    <c:when test="${empty currentMemo}">
                        <span style="opacity: 0.5; font-style: italic;">メモはまだありません。</span>
                    </c:when>
                    <c:otherwise><c:out value="${currentMemo}" /></c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="menu-grid">
            <a href="SearchServlet" class="btn btn-primary">問題を解く（SNS検索）</a>
            <a href="BookmarkListServlet" class="btn btn-warning">❤️ お気に入り問題を確認</a>
            <a href="MyQuestionsServlet" class="btn btn-success">自作問題を管理する</a>
        </div>

        <a href="../LogoutServlet" class="logout-link"><i class='bx bx-log-out'></i> ログアウト</a>
    </div>

    <div id="game-trigger" onclick="openGame()">
        <i class='bx bx-joystick'></i> 息抜きゲーム
    </div>

    <div id="game-modal">
        <div class="modal-content">
            <span class="close-game" onclick="closeGame()">&times;</span>
            <div class="memory-game-section">
                <div class="wrapper">
                    <ul class="cards">
                        <% for(int i=0; i<12; i++) { %>
                        <li class="card">
                            <div class="view front-view">
                                <img src="${pageContext.request.contextPath}/images/que_icon.svg" alt="icon">
                            </div>
                            <div class="view back-view">
                                <img src="" alt="card-img">
                            </div>
                        </li>
                        <% } %>
                    </ul>
                    <div class="details">
                        <p class="time">Time: <span><b>120</b>s</span></p>
                        <p class="flips">Flips: <span><b>0</b></span></p>
                        <button id="game-refresh-btn">Try Again</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="memo_popup.jsp" />

    <script>
        // 星空背景
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        let stars = [];
        function resize() { canvas.width = window.innerWidth; canvas.height = window.innerHeight; }
        window.addEventListener('resize', resize);
        resize();
        class Star {
            constructor() { this.reset(); }
            reset() { this.x = Math.random() * canvas.width; this.y = Math.random() * canvas.height; this.size = Math.random() * 1.2 + 0.5; this.speedX = (Math.random() - 0.5) * 0.1; this.speedY = Math.random() * 0.05 + 0.02; this.brightness = Math.random(); this.blinkSpeed = Math.random() * 0.01 + 0.005; }
            update() { this.y += this.speedY; this.x += this.speedX; this.brightness += this.blinkSpeed; if (this.y > canvas.height) this.reset(); }
            draw() { const alpha = Math.abs(Math.sin(this.brightness)); ctx.fillStyle = `rgba(255, 255, 255, ${alpha})`; ctx.beginPath(); ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2); ctx.fill(); }
        }
        for (let i = 0; i < 100; i++) { stars.push(new Star()); }
        function animate() { ctx.clearRect(0, 0, canvas.width, canvas.height); stars.forEach(star => { star.update(); star.draw(); }); requestAnimationFrame(animate); }
        animate();

        // モーダル制御
        function openGame() {
            document.getElementById('game-modal').style.display = 'flex';
            if(typeof shuffleCard === 'function') shuffleCard();
        }
        function closeGame() {
            document.getElementById('game-modal').style.display = 'none';
        }
    </script>
    <script>const CONTEXT_PATH = '${pageContext.request.contextPath}';</script>
    <script src="${pageContext.request.contextPath}/js/memory-game.js"></script>
</body>
</html>