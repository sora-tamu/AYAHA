package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import dao.UserDAO;
import util.DBManager;

@WebServlet("/UserRegisterServlet")
public class UserRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // フィールドでは宣言のみ行い、ここでは new UserDAO() しない
    private UserDAO userDAO;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. まずDBファイルの保存先パスを確定させる
        // 以前のファイルと混同しないよう、新しいファイル名「main_v3.db」を推奨します
        String dbRealPath = getServletContext().getRealPath("/WEB-INF/db/main_v3.db");
        DBManager.setRealPath(dbRealPath);
        
        // 2. パスが確定した後に UserDAO を作成する
        // 初回実行時のみインスタンスを作成（この時、UserDAOのコンストラクタでテーブルが作られる）
        if (userDAO == null) {
            userDAO = new UserDAO();
        }
        
        // リクエストの文字エンコーディング設定
        request.setCharacterEncoding("UTF-8");
        
        // フォームから値を取得
        String userName = request.getParameter("userName");
        String password = request.getParameter("password");

        // 3. DAOを使用して登録処理を実行
        boolean isSuccess = userDAO.register(userName, password);
        
        // 結果に応じてリダイレクト
        if (isSuccess) {
            // 登録成功時はログイン画面へ
            response.sendRedirect("login.jsp");
        } else {
            // 失敗時は再度サインアップ画面へ
            response.sendRedirect("signup.jsp");
        }
    }
}