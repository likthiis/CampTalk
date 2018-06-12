package com.example.wzf.camptalk.netService;

import android.app.Application;

public class Token extends Application{
    private String token;

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}
