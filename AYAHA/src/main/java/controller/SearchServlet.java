package controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import dao.QuestionDAO;
import model.Playlist;
import util.DBManager;

@WebServlet("/view/SearchServlet")
public class SearchServlet extends HttpServlet {
    private QuestionDAO qDAO;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. DBパス設定：これがないとDAOが正しいDBを参照できません
        String dbRealPath = getServletContext().getRealPath("/WEB-INF/db/main_v3.db");
        DBManager.setRealPath(dbRealPath);
        
        if (qDAO == null) {
            qDAO = new QuestionDAO();
        }

        // リクエストの文字エンコーディング設定
        request.setCharacterEncoding("UTF-8");
        String keyword = request.getParameter("keyword");
        if (keyword == null) keyword = ""; 

        // 2. キーワードに基づいて検索を実行
        List<Playlist> results = qDAO.searchQuestions(keyword);

        // 3. JSPへデータを渡す
        request.setAttribute("searchResults", results);
        request.setAttribute("lastKeyword", keyword);

        // search.jspへ遷移
        request.getRequestDispatcher("/view/search.jsp").forward(request, response);
    }
}