package org.yuru.campTalk.dto;

import com.google.gson.Gson;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Author: Rinkako
 * Date  : 2018/4/16
 * Usage : A data model which encapsulated to return.
 */

public class ReturnModel<T> implements Serializable {
    private String status; // 状态码
    private String timestamp; // 时间戳
    private String token; // 口令
    private T request; // 返回的具体内容

    public ReturnModel() {
        this.status = "stand_by";
        this.timestamp = new Timestamp(System.currentTimeMillis()).toString();
        this.token = "empty_token";
        this.request = (T)"waiting_input";
    }


    public String getStatus() {
        return this.status;
    }
    public void setStatus(String status) {
        this.status = status;
    }
    public String getTimestamp() {
        return this.timestamp;
    }
    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }
    public String getToken() {
        return this.token;
    }
    public void setToken(String token) {
        this.token = token;
    }
    public T getRequest() {
        return this.request;
    }
    public void setRequest(T request) {
        this.request = request;
    }

    public void specialDeal() {
        this.status = "exception_occurred";
        this.timestamp = new Timestamp(System.currentTimeMillis()).toString();
    }

    public void successDeal(String status) {
        this.status = status;
        this.timestamp = new Timestamp(System.currentTimeMillis()).toString();
    }
}
