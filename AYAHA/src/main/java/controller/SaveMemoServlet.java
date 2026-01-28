package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.MemoDAO;
import model.User;
import util.DBManager;

@WebServlet("/view/SaveMemoServlet")
public class SaveMemoServlet extends HttpServlet {
    private MemoDAO memoDAO = new MemoDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String dbRealPath = getServletContext().getRealPath("/WEB-INF/db/main_v3.db");
        DBManager.setRealPath(dbRealPath);

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loginUser");

        if (user != null) {
            String content = request.getParameter("memo");
            memoDAO.saveMemo(user.getId(), content);
            // Ajax用に応答
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Success");
        } else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        }
    }
}