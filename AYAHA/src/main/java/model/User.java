package model;

import java.io.Serializable;

/**
 * ユーザー情報を保持するモデルクラス
 * JavaBeansの規約（直列化、引数なしコンストラクタ）に準拠
 */
public class User implements Serializable {
    private int id;
    private String name;
    private String password;

    // 引数なしコンストラクタ
    public User() {}

    // IDのゲッターとセッター
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    // 名前のゲッターとセッター
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    // パスワードのゲッターとセッター
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}