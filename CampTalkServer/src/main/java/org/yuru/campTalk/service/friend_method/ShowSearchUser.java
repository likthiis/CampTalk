package org.yuru.campTalk.service.friend_method;

import com.google.gson.Gson;
import org.yuru.campTalk.entity.YuruUserEntity;

import java.sql.Timestamp;

// 因为用户实体类根据hibernate协议不能才转换为JSON，特开辟此类，处理获得的用户信息
public class ShowSearchUser {
    private String id;
    private String username;
    private Integer level;
    private Integer status;
    private Timestamp createtimestamp;
    private String location;
    private String headpid;

    private static Gson gson = new Gson();

    public ShowSearchUser(YuruUserEntity yuruUserEntity) {
        this.id = yuruUserEntity.getId();
        this.username = yuruUserEntity.getUsername();
        this.status = yuruUserEntity.getStatus();
        this.level = yuruUserEntity.getLevel();
        this.location = yuruUserEntity.getLocation();
    }

    public String getMessageToJson() {
        // 将类转换成JSON
        return gson.toJson(this);
    }
}
