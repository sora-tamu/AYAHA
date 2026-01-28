package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.QuestionDAO;
import model.Playlist;
import model.User;
import util.DBManager;

@WebServlet("/view/MyQuestionsServlet")
public class MyQuestionsServlet extends HttpServlet {
    private QuestionDAO qDAO;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // DB初期化
        String dbRealPath = getServletContext().getRealPath("/WEB-INF/db/main_v3.db");
        DBManager.setRealPath(dbRealPath);
        if (qDAO == null) qDAO = new QuestionDAO();

        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<Playlist> myPlaylists = qDAO.getMyQuestions(loginUser.getId());
        request.setAttribute("myPlaylists", myPlaylists);
        
        // 修正：遷移先のパスに /view/ を付与
        request.getRequestDispatcher("/view/myQuestions.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        
        String dbRealPath = getServletContext().getRealPath("/WEB-INF/db/main_v3.db");
        DBManager.setRealPath(dbRealPath);
        if (qDAO == null) qDAO = new QuestionDAO();

        if ("delete".equals(action) && idParam != null && !idParam.isEmpty()) {
            try {
                int id = Integer.parseInt(idParam);
                qDAO.deletePlaylist(id); // プレイリスト全体を削除
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect(request.getContextPath() + "/view/MyQuestionsServlet");
    }
}