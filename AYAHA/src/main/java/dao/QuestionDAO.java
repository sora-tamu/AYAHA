package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Playlist;
import model.Question;
import util.DBManager;

public class QuestionDAO {

    // --- コンストラクタ（テーブル初期化） ---
    public QuestionDAO() {
        try (Connection conn = DBManager.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // 1. プレイリストテーブル
            stmt.execute("CREATE TABLE IF NOT EXISTS playlist_table (" +
                         "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                         "user_id INTEGER NOT NULL DEFAULT 0, " +
                         "name TEXT NOT NULL, " +
                         "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
            
            // 2. 問題テーブル
            stmt.execute("CREATE TABLE IF NOT EXISTS question_table (" +
                         "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                         "playlist_id INTEGER DEFAULT 0, " +
                         "user_id INTEGER NOT NULL DEFAULT 0, " +
                         "title TEXT NOT NULL, " +
                         "content TEXT, " +
                         "type TEXT, " +
                         "answer TEXT, " +
                         "choice_1 TEXT, " +
                         "choice_2 TEXT, " +
                         "choice_3 TEXT, " +
                         "explanation TEXT, " +
                         "is_public INTEGER DEFAULT 1, " +
                         "total_attempts INTEGER DEFAULT 0, " +
                         "total_correct INTEGER DEFAULT 0, " +
                         "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

            // 3. タグ関連
            stmt.execute("CREATE TABLE IF NOT EXISTS tag_table (id INTEGER PRIMARY KEY AUTOINCREMENT, tag_name TEXT UNIQUE NOT NULL)");
            stmt.execute("CREATE TABLE IF NOT EXISTS question_tag_table (question_id INTEGER, tag_id INTEGER, PRIMARY KEY (question_id, tag_id))");

        } catch (SQLException e) {
            System.err.println("DB初期化エラー: " + e.getMessage());
        }
    }

    /** MyQuestionsServlet から呼び出されるメソッド */
    public List<Playlist> getMyQuestions(int userId) {
        return getMyPlaylists(userId);
    }

    /** ユーザーが作成したプレイリスト一覧を取得 */
    public List<Playlist> getMyPlaylists(int userId) {
        List<Playlist> results = new ArrayList<>();
        String sql = "SELECT p.*, COUNT(q.id) as q_count FROM playlist_table p " +
                     "LEFT JOIN question_table q ON p.id = q.playlist_id " +
                     "WHERE p.user_id = ? GROUP BY p.id ORDER BY p.id DESC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Playlist p = new Playlist();
                    p.setId(rs.getInt("id"));
                    p.setName(rs.getString("name"));
                    p.setQuestionCount(rs.getInt("q_count"));
                    results.add(p);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return results;
    }

    /** プレイリストを新規作成 */
    public int createPlaylist(String name, int userId) {
        String sql = "INSERT INTO playlist_table(name, user_id) VALUES(?, ?)";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, name);
            pstmt.setInt(2, userId);
            pstmt.executeUpdate();
            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return -1;
    }

    /** 問題保存（タグも保存） */
    public void addQuestionToPlaylist(int playlistId, Question q, String[] tags, int userId) {
        String sql = "INSERT INTO question_table(playlist_id, user_id, title, content, type, answer, choice_1, choice_2, choice_3, explanation, is_public) VALUES(?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBManager.getConnection()) {
            conn.setAutoCommit(false); 
            try (PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                pstmt.setInt(1, playlistId);
                pstmt.setInt(2, userId);
                pstmt.setString(3, q.getTitle());
                pstmt.setString(4, q.getContent());
                pstmt.setString(5, q.getType());
                pstmt.setString(6, q.getAnswer());
                pstmt.setString(7, q.getChoice1());
                pstmt.setString(8, q.getChoice2());
                pstmt.setString(9, q.getChoice3());
                pstmt.setString(10, q.getExplanation());
                pstmt.setInt(11, q.isPublic() ? 1 : 0);
                pstmt.executeUpdate();

                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        saveTagsInternal(conn, rs.getInt(1), tags);
                    }
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) { e.printStackTrace(); }
    }

