<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <title>一括問題作成 - ちょこり</title>
    <style>
        .question-block { border: 1px solid #ddd; padding: 20px; margin-bottom: 30px; border-radius: 12px; background: #fff; position: relative; }
        .question-number { background: #3498db; color: white; padding: 5px 15px; border-radius: 20px; font-size: 14px; display: inline-block; margin-bottom: 15px; }
    </style>
    <script>
        let questionCount = 1;
        let isSubmitted = false;

        function addQuestion() {
            questionCount++;
            const container = document.getElementById("questions-container");
            const newBlock = document.createElement("div");
            newBlock.className = "question-block fade-in";
            newBlock.id = "block_" + questionCount;
            
            newBlock.innerHTML = `
                <span class="question-number">問題 \${questionCount}</span>
                <div class="form-group">
                    <label>Title / タイトル</label>
                    <input type="text" name="title" required placeholder="例：ITパスポート 頻出単語" class="input-minimal">
                </div>
                <div class="form-group">
                    <label>Format / 回答形式</label>
                    <select name="type" onchange="toggleAnswerUI(\${questionCount})" id="type_\${questionCount}" class="input-minimal">
                        <option value="単語入力">単語入力</option>
                        <option value="○×">○×</option>
                        <option value="複数選択">複数選択 (4択)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Content / 問題内容</label>
                    <textarea name="content" required placeholder="問題文を入力してください" class="input-minimal"></textarea>
                </div>
                <div class="form-group">
                    <label>Answer / 正解</label>
                    <div id="answerInputArea_\${questionCount}">
                        <input type="text" name="answer" placeholder="正解を入力" required class="input-minimal">
                    </div>
                </div>
                <div id="choicesInputArea_\${questionCount}" style="display: none; margin-top: 20px; padding: 20px; background-color: #fafafa; border-radius: 12px;">
                    <p style="font-size: 12px; color: #999; margin-bottom: 20px;">間違いの選択肢（3つ）</p>
                    <div class="form-group"><input type="text" name="choice_1" placeholder="ハズレ1" class="input-minimal"></div>
                    <div class="form-group"><input type="text" name="choice_2" placeholder="ハズレ2" class="input-minimal"></div>
                    <div class="form-group"><input type="text" name="choice_3" placeholder="ハズレ3" class="input-minimal"></div>
                </div>
                <div class="form-group">
                    <label>Explanation / 解説 (任意)</label>
                    <textarea name="explanation" placeholder="補足情報を入力してください" class="input-minimal"></textarea>
                </div>
            `;
            container.appendChild(newBlock);
        }

        function toggleAnswerUI(id) {
            const type = document.getElementById("type_" + id).value;
            const answerDiv = document.getElementById("answerInputArea_" + id);
            const choicesDiv = document.getElementById("choicesInputArea_" + id);
            
            if (type === "○×") {
                answerDiv.innerHTML = `
                    <div class="radio-group">
                        <label><input type="radio" name="temp_answer_\${id}" value="○" checked onclick="syncAnswer(\${id}, '○')"> <span>○</span></label>
                        <label><input type="radio" name="temp_answer_\${id}" value="×" onclick="syncAnswer(\${id}, '×')"> <span>×</span></label>
                        <input type="hidden" name="answer" id="hidden_answer_\${id}" value="○">
                    </div>`;
            } else {
                answerDiv.innerHTML = `<input type="text" name="answer" placeholder="\${type === '複数選択' ? '正解の選択肢を入力' : '正解を入力'}" required class="input-minimal">`;
            }
            choicesDiv.style.display = (type === "複数選択") ? "block" : "none";
        }

        function syncAnswer(id, val) {
            document.getElementById("hidden_answer_" + id).value = val;
        }

        function validateSubmit() {
            if (isSubmitted) return false;
            isSubmitted = true;
            document.getElementById("submitBtn").innerText = "Storing All Questions...";
            return true;
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>Create Questions Playlist</h1>
        <form action="CreateQuestionServlet" method="POST" onsubmit="return validateSubmit()">
            <div style="background: #f0f7ff; padding: 20px; border-radius: 12px; margin-bottom: 30px; border: 1px solid #d0e3f0;">
                <div class="form-group">
                    <label>Playlist Name / 問題集のタイトル</label>
                    <input type="text" name="playlistName" required placeholder="例：ITパスポート過去問 第1回" class="input-minimal">
                </div>
                <div class="form-group">
                    <label>Common Tags / 共通タグ</label>
                    <input type="text" name="commonTags" placeholder="Java, 初心者" class="input-minimal">
                </div>
                <label style="font-size: 14px; cursor: pointer;">
                    <input type="checkbox" name="isPublic" value="1" checked style="margin-right: 8px;"> すべて公開設定にする
                </label>
            </div>

            <div id="questions-container">
                <div class="question-block" id="block_1">
                    <span class="question-number">問題 1</span>
                    <div class="form-group">
                        <label>Title / タイトル</label>
                        <input type="text" name="title" required class="input-minimal">
                    </div>
                    <div class="form-group">
                        <label>Format / 回答形式</label>
                        <select name="type" id="type_1" onchange="toggleAnswerUI(1)" class="input-minimal">
                            <option value="単語入力">単語入力</option>
                            <option value="○×">○×</option>
                            <option value="複数選択">複数選択 (4択)</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Content / 問題内容</label>
                        <textarea name="content" required class="input-minimal"></textarea>
                    </div>
                    <div class="form-group">
                        <label>Answer / 正解</label>
                        <div id="answerInputArea_1">
                            <input type="text" name="answer" placeholder="正解を入力" required class="input-minimal">
                        </div>
                    </div>
                    <div id="choicesInputArea_1" style="display: none; margin-top: 20px; padding: 20px; background-color: #fafafa; border-radius: 12px;">
                        <p style="font-size: 12px; color: #999; margin-bottom: 20px;">間違いの選択肢（3つ）</p>
                        <div class="form-group"><input type="text" name="choice_1" class="input-minimal"></div>
                        <div class="form-group"><input type="text" name="choice_2" class="input-minimal"></div>
                        <div class="form-group"><input type="text" name="choice_3" class="input-minimal"></div>
                    </div>
                    <div class="form-group">
                        <label>Explanation / 解説 (任意)</label>
                        <textarea name="explanation" class="input-minimal"></textarea>
                    </div>
                </div>
            </div>

            <div style="text-align: center; margin-bottom: 40px;">
                <button type="button" onclick="addQuestion()" class="btn" style="background: #34495e;">＋ 次の問題を追加</button>
            </div>
            <button type="submit" id="submitBtn" class="btn">Store All Questions</button>
        </form>
    </div>
</body>
</html>