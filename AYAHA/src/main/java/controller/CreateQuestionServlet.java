package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.QuestionDAO;
import model.Question;
import model.User;

@WebServlet("/view/CreateQuestionServlet")
public class CreateQuestionServlet extends HttpServlet {
    private QuestionDAO qDAO = new QuestionDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("createQuestion.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // 1. 共通設定の取得
        String playlistName = request.getParameter("playlistName");
        String tagInput = request.getParameter("commonTags");
        String[] tags = (tagInput != null && !tagInput.isEmpty()) ? tagInput.split("[,，]") : new String[0];
        boolean isPublic = "1".equals(request.getParameter("isPublic"));

        // 2. 新しいプレイリストを作成
        int userId = loginUser.getId();
        int playlistId = qDAO.createPlaylist(playlistName, userId);

        // 3. 各問題のデータを「配列」として取得
        String[] titles = request.getParameterValues("title");
        String[] contents = request.getParameterValues("content");
        String[] types = request.getParameterValues("type");
        String[] answers = request.getParameterValues("answer");
        String[] choice1s = request.getParameterValues("choice_1");
        String[] choice2s = request.getParameterValues("choice_2");
        String[] choice3s = request.getParameterValues("choice_3");
        String[] explanations = request.getParameterValues("explanation");

        // 4. 配列をループして全問題を一括保存
        if (titles != null) {
            for (int i = 0; i < titles.length; i++) {
                Question q = new Question();
                q.setTitle(titles[i]);
                q.setContent(contents[i]);
                q.setType(types[i]);
                q.setAnswer(answers[i]);
                
                // 選択肢などは配列の長さをチェックして安全に取得
                if (choice1s != null && i < choice1s.length) q.setChoice1(choice1s[i]);
                if (choice2s != null && i < choice2s.length) q.setChoice2(choice2s[i]);
                if (choice3s != null && i < choice3s.length) q.setChoice3(choice3s[i]);
                if (explanations != null && i < explanations.length) q.setExplanation(explanations[i]);
                
                q.setPublic(isPublic);

                // 全問題を同じ playlistId に紐付け
                qDAO.addQuestionToPlaylist(playlistId, q, tags, userId);
            }
        }

        // 5. 完了後はマイリスト一覧へ
        response.sendRedirect(request.getContextPath() + "/view/MyQuestionsServlet");
    }
}