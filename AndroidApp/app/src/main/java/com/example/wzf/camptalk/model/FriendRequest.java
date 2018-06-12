package com.example.wzf.camptalk.model;

import com.google.gson.Gson;

public class FriendRequest {
    private String myUid;
    private String itsUid;
    private static Gson gson = new Gson();

    public String getMessageToJson() {
        // 将类转换成JSON
        return gson.toJson(this);
    }

    public String getMyUid() {
        return myUid;
    }

    public void setMyUid(String myUid) {
        this.myUid = myUid;
    }

    public String getItsUid() {
        return itsUid;
    }

    public void setItsUid(String itsUid) {
        this.itsUid = itsUid;
    }
}
