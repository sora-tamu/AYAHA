package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.UserDAO;
import model.User;
import util.DBManager;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // ここで new UserDAO() しないように修正
    private UserDAO userDAO;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. まずDBファイルのパスを確定させる
        // ※UserRegisterServletで登録に成功した時と同じファイル名にしてください
        String dbRealPath = getServletContext().getRealPath("/WEB-INF/db/main_v3.db");
        DBManager.setRealPath(dbRealPath);

        // 2. パス確定後に DAO を作成
        if (userDAO == null) {
            userDAO = new UserDAO();
        }

        request.setCharacterEncoding("UTF-8");
        String name = request.getParameter("userName");
        String pass = request.getParameter("password");

        // 3. ログイン認証実行
        User user = userDAO.login(name, pass);

        if (user != null) {
            // ログイン成功
            HttpSession session = request.getSession();
            session.setAttribute("loginUser", user);
            session.setAttribute("userId", user.getId());
            session.setAttribute("userName", user.getName());
            
            // メイン画面へリダイレクト
            response.sendRedirect("view/main.jsp");
        } else {
            // ログイン失敗
            request.setAttribute("error", "名前またはパスワードが正しくありません。");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}