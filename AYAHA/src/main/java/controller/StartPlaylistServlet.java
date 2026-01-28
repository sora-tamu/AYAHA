package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.QuestionDAO;
import model.Question;
import util.DBManager;

@WebServlet("/view/StartPlaylistServlet")
public class StartPlaylistServlet extends HttpServlet {
    private QuestionDAO qDAO;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // DBパス設定
        String dbRealPath = getServletContext().getRealPath("/WEB-INF/db/main_v3.db");
        DBManager.setRealPath(dbRealPath);
        if (qDAO == null) qDAO = new QuestionDAO();

        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int playlistId = Integer.parseInt(idStr);
                List<Question> questions = qDAO.getQuestionsByPlaylistId(playlistId);
                
                if (questions != null && !questions.isEmpty()) {
                    // セッションに問題IDのリストを保存（AnswerServletで次へ進むために使用）
                    List<Integer> ids = new ArrayList<>();
                    for(Question q : questions) ids.add(q.getId());
                    
                    HttpSession session = request.getSession();
                    session.setAttribute("playlistIds", ids);
                    session.setAttribute("currentIndex", 0);

                    // 1問目をリクエストにセットして回答画面(answer.jsp)へ
                    request.setAttribute("question", questions.get(0));
                    request.getRequestDispatcher("/view/answer.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect(request.getContextPath() + "/view/MyQuestionsServlet");
    }
}