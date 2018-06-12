package com.example.wzf.camptalk.model;

import com.google.gson.Gson;

import java.sql.Timestamp;

// 对应服务端的ShowSearchUser类
public class ShowSearchUser {
    private String id;
    private String username;
    private Integer status;
    private Integer level;
    private String location;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }
}
