package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import dao.QuestionDAO;
import model.Question;
import util.DBManager;

@WebServlet("/view/UpdateQuestionServlet")
public class UpdateQuestionServlet extends HttpServlet {
    private QuestionDAO dao; // フィールドで定義

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        String dbRealPath = getServletContext().getRealPath("/WEB-INF/db/main_v3.db");
        DBManager.setRealPath(dbRealPath);
        if (dao == null) dao = new QuestionDAO(); // 必要な時のみ初期化

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/view/MyQuestionsServlet");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            String answer = request.getParameter("answer");
            String explanation = request.getParameter("explanation");
            String tagsStr = request.getParameter("tags");
            boolean isPublic = "1".equals(request.getParameter("isPublic"));

            // タグのトリミング処理
            String[] tagArray = (tagsStr != null && !tagsStr.trim().isEmpty()) 
                                ? tagsStr.split("\\s*,\\s*") // カンマ前後の空白もまとめて分割
                                : new String[0];

            Question q = new Question(id, title, content, answer, explanation, tagsStr, isPublic);
            
            if (dao.updateQuestion(q, tagArray)) {
                response.sendRedirect(request.getContextPath() + "/view/MyQuestionsServlet");
            } else {
                response.sendRedirect(request.getContextPath() + "/view/error.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/view/MyQuestionsServlet");
        }
    }
}