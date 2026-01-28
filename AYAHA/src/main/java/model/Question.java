package model;

import java.io.Serializable;

public class Question implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int playlistId; 
    private int userId;
    private String title;
    private String content;
    private String type;
    private String answer;
    
    private String choice1;
    private String choice2;
    private String choice3;
    
    private String explanation;
    private String tags; 
    
    private boolean isPublic;
    private int totalAttempts;
    private int totalCorrect;

    public Question() {}

    // UpdateQuestionServlet等で使用するコンストラクタ
    public Question(int id, String title, String content, String answer, String explanation, String tags, boolean isPublic) {
        this.id = id;
        this.title = title;
        this.content = content;
        this.answer = answer;
        this.explanation = explanation;
        this.tags = tags;
        this.isPublic = isPublic;
    }

    // 正解率計算
    public double getClearRate() {
        if (totalAttempts == 0) return 0.0;
        return (double) totalCorrect / totalAttempts * 100.0;
    }
    
    // --- Getter/Setter ---
    
    public int getPlaylistId() { return playlistId; }
    public void setPlaylistId(int playlistId) { this.playlistId = playlistId; }

    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }

    public String getExplanation() { return explanation; }
    public void setExplanation(String explanation) { this.explanation = explanation; }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    
    public String getAnswer() { return answer; }
    public void setAnswer(String answer) { this.answer = answer; }
    
    public String getChoice1() { return choice1; }
    public void setChoice1(String choice1) { this.choice1 = choice1; }
    
    public String getChoice2() { return choice2; }
    public void setChoice2(String choice2) { this.choice2 = choice2; }
    
    public String getChoice3() { return choice3; }
    public void setChoice3(String choice3) { this.choice3 = choice3; }
    
    // ★重要：JSPの ${question.isPublic} でエラーが出ないよう、両方の命名規則に対応させる
    public boolean isPublic() { return isPublic; }
    public boolean getIsPublic() { return isPublic; } // 追加
    public void setPublic(boolean isPublic) { this.isPublic = isPublic; }
    
    public int getTotalAttempts() { return totalAttempts; }
    public void setTotalAttempts(int totalAttempts) { this.totalAttempts = totalAttempts; }
    
    public int getTotalCorrect() { return totalCorrect; }
    public void setTotalCorrect(int totalCorrect) { this.totalCorrect = totalCorrect; }
}