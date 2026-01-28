package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. セッションを取得
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // 2. セッションを無効化（破棄）する
            session.invalidate();
            System.out.println("ログアウト成功：セッションを破棄しました。");
        }

        // 3. ログイン画面へリダイレクト
        // main.jspはviewフォルダ内にあるため、一つ上の階層のlogin.jspを指定
        response.sendRedirect("login.jsp");
    }

    // POSTリクエストが来てもログアウトできるようにしておく
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}