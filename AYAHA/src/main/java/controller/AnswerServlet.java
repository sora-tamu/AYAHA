package controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.QuestionDAO;
import model.Question;

@WebServlet("/view/AnswerServlet")
public class AnswerServlet extends HttpServlet {
    private QuestionDAO qDAO = new QuestionDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/main.jsp");
            return;
        }

        int id = Integer.parseInt(idStr);
        Question q = qDAO.getQuestionById(id);
        
        HttpSession session = request.getSession();
        @SuppressWarnings("unchecked")
        List<Integer> playlistIds = (List<Integer>) session.getAttribute("playlistIds");
        
        if (playlistIds != null) {
            int index = playlistIds.indexOf(Integer.valueOf(id));
            if (index != -1) {
                session.setAttribute("currentIndex", index);
            }
        }
        
        if (q != null && "複数選択".equals(q.getType())) {
            List<String> choices = new ArrayList<>();
            choices.add(q.getAnswer());
            choices.add(q.getChoice1());
            choices.add(q.getChoice2());
            choices.add(q.getChoice3());
            choices.removeIf(c -> c == null || c.isEmpty());
            Collections.shuffle(choices);
            request.setAttribute("shuffledChoices", choices);
        }
        
        request.setAttribute("question", q);
        
        // 修正ポイント：サーブレットが /view/ にあるので、JSP名だけでOK
        request.getRequestDispatcher("answer.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        
        String idStr = request.getParameter("id");
        String userAnswer = request.getParameter("userAnswer");
        
        if (idStr == null || userAnswer == null) {
            response.sendRedirect(request.getContextPath() + "/main.jsp");
            return;
        }

        int id = Integer.parseInt(idStr);
        Question q = qDAO.getQuestionById(id);
        
        boolean isCorrect = false;
        if (q != null && q.getAnswer() != null) {
            isCorrect = q.getAnswer().trim().equalsIgnoreCase(userAnswer.trim());
            qDAO.updateStatistics(id, isCorrect);
        }

        @SuppressWarnings("unchecked")
        List<Integer> playlistIds = (List<Integer>) session.getAttribute("playlistIds");
        Integer currentIndex = (Integer) session.getAttribute("currentIndex");

        if (playlistIds != null && currentIndex != null) {
            int nextIndex = currentIndex + 1;
            if (nextIndex < playlistIds.size()) {
                request.setAttribute("nextQuestionId", playlistIds.get(nextIndex));
            } else {
                request.setAttribute("isPlaylistFinished", true);
            }
        }

        request.setAttribute("question", q);
        request.setAttribute("isCorrect", isCorrect);
        request.setAttribute("userAnswer", userAnswer);
        
        // 修正ポイント：ここも result.jsp だけでOK
        request.getRequestDispatcher("result.jsp").forward(request, response);
    }
}