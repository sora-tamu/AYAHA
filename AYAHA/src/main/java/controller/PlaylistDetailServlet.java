package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import dao.QuestionDAO;
import model.Question;
import util.DBManager;

@WebServlet("/view/PlaylistDetailServlet")
public class PlaylistDetailServlet extends HttpServlet {
    private QuestionDAO qDAO;

    // GET: 問題一覧を表示する
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. DBパス設定を最初に行う
        String dbRealPath = getServletContext().getRealPath("/WEB-INF/db/main_v3.db");
        DBManager.setRealPath(dbRealPath);
        
        if (qDAO == null) {
            qDAO = new QuestionDAO();
        }

        // 2. パラメータ名を playlistId に統一（JSP側と合わせる）
        String idStr = request.getParameter("playlistId");
        
        // もし id という名前でも来る可能性があるなら、両方チェックすると安全です
        if (idStr == null) idStr = request.getParameter("id");

        if (idStr != null && !idStr.isEmpty()) {
            try {
                int playlistId = Integer.parseInt(idStr);
                List<Question> questions = qDAO.getQuestionsByPlaylistId(playlistId);
                request.setAttribute("questions", questions);
                request.setAttribute("playlistId", playlistId);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
        request.getRequestDispatcher("/view/playlistDetail.jsp").forward(request, response);
    }

    // POST: 個別問題の削除処理
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String dbRealPath = getServletContext().getRealPath("/WEB-INF/db/main_v3.db");
        DBManager.setRealPath(dbRealPath);
        if (qDAO == null) qDAO = new QuestionDAO();

        String action = request.getParameter("action");
        String playlistId = request.getParameter("playlistId");

        if ("deleteQuestion".equals(action)) {
            try {
                int qId = Integer.parseInt(request.getParameter("questionId"));
                qDAO.deleteQuestion(qId); 
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        // 削除後、パラメータ名を playlistId にして詳細画面へ戻る
        response.sendRedirect("PlaylistDetailServlet?playlistId=" + playlistId);
    }
}