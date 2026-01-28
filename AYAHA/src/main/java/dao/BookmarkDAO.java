package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Playlist;
import util.DBManager;

/**
 * ブックマーク（お気に入り）および参照先テーブルの操作用DAO
 */
public class BookmarkDAO {

    public BookmarkDAO() {
        try (Connection conn = DBManager.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // 1. bookmark_table の自動生成
            // question_id は playlist_table の id を参照することを想定
            stmt.execute("CREATE TABLE IF NOT EXISTS bookmark_table (" +
                         "user_id INTEGER, " +
                         "question_id INTEGER, " +
                         "PRIMARY KEY (user_id, question_id))");
                         
        } catch (SQLException e) {
            System.err.println("BookmarkDAO初期化エラー: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * ブックマークの追加
     */
    public void addBookmark(int userId, int playlistId) {
        String sql = "INSERT OR IGNORE INTO bookmark_table (user_id, question_id) VALUES (?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, playlistId);
            pstmt.executeUpdate();
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
    }

    /**
     * ブックマークの削除
     */
    public void removeBookmark(int userId, int playlistId) {
        String sql = "DELETE FROM bookmark_table WHERE user_id = ? AND question_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, playlistId);
            pstmt.executeUpdate();
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
    }

    /**
     * ブックマーク済みかどうかの判定
     */
    public boolean isBookmarked(int userId, int playlistId) {
        String sql = "SELECT 1 FROM bookmark_table WHERE user_id = ? AND question_id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, playlistId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) { 
            return false; 
        }
    }

    /**
     * ユーザーがブックマークしたプレイリスト一覧を取得
     * ★修正ポイント: QuestionDAOに合わせてテーブル名を「playlist_table」に変更
     */
    public List<Playlist> getBookmarkedPlaylists(int userId) {
        List<Playlist> list = new ArrayList<>();
        
        // 【重要】playlists ではなく playlist_table を指定
        String sql = "SELECT p.* FROM playlist_table p " +
                     "INNER JOIN bookmark_table b ON p.id = b.question_id " +
                     "WHERE b.user_id = ?";
        
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Playlist p = new Playlist();
                    p.setId(rs.getInt("id"));
                    p.setName(rs.getString("name"));
                    // 必要に応じて created_at 等もセット
                    list.add(p);
                }
            }
        } catch (SQLException e) { 
            System.err.println("ブックマーク取得エラー: " + e.getMessage());
            e.printStackTrace(); 
        }
        return list;
    }
}