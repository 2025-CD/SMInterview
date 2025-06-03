package sm.ac.app.dto;

public class ChatMessage {
    private String sender;
    private String message;

    // 이 Getter/Setter 메서드들이 올바르게 정의되어 있는지 확인하세요.
    public String getSender() { return sender; }
    public void setSender(String sender) { this.sender = sender; }
    public String getMessage() { return message; }
    public  void setMessage(String message) { this.message = message; } // 오타 조심!
}

