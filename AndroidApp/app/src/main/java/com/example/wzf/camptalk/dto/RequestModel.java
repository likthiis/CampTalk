package com.example.wzf.camptalk.dto;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import com.example.wzf.camptalk.Activity.LoginMain;
import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;

public class RequestModel<T> {
    // 请求实体类

    @SerializedName("action")
    private String action; // 动作码，表示该请求的具体内容
    @SerializedName("timestamp")
    private String timestamp; // 时间戳
    @SerializedName("token")
    private String token; // 唯一验证码，用于验证该操作的合法性
    @SerializedName("req")
    private T req;

    public RequestModel(String action, String timestamp, String token, T req) {
        this.action = action;
        this.timestamp = timestamp;
        this.token = token;
        this.req = req;
    }

    private static Gson gson = new Gson();

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getTimestamp() {
        return timestamp;
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

    public T getReq() {
        return req;
    }

    public void setReq(T req) {
        this.req = req;
    }

    public static class Builder<T> {
        private String action; // 动作码，表示该请求的具体内容
        private String timestamp; // 时间戳
        private String token; // 唯一验证码，用于验证该操作的合法性
        private T req;

        public Builder action(String action) {
            this.action = action;
            return this;
        }

        public Builder timestamp(String timestamp) {
            this.timestamp = timestamp;
            return this;
        }

        public Builder token(String token) {
            this.token = token;
            return this;
        }

        public Builder req(T req) {
            this.req = req;
            return this;
        }

        public RequestModel build() {
            return new RequestModel<T>(action, timestamp, token, req);
        }
    }

    // 借鉴的
    private boolean isNetConnect() {
        ConnectivityManager connectivity = (ConnectivityManager) LoginMain.getInstance()
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        if (connectivity != null) {
            NetworkInfo info = connectivity.getActiveNetworkInfo();
            if (info != null && info.isConnected()) {
                // 当前网络是连接的
                if (info.getState() == NetworkInfo.State.CONNECTED) {
                    // 当前所连接的网络可用
                    return true;
                }
            }
        }
        return false;
    }

}
