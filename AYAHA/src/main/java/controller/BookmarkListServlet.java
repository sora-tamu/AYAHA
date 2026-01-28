package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.BookmarkDAO;
import model.Playlist;
import model.User;
import util.DBManager;

@WebServlet("/view/BookmarkListServlet")
public class BookmarkListServlet extends HttpServlet {
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

        // プレイリスト一覧を取得
        List<Playlist> bookmarkedList = bDAO.getBookmarkedPlaylists(loginUser.getId());
        request.setAttribute("bookmarkedList", bookmarkedList);
        
        request.getRequestDispatcher("/view/bookmarkList.jsp").forward(request, response);
    }
}