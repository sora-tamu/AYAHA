package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement; // 追加

import model.User;
import util.DBManager; 

public class UserDAO {

    // --- コンストラクタ: 起動時にテーブルを自動作成する ---
    public UserDAO() {
        try (Connection conn = DBManager.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // user_table がなければ作成する
            // カラム名は提供されたコードに合わせて user_name にしています
            stmt.execute("CREATE TABLE IF NOT EXISTS user_table (" +
                         "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                         "user_name TEXT UNIQUE NOT NULL, " +
                         "password TEXT NOT NULL, " +
                         "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
            
        } catch (SQLException e) {
            System.err.println("UserDAO初期化エラー: " + e.getMessage());
        }
    }

    /**
     * ログイン認証
     */
    public User login(String name, String password) {
        String sql = "SELECT id, user_name FROM user_table WHERE user_name = ? AND password = ?";
        
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, name);
            pstmt.setString(2, password);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setName(rs.getString("user_name"));
                    return user;
                }
            }
        } catch (SQLException e) {
            System.err.println("ログイン処理エラー: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 新規ユーザー登録
     */
    public boolean register(String name, String password) {
        String sql = "INSERT INTO user_table (user_name, password) VALUES (?, ?)";
        
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, name);
            pstmt.setString(2, password);
            
            int result = pstmt.executeUpdate();
            return result > 0;
            
        } catch (SQLException e) {
            System.err.println("ユーザー登録エラー: " + e.getMessage());
            return false;
        }
    }
}