    /** プレイリストとその中の問題を一括削除 */
    public void deletePlaylist(int playlistId) {
        try (Connection conn = DBManager.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String sqlDelTags = "DELETE FROM question_tag_table WHERE question_id IN (SELECT id FROM question_table WHERE playlist_id = ?)";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlDelTags)) {
                    pstmt.setInt(1, playlistId);
                    pstmt.executeUpdate();
                }
                String sqlDelQuestions = "DELETE FROM question_table WHERE playlist_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlDelQuestions)) {
                    pstmt.setInt(1, playlistId);
                    pstmt.executeUpdate();
                }
                String sqlDelPlaylist = "DELETE FROM playlist_table WHERE id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlDelPlaylist)) {
                    pstmt.setInt(1, playlistId);
                    pstmt.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) { e.printStackTrace(); }
    }

    /** 公開されているプレイリストを検索 */
    public List<Playlist> searchQuestions(String keyword) {
        List<Playlist> results = new ArrayList<>();
        boolean hasKeyword = (keyword != null && !keyword.trim().isEmpty());
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT DISTINCT p.id, p.name, (SELECT COUNT(*) FROM question_table WHERE playlist_id = p.id) as q_count FROM playlist_table p ");
        sql.append("JOIN question_table q ON p.id = q.playlist_id ");
        sql.append("LEFT JOIN question_tag_table qtt ON q.id = qtt.question_id ");
        sql.append("LEFT JOIN tag_table t ON qtt.tag_id = t.id ");
        sql.append("WHERE q.is_public = 1 ");
        if (hasKeyword) {
            sql.append("AND (p.name LIKE ? OR t.tag_name LIKE ? OR q.title LIKE ?) ");
        }
        sql.append("ORDER BY p.id DESC");

        try (Connection conn = DBManager.getConnection(); 
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            if (hasKeyword) {
                String fuzzy = "%" + keyword.trim() + "%";
                pstmt.setString(1, fuzzy);
                pstmt.setString(2, fuzzy);
                pstmt.setString(3, fuzzy);
            }
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Playlist p = new Playlist();
                    p.setId(rs.getInt("id"));
                    p.setName(rs.getString("name"));
                    p.setQuestionCount(rs.getInt("q_count"));
                    results.add(p);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return results;
    }

    /** プレイリスト内の全問題取得 */
    public List<Question> getQuestionsByPlaylistId(int playlistId) {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT * FROM question_table WHERE playlist_id = ? ORDER BY id ASC";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, playlistId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Question q = new Question();
                    q.setId(rs.getInt("id"));
                    q.setPlaylistId(rs.getInt("playlist_id"));
                    q.setTitle(rs.getString("title"));
                    q.setContent(rs.getString("content"));
                    q.setType(rs.getString("type"));
                    q.setAnswer(rs.getString("answer"));
                    list.add(q);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /** 個別問題取得 */
    public Question getQuestionById(int id) {
        String sql = "SELECT q.*, (SELECT GROUP_CONCAT(t.tag_name, ', ') FROM question_tag_table qtt JOIN tag_table t ON qtt.tag_id = t.id WHERE qtt.question_id = q.id) AS tags_str FROM question_table q WHERE q.id = ?";
        try (Connection conn = DBManager.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Question q = new Question();
                    q.setId(rs.getInt("id"));
                    q.setPlaylistId(rs.getInt("playlist_id"));
                    q.setTitle(rs.getString("title"));
                    q.setContent(rs.getString("content"));
                    q.setType(rs.getString("type"));
                    q.setAnswer(rs.getString("answer"));
                    q.setChoice1(rs.getString("choice_1"));
                    q.setChoice2(rs.getString("choice_2"));
                    q.setChoice3(rs.getString("choice_3"));
                    q.setExplanation(rs.getString("explanation"));
                    q.setTags(rs.getString("tags_str")); 
                    q.setPublic(rs.getInt("is_public") == 1);
                    return q;
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    /** 統計更新メソッド */
    public void updateStatistics(int id, boolean isCorrect) {
        String sql = "UPDATE question_table SET total_attempts = total_attempts + 1, total_correct = total_correct + ? WHERE id = ?";
        try (Connection conn = DBManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, isCorrect ? 1 : 0);
            pstmt.setInt(2, id);
            pstmt.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    /** * 修正案２：引数1つだけの古い呼び出し方に対応させるためのメソッド
     * 内部でタグを null として、引数2つの updateQuestion を呼び出します。
     */
    public boolean updateQuestion(Question q) {
        return updateQuestion(q, null);
    }

    /** 問題の更新（選択肢とタグの更新に対応） */
    public boolean updateQuestion(Question q, String[] tags) {
        String sql = "UPDATE question_table SET title=?, content=?, answer=?, choice_1=?, choice_2=?, choice_3=?, explanation=?, is_public=? WHERE id=?";
        try (Connection conn = DBManager.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, q.getTitle());
                pstmt.setString(2, q.getContent());
                pstmt.setString(3, q.getAnswer());
                pstmt.setString(4, q.getChoice1());
                pstmt.setString(5, q.getChoice2());
                pstmt.setString(6, q.getChoice3());
                pstmt.setString(7, q.getExplanation());
                pstmt.setInt(8, q.isPublic() ? 1 : 0);
                pstmt.setInt(9, q.getId());
                
                int rows = pstmt.executeUpdate();

                // タグの更新：一度消して登録し直す
                if (tags != null) {
                    try (PreparedStatement delPstmt = conn.prepareStatement("DELETE FROM question_tag_table WHERE question_id = ?")) {
                        delPstmt.setInt(1, q.getId());
                        delPstmt.executeUpdate();
                    }
                    saveTagsInternal(conn, q.getId(), tags);
                }

                conn.commit();
                return rows > 0;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    /** 個別問題の削除 */
    public void deleteQuestion(int id) {
        try (Connection conn = DBManager.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String sqlTag = "DELETE FROM question_tag_table WHERE question_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlTag)) {
                    pstmt.setInt(1, id);
                    pstmt.executeUpdate();
                }
                String sqlQuestion = "DELETE FROM question_table WHERE id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlQuestion)) {
                    pstmt.setInt(1, id);
                    pstmt.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) { e.printStackTrace(); }
    }

    /** タグ保存用内部メソッド */
    private void saveTagsInternal(Connection conn, int questionId, String[] tags) throws SQLException {
        if (tags == null) return;
        String tagSql = "INSERT OR IGNORE INTO tag_table(tag_name) VALUES(?)";
        String linkSql = "INSERT INTO question_tag_table(question_id, tag_id) SELECT ?, id FROM tag_table WHERE tag_name = ?";
        try (PreparedStatement p1 = conn.prepareStatement(tagSql); PreparedStatement p2 = conn.prepareStatement(linkSql)) {
            for (String t : tags) {
                String name = t.trim();
                if (name.isEmpty()) continue;
                p1.setString(1, name); p1.executeUpdate();
                p2.setInt(1, questionId); p2.setString(2, name); p2.executeUpdate();
            }
        }
    }
}