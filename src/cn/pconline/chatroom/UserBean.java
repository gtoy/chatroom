package cn.pconline.chatroom;

public class UserBean {

    private long userBeanId;
    private String sessionId;
    private String name;
    private int age;

    public UserBean(String name, String sessionId) {
        this.name = name;
        this.sessionId = sessionId;
    }

    public long getUserBeanId() {
        return userBeanId;
    }

    public void setUserBeanId(long userBeanId) {
        this.userBeanId = userBeanId;
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }
}
