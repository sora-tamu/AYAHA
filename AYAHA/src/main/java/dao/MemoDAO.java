package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import util.DBManager;

/**
 * ユーザーごとのメモを管理するDAO
 */
public class MemoDAO {

    public MemoDAO() {
        // テーブル作成：user_idを主キーにすることで、1ユーザー1件のメモを保持
        String sql = "CREATE TABLE IF NOT EXISTS memo_table ("
                   + "user_id INTEGER PRIMARY KEY, "
                   + "content TEXT, "
                   + "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)";
        try (Connection conn = DBManager.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
        } catch (SQLException e) {
            System.err.println("MemoDAO: テーブル作成失敗 - " + e.getMessage());
        }
    }

    /**
     * メモを保存または更新
     */
    public void saveMemo(int userId, String content) {
        // INSERT OR REPLACE により、既存データがあれば更新、なければ挿入を行う
        String sql = "INSERT OR REPLACE INTO memo_table (user_id, content, updated_at) VALUES (?, ?, CURRENT_TIMESTAMP)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, content);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("MemoDAO: 保存エラー - " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * footer.jsp で使用されているメソッド名
     */
    public String getMemoByUserId(int userId) {
        return getMemo(userId);
    }

    /**
     * main.jsp や memo_popup.jsp で使用されているメソッド名
     */
    public String getMemo(int userId) {
        String sql = "SELECT content FROM memo_table WHERE user_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String content = rs.getString("content");
                    return (content != null) ? content : "";
                }
            }
        } catch (SQLException e) {
            System.err.println("MemoDAO: 取得エラー - " + e.getMessage());
            e.printStackTrace();
        }
        return ""; // メモが存在しない、またはエラー時は空文字を返す
    }
}