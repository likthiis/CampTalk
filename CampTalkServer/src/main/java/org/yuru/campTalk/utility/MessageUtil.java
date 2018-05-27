package org.yuru.campTalk.utility;

import com.google.gson.Gson;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

public class MessageUtil {
    // 该类用于将信息从服务端发送至客户端
    // 聊天，单聊 type = 1，群聊 type = 2
    private int type;

    // 记录了由谁发送信息，将信息发送给谁，以及信息的内容
    private String sender;
    private String content;
    private String receiver;

    // 记录各用户的用户名与其socket的信息，并提供了将数据转化为Json格式的工具
    private static Gson gson = new Gson();

    public MessageUtil(){

    }

    public String getMessageToJson() {
        // 将类转换成JSON
        return gson.toJson(this);
    }

    public void setContent(String content) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String time = sdf.format(new Date());
        this.content = "\r\n\r\n" + time + "\r\n" + this.sender + " said: " + content;
    }

    // get与set集中放置，个别被重新编写逻辑的会调出来

    public String getContent() {
        return content;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
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
}
