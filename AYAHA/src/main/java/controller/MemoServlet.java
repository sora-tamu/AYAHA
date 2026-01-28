package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.MemoDAO;
// 【重要】自作の User クラスをインポートします
import model.User;

@WebServlet("/view/MemoServlet")
public class MemoServlet extends HttpServlet {
    private MemoDAO mDAO = new MemoDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 日本語の文字化け対策
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        
        // model.User 型として正しく取得
        User loginUser = (User) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.sendRedirect("../login.jsp");
            return;
        }

        // メモ内容を取得して保存
        String content = request.getParameter("memoContent");
        
        // model.User クラスに getId() メソッドがあれば、これで保存が実行されます
        mDAO.saveMemo(loginUser.getId(), content);

        // 元の画面に戻る（Refererを利用）
        String referer = request.getHeader("Referer");
        response.sendRedirect(referer != null ? referer : "main.jsp");
    }
}