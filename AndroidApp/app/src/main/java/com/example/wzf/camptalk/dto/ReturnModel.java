package com.example.wzf.camptalk.dto;

import com.google.gson.Gson;
import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Author: Likthiis
 * Date  : 2018/6/3
 * Usage : A data model which encapsulated to return.
 */
public class ReturnModel<T> implements Serializable {
    private String status; // 状态码
    private String timestamp; // 时间戳
    private String token = null; // 口令
    private T request; // 返回的具体内容
    private static Gson gson = new Gson();

    public String getStatus() {
        return this.status;
    }
    public void setStatus(String code) {
        this.status = status;
    }
    public String getTimestamp() {
        return this.timestamp;
    }
    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }
    public String getToken() {
        return token;
    }
    public void setToken(String token) {
        this.token = token;
    }
    public T getRequest() {
        return request;
    }
    public void setRequest(T request) {
        this.request = request;
    }

    public String getMessageToJson() {
        // 将类转换成JSON
        return gson.toJson(this);
    }

    public void specialDeal() {
        this.status = "exception_occurred";
        this.timestamp = new Timestamp(System.currentTimeMillis()).toString();
        this.token = null;
    }

    public void successDeal(String status) {
        this.status = status;
        this.timestamp = new Timestamp(System.currentTimeMillis()).toString();
        this.token = null;
    }
}
