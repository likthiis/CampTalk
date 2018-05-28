package com.example.wzf.camptalk.model;

import com.google.gson.Gson;

public class message {
    private String sender;
    private String receiver;
    private String content;
    private static Gson gson = new Gson();

    public message() {

    }

    public String getMessageToJson() {
        // 将类转换成JSON
        return gson.toJson(this);
    }

    public String getSender() {
        return sender;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public String getReceiver() {
        return receiver;
    }

    public void setReceiver(String receiver) {
        this.receiver = receiver;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
