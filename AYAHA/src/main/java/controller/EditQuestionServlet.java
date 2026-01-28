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

@WebServlet("/view/EditQuestionServlet")
public class EditQuestionServlet extends HttpServlet {
    private QuestionDAO dao;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // DBパスを確定
        String dbRealPath = getServletContext().getRealPath("/WEB-INF/db/main_v3.db");
        DBManager.setRealPath(dbRealPath);
        if (dao == null) dao = new QuestionDAO();

        String idStr = request.getParameter("id"); // 問題IDを受け取る
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/view/MyQuestionsServlet");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Question question = dao.getQuestionById(id);
            
            if (question != null) {
                request.setAttribute("question", question);
                // 修正後のeditQuestion.jspへ移動
                request.getRequestDispatcher("/view/editQuestion.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/view/MyQuestionsServlet");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/view/MyQuestionsServlet");
        }
    }
}