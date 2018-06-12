package com.example.wzf.camptalk.netService;

public enum Action {
    LOGIN("login", null),
    FRIENDREQUEST("friend_request", null),
    USERSEARCH("user_search", null);


    private String  action;
    private Class respClazz;

    Action(String action, Class respClazz) {
        this.action = action;
        this.respClazz = respClazz;
    }

    public String getAction() {
        return action;
    }

    public Class getRespClazz() {
        return respClazz;
    }
}
