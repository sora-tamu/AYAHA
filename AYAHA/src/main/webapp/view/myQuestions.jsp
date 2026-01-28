<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.Playlist" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>自作プレイリスト管理 - ちょこり</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet'>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Nunito:wght@200..1000&display=swap">
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: "Nunito", "Meiryo", sans-serif; }

        body {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background-color: #050510; 
            background-image: url('${pageContext.request.contextPath}/images/bg-galaxy.jpg');
            background-repeat: no-repeat;
            background-position: center center;
            background-size: cover;
            background-attachment: fixed;
            overflow-x: hidden;
            color: #fff;
        }

        #canvas {
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            z-index: -1; 
            pointer-events: none;
        }

        .container {
            position: relative;
            z-index: 10;
            width: 95%;
            max-width: 850px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(15px) saturate(150%);
            border-radius: 25px;
            padding: 40px;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.6);
            margin: 40px 10px;
        }

        /* ボタンスタイル */
        .btn-solve { background: linear-gradient(135deg, #00d4ff, #008cff); color: white; padding: 10px 22px; border-radius: 50px; text-decoration: none; font-weight: bold; display: inline-block; transition: 0.3s; }
        .btn-edit { background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(255, 255, 255, 0.2); color: white; padding: 10px 22px; border-radius: 50px; text-decoration: none; display: inline-block; transition: 0.3s; }
        .btn-delete { background: rgba(255, 77, 77, 0.15); color: #ff4d4d; border: 1px solid rgba(255, 77, 77, 0.3); padding: 10px 22px; border-radius: 50px; cursor: pointer; transition: 0.3s; }
        
        .btn-solve:hover, .btn-edit:hover { transform: scale(1.05); opacity: 0.9; }
        .btn-delete:hover { background: #ff4d4d; color: white; }

        .result-item { border-bottom: 1px solid rgba(255, 255, 255, 0.1); padding: 25px 0; display: flex; justify-content: space-between; align-items: center; }
        .result-title { font-size: 1.3em; color: #00d4ff !important; text-decoration: none; }
        .result-meta { color: rgba(255, 255, 255, 0.5); font-size: 0.9em; }
    </style>
</head>
<body>
    <canvas id="canvas"></canvas>

    <div class="container">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
            <h2>My Playlists</h2>
            <a href="${pageContext.request.contextPath}/view/CreateQuestionServlet" style="border: 1px solid #00d4ff; color: #00d4ff; padding: 10px 20px; border-radius: 50px; text-decoration: none; font-size: 0.9em; font-weight: bold;">
               <i class='bx bx-plus-circle'></i> 新規作成
            </a>
        </div>

        <c:choose>
            <c:when test="${not empty myPlaylists}">
                <c:forEach var="p" items="${myPlaylists}">
                    <div class="result-item">
                        <div class="result-info">
                            <span class="result-meta">ID: <c:out value="${p.id}" /> | <c:out value="${p.questionCount}" /> Questions</span><br>
                            <a href="${pageContext.request.contextPath}/view/PlaylistDetailServlet?playlistId=${p.id}" class="result-title">
                                <strong><c:out value="${p.name}" /></strong>
                            </a>
                        </div>
                        <div style="display: flex; gap: 10px;">
                            <a href="${pageContext.request.contextPath}/view/StartPlaylistServlet?id=${p.id}" class="btn-solve">解く</a>
                            <a href="${pageContext.request.contextPath}/view/PlaylistDetailServlet?playlistId=${p.id}" class="btn-edit">管理</a>
                            <form action="${pageContext.request.contextPath}/view/MyQuestionsServlet" method="POST" style="margin: 0;">
                                <input type="hidden" name="id" value="${p.id}">
                                <input type="hidden" name="action" value="delete"> 
                                <button type="submit" class="btn-delete" onclick="return confirm('削除しますか？')">削除</button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <p style="text-align: center; color: rgba(255,255,255,0.4);">リストがありません。</p>
            </c:otherwise>
        </c:choose>

        <p style="text-align: center; margin-top: 30px;">
            <a href="${pageContext.request.contextPath}/view/main.jsp" style="color: rgba(255,255,255,0.6); text-decoration: none; font-size: 0.9em;">
               <i class='bx bx-left-arrow-alt'></i> メインへ戻る
            </a>
        </p>
    </div>

    <script>
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        let stars = [];
        function resize() { canvas.width = window.innerWidth; canvas.height = window.innerHeight; }
        window.addEventListener('resize', resize);
        resize();

        class Star {
            constructor() { this.reset(); }
            reset() {
                this.x = Math.random() * canvas.width;
                this.y = Math.random() * canvas.height;
                this.size = Math.random() * 1.5 + 0.2;
                this.speedY = Math.random() * 0.1 + 0.05;
                this.brightness = Math.random();
            }
            update() { this.y += this.speedY; if (this.y > canvas.height) this.reset(); }
            draw() {
                // 修正ポイント：EL式との衝突を防ぐため、文字列結合を使用
                const alpha = Math.abs(Math.sin(this.brightness));
                ctx.fillStyle = "rgba(255, 255, 255, " + alpha + ")";
                ctx.beginPath(); 
                ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2); 
                ctx.fill();
                this.brightness += 0.01;
            }
        }
        for (let i = 0; i < 100; i++) stars.push(new Star());
        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            stars.forEach(s => { s.update(); s.draw(); });
            requestAnimationFrame(animate);
        }
        animate();
    </script>
</body>
</html>