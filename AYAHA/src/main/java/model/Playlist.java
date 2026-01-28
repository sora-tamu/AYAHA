package model;

import java.io.Serializable;

/**
 * プレイリスト（問題のまとまり）を管理するモデルクラス
 */
public class Playlist implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;             // プレイリストID
    private String name;        // プレイリスト名
    private int questionCount;  // プレイリストに含まれる問題数

    // デフォルトコンストラクタ
    public Playlist() {}

    // 全フィールドを指定するコンストラクタ
    public Playlist(int id, String name, int questionCount) {
        this.id = id;
        this.name = name;
        this.questionCount = questionCount;
    }

    // Getter と Setter
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getQuestionCount() {
        return questionCount;
    }

    public void setQuestionCount(int questionCount) {
        this.questionCount = questionCount;
    }
}