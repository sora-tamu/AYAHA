package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.BookmarkDAO;
import model.User;
import util.DBManager;

@WebServlet("/view/BookmarkServlet")
public class BookmarkServlet extends HttpServlet {
    private BookmarkDAO bDAO;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String dbRealPath = getServletContext().getRealPath("/WEB-INF/db/main_v3.db");
        DBManager.setRealPath(dbRealPath);
        if (bDAO == null) bDAO = new BookmarkDAO();

        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("../login.jsp");
            return;
        }

        String pIdStr = request.getParameter("questionId"); // パラメータ名はJSPと合わせる
        String action = request.getParameter("action");

        if (pIdStr != null && !pIdStr.isEmpty()) {
            try {
                int pId = Integer.parseInt(pIdStr);
                if ("remove".equals(action)) {
                    bDAO.removeBookmark(loginUser.getId(), pId);
                } else {
                    bDAO.addBookmark(loginUser.getId(), pId);
                }
            } catch (Exception e) { e.printStackTrace(); }
        }

        // 処理後にお気に入り一覧へ
        response.sendRedirect("BookmarkListServlet");
    }
}