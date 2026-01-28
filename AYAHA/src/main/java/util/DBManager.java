package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBManager {
    private static String realPath;

    // パスを動的に設定するメソッド（残しておきます）
    public static void setRealPath(String path) {
        realPath = path;
    }

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("org.sqlite.JDBC");
        } catch (ClassNotFoundException e) {
            throw new SQLException("SQLite JDBC Driver not found.", e);
        }

        // 1. もし外部（Listener等）からパスが指定されたらそれを使う
        // 2. 指定がない場合は、カレントディレクトリにファイルを自動作成する
        String dbPath = (realPath != null) ? realPath : "main_v3.db";
        
        // 接続URLを作成
        String url = "jdbc:sqlite:" + dbPath;
        
        return DriverManager.getConnection(url);
    }
}