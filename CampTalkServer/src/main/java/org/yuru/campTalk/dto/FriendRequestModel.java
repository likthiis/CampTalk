package org.yuru.campTalk.dto;

import com.google.gson.Gson;

// 好友请求的JSON数据对应的处理类
public class FriendRequestModel {

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
