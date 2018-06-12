package org.yuru.campTalk.service.friend_method;

import com.google.gson.Gson;
import org.yuru.campTalk.entity.YuruUserEntity;


public class ShowSearchUser {
    private String id;
    private String username;
    private Integer level;
    private Integer status;
    private String location;

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
